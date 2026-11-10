#!/usr/bin/env bash
# ==============================================================================
# Script de Configuración en Producción (75.119.136.151):
# 1. Asegura que la red Docker ddev_default tenga subred IPAM explícita para
#    permitir IPs estáticas (ipv4_address) en los contenedores.
# 2. Fija las IPs internas de Docker (.ddev/docker-compose.static-ip.yaml) y
#    puertos en todos los proyectos DDEV de /home/developer/Projects/* según
#    las redirecciones actuales de Apache (/etc/apache2/sites-available/*.conf).
# 3. Levanta DDEV en /home/developer/Projects/andarasalon (puerto 8084 / IP fija).
# 4. Crea y activa el VirtualHost de proxy inverso en Apache para andarasoft.com.
# ==============================================================================
set -euo pipefail

PROJECTS_DIR="/home/developer/Projects"
ANDARA_DIR="/home/developer/Projects/andarasalon"
APACHE_SITES_AVAIL="/etc/apache2/sites-available"

echo "=== [1/6] Habilitando módulos de Proxy Inverso y SSL en Apache ==="
a2enmod proxy proxy_http headers rewrite ssl >/dev/null 2>&1 || true

echo "=== [2/6] Verificando red Docker ddev_default y soporte de IPs estáticas ==="
if ! docker network inspect ddev_default >/dev/null 2>&1; then
    docker network create --driver bridge --subnet=172.18.0.0/16 --gateway=172.18.0.1 --label com.ddev.platform=ddev ddev_default
fi

SUBNET=$(docker network inspect ddev_default -f '{{range .IPAM.Config}}{{.Subnet}}{{end}}')
GATEWAY=$(docker network inspect ddev_default -f '{{range .IPAM.Config}}{{.Gateway}}{{end}}')
if [ -z "$SUBNET" ]; then
    SUBNET="172.18.0.0/16"
    GATEWAY="172.18.0.1"
fi
SUBNET_PREFIX=$(echo "$SUBNET" | cut -d'.' -f1-3)
echo "Red ddev_default detectada: Subred=${SUBNET}, Gateway=${GATEWAY}, Prefijo=${SUBNET_PREFIX}"

echo "=== [3/6] Capturando IPs actuales de contenedores y VirtualHosts de Apache ==="
declare -A PROJ_IPS
NEXT_OCTET=10

for proj_path in "$PROJECTS_DIR"/*; do
    [ -d "$proj_path/.ddev" ] || continue
    proj_dir_name=$(basename "$proj_path")
    ddev_name=$(grep -E '^name:' "$proj_path/.ddev/config.yaml" | awk '{print $2}' | tr -d '"'\''' || true)
    [ -n "$ddev_name" ] || continue

    container_name="ddev-${ddev_name}-web"
    assigned_ip=""

    # A) Comprobar si algún VirtualHost de Apache ya apunta a una IP 172.x.x.x para este proyecto/dominio
    vhost_file=$(grep -rilE "$ddev_name|$proj_dir_name" "$APACHE_SITES_AVAIL"/ 2>/dev/null | head -n1 || true)
    if [ -n "$vhost_file" ]; then
        vhost_ip=$(grep -E "ProxyPass\s+/" "$vhost_file" 2>/dev/null | grep -oE '172\.[0-9]+\.[0-9]+\.[0-9]+' | head -n1 || true)
        if [ -n "$vhost_ip" ]; then
            assigned_ip="$vhost_ip"
        fi
    fi

    # B) Si el contenedor está corriendo actualmente, conservar su IP actual en ddev_default
    if [ -z "$assigned_ip" ] && docker ps --format '{{.Names}}' | grep -qx "$container_name"; then
        assigned_ip=$(docker inspect -f '{{with index .NetworkSettings.Networks "ddev_default"}}{{.IPAddress}}{{end}}' "$container_name" 2>/dev/null || true)
    fi

    # C) Si no está corriendo, revisar si ya tiene docker-compose.static-ip.yaml con el prefijo correcto
    if [ -z "$assigned_ip" ] && [ -f "$proj_path/.ddev/docker-compose.static-ip.yaml" ]; then
        cfg_ip=$(grep -E 'ipv4_address:' "$proj_path/.ddev/docker-compose.static-ip.yaml" | awk '{print $2}' | tr -d '"'\''' || true)
        if [[ "$cfg_ip" == "${SUBNET_PREFIX}."* ]]; then
            assigned_ip="$cfg_ip"
        fi
    fi

    # C) Si es andara/andarasalon, usar .20 por defecto (o libre)
    if [ -z "$assigned_ip" ] && [ "$ddev_name" = "andara" ]; then
        assigned_ip="${SUBNET_PREFIX}.20"
    fi

    # D) Si sigue sin IP, asignar el siguiente octeto libre
    if [ -z "$assigned_ip" ]; then
        while printf '%s\n' "${PROJ_IPS[@]:-}" | grep -qx "${SUBNET_PREFIX}.${NEXT_OCTET}" || [ "$NEXT_OCTET" -eq 20 ]; do
            NEXT_OCTET=$((NEXT_OCTET + 1))
        done
        assigned_ip="${SUBNET_PREFIX}.${NEXT_OCTET}"
        NEXT_OCTET=$((NEXT_OCTET + 1))
    fi

    PROJ_IPS["$proj_path"]="$assigned_ip"
    echo " -> Proyecto [$ddev_name] ($proj_dir_name): IP interna fijada a ${assigned_ip}"

    cat > "$proj_path/.ddev/docker-compose.static-ip.yaml" <<EOF
services:
  web:
    networks:
      ddev_default:
        ipv4_address: ${assigned_ip}
EOF
    chown developer:developer "$proj_path/.ddev/docker-compose.static-ip.yaml"
done

echo "=== [4/6] Verificando que ddev_default permita asignación estática de IPs ==="
# Comprobar con un contenedor efímero si ddev_default tiene IPAM de usuario habilitado
if ! docker run --rm --network ddev_default --ip "${SUBNET_PREFIX}.250" alpine:latest true >/dev/null 2>&1; then
    echo "Recreando red ddev_default con --subnet=${SUBNET} explícito para permitir IPs fijas..."
    su - developer -c "ddev poweroff" || true
    docker network rm ddev_default >/dev/null 2>&1 || true
    docker network create --driver bridge --subnet="${SUBNET}" --gateway="${GATEWAY}" --label com.ddev.platform=ddev ddev_default
fi

echo "=== [5/6] Levantando todos los entornos DDEV con sus IPs fijas y desplegando Andara ==="
su - developer -c "cd '$ANDARA_DIR' && git fetch origin && git reset --hard origin/main"
# Asegurar que el static-ip de Andara coincide con el prefijo de subred del servidor
ANDARA_IP="${PROJ_IPS[$ANDARA_DIR]:-${SUBNET_PREFIX}.20}"
cat > "$ANDARA_DIR/.ddev/docker-compose.static-ip.yaml" <<EOF
services:
  web:
    networks:
      ddev_default:
        ipv4_address: ${ANDARA_IP}
EOF
chown developer:developer "$ANDARA_DIR/.ddev/docker-compose.static-ip.yaml"

for proj_path in "${!PROJ_IPS[@]}"; do
    proj_dir_name=$(basename "$proj_path")
    echo "Arrancando DDEV en $proj_dir_name (IP fija: ${PROJ_IPS[$proj_path]})..."
    su - developer -c "cd '$proj_path' && ddev start"
done

echo "=== [6/6] Configurando VirtualHost de Apache para andarasoft.com ==="
# Respaldar configuración previa de andarasoft si existía apuntando a directorio estático
for old_conf in "${APACHE_SITES_AVAIL}"/*andara*.conf; do
    [ -e "$old_conf" ] || continue
    cp -a "$old_conf" "${old_conf}.bak.$(date +%Y%m%d%H%M%S)"
done

# Buscar certificados SSL existentes para andarasoft.com
SSL_CERT=""
SSL_KEY=""
if [ -f "/etc/letsencrypt/live/andarasoft.com/fullchain.pem" ]; then
    SSL_CERT="/etc/letsencrypt/live/andarasoft.com/fullchain.pem"
    SSL_KEY="/etc/letsencrypt/live/andarasoft.com/privkey.pem"
elif [ -f "/etc/ssl/certs/andarasoft.com.crt" ]; then
    SSL_CERT="/etc/ssl/certs/andarasoft.com.crt"
    SSL_KEY="/etc/ssl/private/andarasoft.com.key"
else
    # Detectar si algún vhost existente ya tenía ruta de certificado para andarasoft.com
    EXISTING_CERT=$(grep -rnI "SSLCertificateFile" /etc/apache2/sites-enabled/ /etc/apache2/sites-available/ 2>/dev/null | grep -i "andara" | awk '{print $2}' | head -n1 || true)
    EXISTING_KEY=$(grep -rnI "SSLCertificateKeyFile" /etc/apache2/sites-enabled/ /etc/apache2/sites-available/ 2>/dev/null | grep -i "andara" | awk '{print $2}' | head -n1 || true)
    if [ -n "$EXISTING_CERT" ] && [ -f "$EXISTING_CERT" ]; then
        SSL_CERT="$EXISTING_CERT"
        SSL_KEY="$EXISTING_KEY"
    fi
fi

cat > "${APACHE_SITES_AVAIL}/andarasoft.com.conf" <<EOF
<VirtualHost *:80>
    ServerName andarasoft.com
    ServerAlias www.andarasoft.com

    ProxyPreserveHost On
    RequestHeader set X-Forwarded-Proto "http"
    RequestHeader set X-Forwarded-Port "80"

    # Proxy inverso hacia contenedor DDEV de Andara (puerto fijo 8084 / IP fija ${ANDARA_IP})
    ProxyPass / http://127.0.0.1:8084/
    ProxyPassReverse / http://127.0.0.1:8084/

    ErrorLog \${APACHE_LOG_DIR}/andarasoft_error.log
    CustomLog \${APACHE_LOG_DIR}/andarasoft_access.log combined
</VirtualHost>
EOF

if [ -n "$SSL_CERT" ] && [ -n "$SSL_KEY" ]; then
    cat > "${APACHE_SITES_AVAIL}/andarasoft.com-le-ssl.conf" <<EOF
<IfModule mod_ssl.c>
<VirtualHost *:443>
    ServerName andarasoft.com
    ServerAlias www.andarasoft.com

    ProxyPreserveHost On
    RequestHeader set X-Forwarded-Proto "https"
    RequestHeader set X-Forwarded-Port "443"

    # Proxy inverso hacia contenedor DDEV de Andara (puerto fijo 8084 / IP fija ${ANDARA_IP})
    ProxyPass / http://127.0.0.1:8084/
    ProxyPassReverse / http://127.0.0.1:8084/

    ErrorLog \${APACHE_LOG_DIR}/andarasoft_ssl_error.log
    CustomLog \${APACHE_LOG_DIR}/andarasoft_ssl_access.log combined

    SSLEngine on
    SSLCertificateFile ${SSL_CERT}
    SSLCertificateKeyFile ${SSL_KEY}
</VirtualHost>
</IfModule>
EOF
    a2ensite andarasoft.com-le-ssl.conf >/dev/null 2>&1 || true
fi

a2ensite andarasoft.com.conf >/dev/null 2>&1 || true
apache2ctl configtest
systemctl reload apache2

echo "=== Resumen de Contenedores DDEV e IPs Fijas en ddev_default ==="
for c in $(docker ps --format '{{.Names}}' | grep '^ddev-.*-web$'); do
    cip=$(docker inspect -f '{{with index .NetworkSettings.Networks "ddev_default"}}{{.IPAddress}}{{end}}' "$c" 2>/dev/null || true)
    cports=$(docker port "$c" 80/tcp 2>/dev/null | tr '\n' ' ' || true)
    echo " - $c => IP interna: $cip | Puerto Host: $cports"
done
