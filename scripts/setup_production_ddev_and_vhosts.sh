#!/usr/bin/env bash
# ==============================================================================
# Script de Configuración en Producción (vmi2545399 - 75.119.136.151):
# 1. Detecta dónde está alojado andarasoft.com (o lo clona en
#    /home/developer/Projects/andara si no existe aún en Projects).
# 2. Asegura que la red Docker ddev_default tenga subred IPAM explícita para
#    permitir IPs estáticas (ipv4_address) a fuego en los contenedores.
# 3. Fija las IPs internas de Docker (.ddev/docker-compose.static-ip.yaml) en
#    todos los proyectos DDEV de /home/developer/Projects/* y sincroniza los
#    VirtualHosts de /etc/apache2/sites-available/*.conf.
# 4. Levanta DDEV en Andara y en todos los contenedores activos.
# 5. Crea y activa el VirtualHost de proxy inverso en Apache para andarasoft.com
#    (andarasoft.com.conf y andarasoft.com-le-ssl.conf).
# ==============================================================================
set -euo pipefail

PROJECTS_DIR="/home/developer/Projects"
APACHE_SITES_AVAIL="/etc/apache2/sites-available"

echo "=== [0/6] Configurando safe.directory en Git y localizando proyecto Andara ==="
git config --global --add safe.directory '*' || true
su - developer -c "git config --global --add safe.directory '*'" || true

# Buscar si ya existe el repositorio de andara (andarasoft.com)
FOUND_ANDARA=$(find /home/developer/Projects -maxdepth 3 -name "porque-andara.php" 2>/dev/null | head -n1 || true)
if [ -n "$FOUND_ANDARA" ]; then
    ANDARA_DIR=$(dirname "$FOUND_ANDARA")
    echo " -> Encontrado proyecto Andara existente en: ${ANDARA_DIR}"
else
    ANDARA_DIR="/home/developer/Projects/andara"
    echo " -> Clonando https://github.com/staging-environment/andara.git en ${ANDARA_DIR}..."
    if [ ! -d "$ANDARA_DIR/.git" ]; then
        su - developer -c "git clone https://github.com/staging-environment/andara.git '$ANDARA_DIR'"
    fi
fi

chown -R developer:developer "$ANDARA_DIR"
su - developer -c "cd '$ANDARA_DIR' && git remote set-url origin https://github.com/staging-environment/andara.git && git pull origin main" || true

echo "=== [1/6] Habilitando módulos de Proxy Inverso y SSL en Apache ==="
a2enmod proxy proxy_http headers rewrite ssl >/dev/null 2>&1 || true

echo "=== [2/6] Verificando red Docker ddev_default ==="
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
echo " -> Red ddev_default: Subred=${SUBNET}, Gateway=${GATEWAY}"

# Guardar qué proyectos DDEV estaban corriendo actualmente antes de tocar la red
mapfile -t RUNNING_WEB_CONTAINERS < <(docker ps --format '{{.Names}}' | grep '^ddev-.*-web$' || true)
echo " -> Contenedores web DDEV activos actualmente: ${RUNNING_WEB_CONTAINERS[*]:-ninguno}"

echo "=== [3/6] Fijando IPs internas a fuego en todos los proyectos DDEV ==="
declare -A PROJ_IPS
declare -A PROJ_SHOULD_START
NEXT_OCTET=10

mapfile -t DDEV_DIRS < <(find "$PROJECTS_DIR" -maxdepth 3 -type d -name ".ddev" | sort)

for ddev_dir in "${DDEV_DIRS[@]}"; do
    proj_path=$(dirname "$ddev_dir")
    [ -f "$proj_path/.ddev/config.yaml" ] || continue
    proj_dir_name=$(basename "$proj_path")
    parent_dir_name=$(basename "$(dirname "$proj_path")")
    ddev_name=$(grep -E '^name:' "$proj_path/.ddev/config.yaml" | awk '{print $2}' | tr -d '"'\''' || true)
    [ -n "$ddev_name" ] || continue

    container_name="ddev-${ddev_name}-web"
    assigned_ip=""

    # Marcar si estaba corriendo o si es andara
    if printf '%s\n' "${RUNNING_WEB_CONTAINERS[@]:-}" | grep -qx "$container_name" || [ "$proj_path" = "$ANDARA_DIR" ]; then
        PROJ_SHOULD_START["$proj_path"]=1
    fi

    # A) Si el contenedor está corriendo actualmente, conservar su IP actual en ddev_default
    if docker ps --format '{{.Names}}' | grep -qx "$container_name"; then
        assigned_ip=$(docker inspect -f '{{with index .NetworkSettings.Networks "ddev_default"}}{{.IPAddress}}{{end}}' "$container_name" 2>/dev/null || true)
    fi

    # B) Buscar si hay un VirtualHost en /etc/apache2/sites-available/ que apunte a una IP 172.x.x.x para este proyecto
    if [ -z "$assigned_ip" ]; then
        for candidate in "${APACHE_SITES_AVAIL}/${ddev_name}"*.conf "${APACHE_SITES_AVAIL}/${proj_dir_name}"*.conf "${APACHE_SITES_AVAIL}/${parent_dir_name}"*.conf; do
            [ -f "$candidate" ] || continue
            vhost_ip=$(grep -E "ProxyPass\s+/" "$candidate" 2>/dev/null | grep -oE '172\.[0-9]+\.[0-9]+\.[0-9]+' | head -n1 || true)
            if [ -n "$vhost_ip" ]; then
                assigned_ip="$vhost_ip"
                break
            fi
        done
    fi

    # C) Revisar si ya tiene docker-compose.static-ip.yaml con el prefijo correcto
    if [ -z "$assigned_ip" ] && [ -f "$proj_path/.ddev/docker-compose.static-ip.yaml" ]; then
        cfg_ip=$(grep -E 'ipv4_address:' "$proj_path/.ddev/docker-compose.static-ip.yaml" | awk '{print $2}' | tr -d '"'\''' || true)
        if [[ "$cfg_ip" == "${SUBNET_PREFIX}."* ]]; then
            assigned_ip="$cfg_ip"
        fi
    fi

    # D) Si es andara, usar .20 por defecto (si está libre)
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
    echo " -> Proyecto [$ddev_name] ($proj_path): IP interna fijada en ${assigned_ip}"

    cat > "$proj_path/.ddev/docker-compose.static-ip.yaml" <<EOF
services:
  web:
    networks:
      ddev_default:
        ipv4_address: ${assigned_ip}
EOF
    chown developer:developer "$proj_path/.ddev/docker-compose.static-ip.yaml"

    # Si existe un VirtualHost para este proyecto con una IP 172.x.x.x distinta, sincronizarla a su IP fija
    for candidate in "${APACHE_SITES_AVAIL}/${ddev_name}"*.conf "${APACHE_SITES_AVAIL}/${proj_dir_name}"*.conf "${APACHE_SITES_AVAIL}/${parent_dir_name}"*.conf; do
        [ -f "$candidate" ] || continue
        if grep -qE 'http://172\.[0-9]+\.[0-9]+\.[0-9]+' "$candidate"; then
            sed -i -E "s|http://172\.[0-9]+\.[0-9]+\.[0-9]+|http://${assigned_ip}|g" "$candidate"
            echo "    (Sincronizado VirtualHost $(basename "$candidate") -> http://${assigned_ip})"
        fi
    done
done

echo "=== [4/6] Asegurando soporte IPAM de usuario en ddev_default ==="
ANY_IMAGE=$(docker images --format '{{.Repository}}:{{.Tag}}' | grep -v '<none>' | head -n1 || echo "busybox:latest")
if ! docker run --rm --network ddev_default --ip "${SUBNET_PREFIX}.250" "$ANY_IMAGE" true >/dev/null 2>&1; then
    echo " -> Recreando red ddev_default con --subnet=${SUBNET} explícito para permitir IPs fijas..."
    su - developer -c "ddev poweroff" || true
    docker network rm ddev_default >/dev/null 2>&1 || true
    docker network create --driver bridge --subnet="${SUBNET}" --gateway="${GATEWAY}" --label com.ddev.platform=ddev ddev_default
fi

echo "=== [5/6] Levantando proyectos DDEV activos + Andara con sus IPs fijas ==="
ANDARA_IP="${PROJ_IPS[$ANDARA_DIR]:-${SUBNET_PREFIX}.20}"
for proj_path in "${!PROJ_SHOULD_START[@]}"; do
    echo " -> Arrancando DDEV en $proj_path (IP fija: ${PROJ_IPS[$proj_path]})..."
    su - developer -c "cd '$proj_path' && ddev start" || echo "    [Aviso] Revisa $proj_path manualmente si requiere configuración extra."
done

# Verificar IP real y puerto de ddev-andara-web
ACTUAL_ANDARA_IP=$(docker inspect -f '{{with index .NetworkSettings.Networks "ddev_default"}}{{.IPAddress}}{{end}}' ddev-andara-web 2>/dev/null || echo "$ANDARA_IP")
echo " -> Contenedor ddev-andara-web activo en IP fija: ${ACTUAL_ANDARA_IP} y puerto 127.0.0.1:8084"

echo "=== [6/6] Creando y habilitando VirtualHost Apache para andarasoft.com ==="
cat > "${APACHE_SITES_AVAIL}/andarasoft.com.conf" <<EOF
<VirtualHost *:80>
    ServerName andarasoft.com
    ServerAlias www.andarasoft.com

    ProxyPreserveHost On
    ProxyRequests Off
    RequestHeader set X-Forwarded-Proto "http"
    RequestHeader set X-Forwarded-Port "80"

    ProxyPass / http://${ACTUAL_ANDARA_IP}:80/
    ProxyPassReverse / http://${ACTUAL_ANDARA_IP}:80/

    ErrorLog \${APACHE_LOG_DIR}/andarasoft.com-error.log
    CustomLog \${APACHE_LOG_DIR}/andarasoft.com-access.log combined
</VirtualHost>
EOF

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

    ProxyPass / http://${ACTUAL_ANDARA_IP}:80/
    ProxyPassReverse / http://${ACTUAL_ANDARA_IP}:80/

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
cat > /etc/cron.d/andara-autodeploy <<EOF
# Auto-sync de Andara desde GitHub (origin/main) cada minuto
* * * * * developer cd ${ANDARA_DIR} && git fetch origin main >/dev/null 2>&1 && [ "\$(git rev-parse HEAD)" != "\$(git rev-parse origin/main)" ] && git pull origin main >/dev/null 2>&1
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
