#!/usr/bin/env bash
# ==============================================================================
# Script de Configuración en Producción (vmi2545399 - 75.119.136.151):
# 1. Detecta o clona el proyecto Andara en /home/developer/Projects/andara.
# 2. Asegura que la red Docker ddev_default tenga subred IPAM explícita
#    (172.18.0.0/16) para permitir IPs estáticas (ipv4_address).
# 3. Fija las IPs internas de Docker (.ddev/docker-compose.static-ip.yaml) en
#    rango alto (.20-.29 para web y .30-.39 para db) en todos los proyectos DDEV
#    de /home/developer/Projects/* para evitar colisiones con el IPAM dinámico,
#    sincroniza certificados TLS de Traefik y actualiza VirtualHosts si usan IP.
# 4. Levanta DDEV en todos los proyectos activos + Andara.
# 5. Crea y activa el VirtualHost de proxy inverso en Apache para andarasoft.com
#    (andarasoft.com.conf y andarasoft.com-le-ssl.conf) y desactiva el antiguo
#    000-default-le-ssl.conf que apuntaba a /var/www/html.
# ==============================================================================
set -euo pipefail

PROJECTS_DIR="/home/developer/Projects"
APACHE_SITES_AVAIL="/etc/apache2/sites-available"
ANDARA_DIR="/home/developer/Projects/andara"

echo "=== [0/6] Configurando safe.directory en Git y actualizando proyecto Andara ==="
git config --global --add safe.directory '*' || true
su - developer -c "git config --global --add safe.directory '*'" || true

if [ ! -d "$ANDARA_DIR/.git" ]; then
    echo " -> Clonando https://github.com/staging-environment/andara.git en ${ANDARA_DIR}..."
    su - developer -c "git clone https://github.com/staging-environment/andara.git '$ANDARA_DIR'"
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

echo "=== [3/6] Fijando IPs internas (.20-.29 web / .30-.39 db) y certificados Traefik ==="
declare -A PROJ_WEB_IPS
declare -A PROJ_DB_IPS
declare -A PROJ_SHOULD_START
NEXT_OFFSET=1

mapfile -t DDEV_DIRS < <(find "$PROJECTS_DIR" -maxdepth 2 -type d -name ".ddev" | sort)

for ddev_dir in "${DDEV_DIRS[@]}"; do
    proj_path=$(dirname "$ddev_dir")
    [ -f "$proj_path/.ddev/config.yaml" ] || continue
    proj_dir_name=$(basename "$proj_path")
    ddev_name=$(grep -E '^name:' "$proj_path/.ddev/config.yaml" | awk '{print $2}' | tr -d '"'\''' || true)
    [ -n "$ddev_name" ] || continue

    if [ "$ddev_name" = "andara" ]; then
        web_ip="${SUBNET_PREFIX}.20"
        db_ip="${SUBNET_PREFIX}.30"
    else
        web_ip="${SUBNET_PREFIX}.$((20 + NEXT_OFFSET))"
        db_ip="${SUBNET_PREFIX}.$((30 + NEXT_OFFSET))"
        NEXT_OFFSET=$((NEXT_OFFSET + 1))
    fi

    PROJ_WEB_IPS["$proj_path"]="$web_ip"
    PROJ_DB_IPS["$proj_path"]="$db_ip"

    # Proyectos que deben estar levantados en producción
    case "$ddev_name" in
        andara|goinvesting|pinomontano|sevilla-este)
            PROJ_SHOULD_START["$proj_path"]=1
            ;;
        *)
            if docker ps --format '{{.Names}}' | grep -qx "ddev-${ddev_name}-web"; then
                PROJ_SHOULD_START["$proj_path"]=1
            fi
            ;;
    esac

    echo " -> Proyecto [$ddev_name] ($proj_path): WEB=${web_ip}, DB=${db_ip}"

    cat > "$proj_path/.ddev/docker-compose.static-ip.yaml" <<EOF
services:
  web:
    networks:
      ddev_default:
        ipv4_address: ${web_ip}
  db:
    networks:
      ddev_default:
        ipv4_address: ${db_ip}
EOF
    chown developer:developer "$proj_path/.ddev/docker-compose.static-ip.yaml"

    # Asegurar que exista certificado TLS válido en .ddev/traefik/certs para que ddev-router no falle
    mkdir -p "$proj_path/.ddev/traefik/certs"
    crt_file="$proj_path/.ddev/traefik/certs/${ddev_name}.crt"
    key_file="$proj_path/.ddev/traefik/certs/${ddev_name}.key"
    if [ ! -s "$crt_file" ] || [ ! -s "$key_file" ]; then
        openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
            -keyout "$key_file" \
            -out "$crt_file" \
            -subj "/CN=${ddev_name}.ddev.site" >/dev/null 2>&1
        chown -R developer:developer "$proj_path/.ddev/traefik"
        echo "    (Generado certificado TLS interno para Traefik: ${ddev_name}.crt)"
    fi

    # Si algún VirtualHost en Apache usa IP directa 172.x.x.x para este proyecto, sincronizarla
    for candidate in "${APACHE_SITES_AVAIL}/${ddev_name}"*.conf "${APACHE_SITES_AVAIL}/${proj_dir_name}"*.conf; do
        [ -f "$candidate" ] || continue
        if grep -qE 'http://172\.[0-9]+\.[0-9]+\.[0-9]+' "$candidate"; then
            sed -i -E "s|http://172\.[0-9]+\.[0-9]+\.[0-9]+|http://${web_ip}|g" "$candidate"
            echo "    (Sincronizado VirtualHost $(basename "$candidate") -> http://${web_ip})"
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

echo "=== [5/6] Reiniciando proyectos DDEV activos con sus IPs fijas ==="
for proj_path in $(printf '%s\n' "${!PROJ_SHOULD_START[@]}" | sort); do
    echo " -> Levantando DDEV en $proj_path (WEB: ${PROJ_WEB_IPS[$proj_path]}, DB: ${PROJ_DB_IPS[$proj_path]})..."
    su - developer -c "cd '$proj_path' && ddev restart" || su - developer -c "cd '$proj_path' && ddev start"
done

ANDARA_IP="${PROJ_WEB_IPS[$ANDARA_DIR]:-${SUBNET_PREFIX}.20}"
ACTUAL_ANDARA_IP=$(docker inspect -f '{{with index .NetworkSettings.Networks "ddev_default"}}{{.IPAddress}}{{end}}' ddev-andara-web 2>/dev/null || echo "$ANDARA_IP")
echo " -> Contenedor ddev-andara-web activo en IP fija: ${ACTUAL_ANDARA_IP} y puerto 127.0.0.1:8084"

echo "=== [6/6] Creando y habilitando VirtualHost Apache para andarasoft.com ==="
cat > "${APACHE_SITES_AVAIL}/andarasoft.com.conf" <<EOF
<VirtualHost *:80>
    ServerName andarasoft.com
    ServerAlias www.andarasoft.com andarasoft.es www.andarasoft.es

    ProxyPreserveHost On
    ProxyRequests Off
    RequestHeader set X-Forwarded-Proto "http"
    RequestHeader set X-Forwarded-Port "80"

    ProxyPass / http://${ACTUAL_ANDARA_IP}:80/
    ProxyPassReverse / http://${ACTUAL_ANDARA_IP}:80/

    ErrorLog \${APACHE_LOG_DIR}/andarasoft.com-error.log
    CustomLog \${APACHE_LOG_DIR}/andarasoft.com-access.log combined

    RewriteEngine on
    RewriteCond %{SERVER_NAME} =andarasoft.com [OR]
    RewriteCond %{SERVER_NAME} =www.andarasoft.com [OR]
    RewriteCond %{SERVER_NAME} =andarasoft.es [OR]
    RewriteCond %{SERVER_NAME} =www.andarasoft.es
    RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]
</VirtualHost>
EOF

SSL_CERT="/etc/letsencrypt/live/andarasoft.com/fullchain.pem"
SSL_KEY="/etc/letsencrypt/live/andarasoft.com/privkey.pem"

if [ -f "$SSL_CERT" ]; then
    cat > "${APACHE_SITES_AVAIL}/andarasoft.com-le-ssl.conf" <<EOF
<IfModule mod_ssl.c>
<VirtualHost *:443>
    ServerName andarasoft.com
    ServerAlias www.andarasoft.com andarasoft.es www.andarasoft.es

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

# Desactivar 000-default-le-ssl.conf para que no intercepte andarasoft.com hacia /var/www/html
a2dissite 000-default-le-ssl.conf >/dev/null 2>&1 || true
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
for c in $(docker ps --format '{{.Names}}' | grep '^ddev-.*' | sort); do
    cip=$(docker inspect -f '{{with index .NetworkSettings.Networks "ddev_default"}}{{.IPAddress}}{{end}}' "$c" 2>/dev/null || true)
    cports=$(docker port "$c" 80/tcp 2>/dev/null | tr '\n' ' ' || true)
    echo " - $c => IP interna: $cip | Puerto Host 80: ${cports:-N/A}"
done
