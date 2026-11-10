#!/usr/bin/env bash
# ==============================================================================
# Script de Configuración en Producción (vmi2545399 - 75.119.136.151):
# 1. Asegura que la red Docker ddev_default tenga subred IPAM explícita para
#    permitir IPs estáticas (ipv4_address) en los contenedores.
# 2. Fija las IPs internas de Docker (.ddev/docker-compose.static-ip.yaml) en
#    todos los proyectos DDEV de /home/developer/Projects/* y sincroniza los
#    VirtualHosts de /etc/apache2/sites-available/*.conf para que al reiniciar
#    Docker nunca cambien las IPs ni fallen las redirecciones del proxy inverso.
# 3. Levanta DDEV en /home/developer/Projects/andarasalon.
# 4. Crea y activa el VirtualHost de proxy inverso en Apache para andarasoft.com
#    (andarasoft.com.conf y andarasoft.com-le-ssl.conf).
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

echo "=== [3/6] Fijando IPs internas a fuego en todos los proyectos DDEV ==="
declare -A PROJ_IPS
declare -A DDEV_NAMES
NEXT_OCTET=10

for proj_path in "$PROJECTS_DIR"/*; do
    [ -d "$proj_path/.ddev" ] || continue
    proj_dir_name=$(basename "$proj_path")
    ddev_name=$(grep -E '^name:' "$proj_path/.ddev/config.yaml" | awk '{print $2}' | tr -d '"'\''' || true)
    [ -n "$ddev_name" ] || continue
    DDEV_NAMES["$proj_path"]="$ddev_name"

    container_name="ddev-${ddev_name}-web"
    assigned_ip=""

    # A) Buscar si hay un VirtualHost en /etc/apache2/sites-available/ que apunte a una IP 172.x.x.x para este proyecto
    for candidate in "${APACHE_SITES_AVAIL}/${ddev_name}"*.conf "${APACHE_SITES_AVAIL}/${proj_dir_name}"*.conf; do
        [ -f "$candidate" ] || continue
        vhost_ip=$(grep -E "ProxyPass\s+/" "$candidate" 2>/dev/null | grep -oE '172\.[0-9]+\.[0-9]+\.[0-9]+' | head -n1 || true)
        if [ -n "$vhost_ip" ]; then
            assigned_ip="$vhost_ip"
            break
        fi
    done

    # B) Si el contenedor está corriendo actualmente, conservar su IP actual en ddev_default
    if [ -z "$assigned_ip" ] && docker ps --format '{{.Names}}' | grep -qx "$container_name"; then
        assigned_ip=$(docker inspect -f '{{with index .NetworkSettings.Networks "ddev_default"}}{{.IPAddress}}{{end}}' "$container_name" 2>/dev/null || true)
    fi

    # C) Revisar si ya tiene docker-compose.static-ip.yaml con el prefijo correcto
    if [ -z "$assigned_ip" ] && [ -f "$proj_path/.ddev/docker-compose.static-ip.yaml" ]; then
        cfg_ip=$(grep -E 'ipv4_address:' "$proj_path/.ddev/docker-compose.static-ip.yaml" | awk '{print $2}' | tr -d '"'\''' || true)
        if [[ "$cfg_ip" == "${SUBNET_PREFIX}."* ]]; then
            assigned_ip="$cfg_ip"
        fi
    fi

    # D) Si es andara/andarasalon, usar .20 por defecto (si está libre)
    if [ -z "$assigned_ip" ] && [ "$ddev_name" = "andara" ]; then
        if ! printf '%s\n' "${PROJ_IPS[@]:-}" | grep -qx "${SUBNET_PREFIX}.20"; then
            assigned_ip="${SUBNET_PREFIX}.20"
        fi
    fi

    # E) Si sigue sin IP, asignar el siguiente octeto libre
    if [ -z "$assigned_ip" ]; then
        while printf '%s\n' "${PROJ_IPS[@]:-}" | grep -qx "${SUBNET_PREFIX}.${NEXT_OCTET}" || [ "$NEXT_OCTET" -eq 20 ]; do
            NEXT_OCTET=$((NEXT_OCTET + 1))
        done
        assigned_ip="${SUBNET_PREFIX}.${NEXT_OCTET}"
        NEXT_OCTET=$((NEXT_OCTET + 1))
    fi

    PROJ_IPS["$proj_path"]="$assigned_ip"
    echo " -> Proyecto [$ddev_name] ($proj_dir_name): IP interna fijada en ${assigned_ip}"

    cat > "$proj_path/.ddev/docker-compose.static-ip.yaml" <<EOF
services:
  web:
    networks:
      ddev_default:
        ipv4_address: ${assigned_ip}
EOF
    chown developer:developer "$proj_path/.ddev/docker-compose.static-ip.yaml"

    # Si existe un VirtualHost para este proyecto con una IP 172.x.x.x distinta, actualizarla a su IP fija
    for candidate in "${APACHE_SITES_AVAIL}/${ddev_name}"*.conf "${APACHE_SITES_AVAIL}/${proj_dir_name}"*.conf; do
        [ -f "$candidate" ] || continue
        if grep -qE 'http://172\.[0-9]+\.[0-9]+\.[0-9]+' "$candidate"; then
            sed -i -E "s|http://172\.[0-9]+\.[0-9]+\.[0-9]+|http://${assigned_ip}|g" "$candidate"
            echo "    (Sincronizado VirtualHost $(basename "$candidate") -> http://${assigned_ip})"
        fi
    done
done

echo "=== [4/6] Verificando que ddev_default permita asignación estática de IPs ==="
if ! docker run --rm --network ddev_default --ip "${SUBNET_PREFIX}.250" alpine:latest true >/dev/null 2>&1; then
    echo "Recreando red ddev_default con --subnet=${SUBNET} explícito para permitir IPs fijas..."
    su - developer -c "ddev poweroff" || true
    docker network rm ddev_default >/dev/null 2>&1 || true
    docker network create --driver bridge --subnet="${SUBNET}" --gateway="${GATEWAY}" --label com.ddev.platform=ddev ddev_default
fi

echo "=== [5/6] Levantando todos los entornos DDEV con sus IPs fijas ==="
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

echo "=== [6/6] Creando y habilitando VirtualHost Apache para andarasoft.com ==="
cat > "${APACHE_SITES_AVAIL}/andarasoft.com.conf" <<EOF
<VirtualHost *:80>
    ServerName andarasoft.com
    ServerAlias www.andarasoft.com

    ProxyPreserveHost On
    ProxyRequests Off
    RequestHeader set X-Forwarded-Proto "http"
    RequestHeader set X-Forwarded-Port "80"

    ProxyPass / http://${ANDARA_IP}:80/
    ProxyPassReverse / http://${ANDARA_IP}:80/

    ErrorLog \${APACHE_LOG_DIR}/andarasoft.com-error.log
    CustomLog \${APACHE_LOG_DIR}/andarasoft.com-access.log combined
</VirtualHost>
EOF

# Comprobar si existe certificado SSL en Let's Encrypt o en 000-default-le-ssl.conf
SSL_CERT=""
SSL_KEY=""
if [ -f "/etc/letsencrypt/live/andarasoft.com/fullchain.pem" ]; then
    SSL_CERT="/etc/letsencrypt/live/andarasoft.com/fullchain.pem"
    SSL_KEY="/etc/letsencrypt/live/andarasoft.com/privkey.pem"
elif [ -f "${APACHE_SITES_AVAIL}/000-default-le-ssl.conf" ]; then
    SSL_CERT=$(grep -E "^\s*SSLCertificateFile" "${APACHE_SITES_AVAIL}/000-default-le-ssl.conf" | awk '{print $2}' | head -n1 || true)
    SSL_KEY=$(grep -E "^\s*SSLCertificateKeyFile" "${APACHE_SITES_AVAIL}/000-default-le-ssl.conf" | awk '{print $2}' | head -n1 || true)
fi

if [ -n "$SSL_CERT" ] && [ -f "$SSL_CERT" ]; then
    cat > "${APACHE_SITES_AVAIL}/andarasoft.com-le-ssl.conf" <<EOF
<IfModule mod_ssl.c>
<VirtualHost *:443>
    ServerName andarasoft.com
    ServerAlias www.andarasoft.com

    ProxyPreserveHost On
    ProxyRequests Off
    RequestHeader set X-Forwarded-Proto "https"
    RequestHeader set X-Forwarded-Port "443"

    ProxyPass / http://${ANDARA_IP}:80/
    ProxyPassReverse / http://${ANDARA_IP}:80/

    ErrorLog \${APACHE_LOG_DIR}/andarasoft.com-ssl-error.log
    CustomLog \${APACHE_LOG_DIR}/andarasoft.com-ssl-access.log combined

    SSLEngine on
    SSLCertificateFile ${SSL_CERT}
    SSLCertificateKeyFile ${SSL_KEY}
    Include /etc/letsencrypt/options-ssl-apache.conf
</VirtualHost>
</IfModule>
EOF
    a2ensite andarasoft.com-le-ssl.conf >/dev/null 2>&1 || true
fi

a2ensite andarasoft.com.conf >/dev/null 2>&1 || true
apache2ctl configtest
systemctl reload apache2

echo "=== [Extra] Configurando auto-despliegue continuo (/etc/cron.d/andara-autodeploy) ==="
cat > /etc/cron.d/andara-autodeploy <<'EOF'
# Auto-sync de Andara desde GitHub (origin/main) cada minuto
* * * * * developer cd /home/developer/Projects/andarasalon && git fetch origin main >/dev/null 2>&1 && [ "$(git rev-parse HEAD)" != "$(git rev-parse origin/main)" ] && git pull origin main >/dev/null 2>&1
EOF
chmod 644 /etc/cron.d/andara-autodeploy

echo ""
echo "=== ¡VirtualHost creado y activado! Archivos en /etc/apache2/sites-available: ==="
ls -lah "${APACHE_SITES_AVAIL}"/*andara*
echo ""
echo "=== Resumen de Contenedores DDEV e IPs Fijas en ddev_default ==="
for c in $(docker ps --format '{{.Names}}' | grep '^ddev-.*-web$'); do
    cip=$(docker inspect -f '{{with index .NetworkSettings.Networks "ddev_default"}}{{.IPAddress}}{{end}}' "$c" 2>/dev/null || true)
    cports=$(docker port "$c" 80/tcp 2>/dev/null | tr '\n' ' ' || true)
    echo " - $c => IP interna fija: $cip | Puerto Host: $cports"
done
