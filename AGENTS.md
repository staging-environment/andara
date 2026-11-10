# Contexto del Proyecto: Andara Soft (`andara`)

Este documento recoge la configuración del entorno, arquitectura, accesos de producción y flujo de despliegue del portal web comercial **Andara Soft** (`https://andarasoft.com`), vinculado a la plataforma SaaS de gestión para peluquerías, barberías y centros de estética **Andara Salón** (`https://andarasalon.com`).

---

## 📌 Datos de Entornos

### 🚀 Entorno de Producción
- **Dominio Web:** `https://andarasoft.com` (`www.andarasoft.com`)
- **Dirección IP:** `75.119.136.151`
- **Usuario SSH:** `root`
- **Comando de Acceso SSH:** `ssh root@75.119.136.151`
- **Ruta del Proyecto en Producción:** `/home/developer/Projects/andarasalon/public_html`
- **Arquitectura en Producción (Proxy Inverso Apache + DDEV):**
  - **Proxy Inverso Host:** `Apache/2.4.58 (Ubuntu)` (`/etc/apache2/sites-available/andarasoft.com.conf` y `andarasoft.com-le-ssl.conf`)
  - **Contenedor Web DDEV:** `ddev-andara-web`
  - **Puerto Host Fijo (`host_webserver_port`):** `127.0.0.1:8084`
  - **IP Interna Fija Docker (`ddev_default`):** `172.18.0.20` (definida en [`.ddev/docker-compose.static-ip.yaml`](file:///home/antigravity/staging-environment/andara/.ddev/docker-compose.static-ip.yaml))
  - **Puertos Router DDEV:** `33002` (HTTP) / `33003` (HTTPS)
  - **Script de aprovisionamiento y fijación de IPs de todos los proyectos:** [`scripts/setup_production_ddev_and_vhosts.sh`](file:///home/antigravity/staging-environment/andara/scripts/setup_production_ddev_and_vhosts.sh)
- **Plataforma SaaS Vinculada (`SUX_SALON`):** `https://andarasalon.com` (`161.97.107.80` - Nginx / Laravel)
  - Registro de negocios: `https://andarasalon.com/registrar-negocio`
  - Inicio de sesión: `https://andarasalon.com/login`

### 💻 Entorno Local (Desarrollo) y Cloud Agent (`☁️`)
- **Ruta en Agente Cloud (`☁️`):** `/home/antigravity/staging-environment/andara`
- **Ruta Local en WSL / Escritorio:** `/home/developer/Projects/andara` (o `/home/bonilla/Projects/andara`)
- **Virtualización Local:** DDEV ([`.ddev/config.yaml`](file:///home/antigravity/staging-environment/andara/.ddev/config.yaml))
  - **Nombre del proyecto:** `andara`
  - **URL Local:** `https://andara.ddev.site`
  - **PHP:** `8.3` (`webserver_type: apache-fpm`)
  - **Base de datos configurada en DDEV:** `mariadb:10.11`
  - **Puerto Web Host Fijo:** `8084` (`host_webserver_port: "8084"`)
  - **IP Estática en `ddev_default`:** `172.18.0.20` ([`.ddev/docker-compose.static-ip.yaml`](file:///home/antigravity/staging-environment/andara/.ddev/docker-compose.static-ip.yaml))
  - **Gestor de dependencias:** Composer v2 (`phpmailer/phpmailer: ^6.10`)

---

## 📁 Arquitectura y Estructura del Repositorio

Aplicación web en **PHP nativo** con controlador frontal ligero y maquetación basada en **Bootstrap 5.0.2**, **Font Awesome 6.7.2** y hojas de estilo personalizadas:

- [`index.php`](file:///home/antigravity/staging-environment/andara/index.php): Enrutador frontal que procesa `$_SERVER['REQUEST_URI']`, carga `includes/variables_configuracion.php` y resuelve las vistas:
  - `/` (por defecto) ➔ [`home.php`](file:///home/antigravity/staging-environment/andara/home.php)
  - `/precios` ➔ [`precios.php`](file:///home/antigravity/staging-environment/andara/precios.php)
  - `/porque-andara` ➔ [`porque-andara.php`](file:///home/antigravity/staging-environment/andara/porque-andara.php)
  - `/quienes-somos` ➔ [`quienes-somos.php`](file:///home/antigravity/staging-environment/andara/quienes-somos.php)
  - `/contacto` ➔ [`contacto.php`](file:///home/antigravity/staging-environment/andara/contacto.php)
  - `/productos` ➔ [`productos.php`](file:///home/antigravity/staging-environment/andara/productos.php)
- [`.htaccess`](file:///home/antigravity/staging-environment/andara/.htaccess): Reglas `RewriteEngine On` que redirigen cualquier ruta no estática a `index.php`.
- [`cabecera.php`](file:///home/antigravity/staging-environment/andara/cabecera.php): Barra de navegación común (`navbar`).
- [`includes/variables_configuracion.php`](file:///home/antigravity/staging-environment/andara/includes/variables_configuracion.php):
  - Define la constante `SUX_SALON` (`https://andarasalon.com`).
  - Configura las credenciales SMTP (`smtp.gmail.com:587`, remitente `andaratechnology@gmail.com`, destinatario `jarodriguezbonilla@gmail.com`).
- [`process-contact.php`](file:///home/antigravity/staging-environment/andara/process-contact.php): Endpoint `POST` que envía los mensajes del formulario de contacto mediante `PHPMailer` y devuelve respuesta en JSON (`{ "success": true }`).
- [`css/estilos.css`](file:///home/antigravity/staging-environment/andara/css/estilos.css) y [`css/mediaquer.css`](file:///home/antigravity/staging-environment/andara/css/mediaquer.css): Estilos globales, variables de color (`--rojo`, `--amarillo`, `--verde`, `--gris`, `--rosa`) y diseño responsive.
- [`js/app.js`](file:///home/antigravity/staging-environment/andara/js/app.js): Control de carrusel, pestañas (`tabs`), notificaciones flotantes y envío asíncrono (`fetch`) del formulario `#contactForm`.

---

## 🔗 Repositorio Git
- **URL HTTPS:** `https://github.com/staging-environment/andara`
- **URL SSH:** `git@github.com:staging-environment/andara.git`
- **Rama Principal:** `main`

---

## 🚀 Flujo de Trabajo Git y Despliegue en Producción

Cada vez que se realice y verifique un cambio en el repositorio:

1. **Commit y Push a GitHub (`main`):**
   ```bash
   git add <archivos>
   git commit -m "feat/fix: descripción clara del cambio"
   git push origin main
   ```
2. **Despliegue en el Servidor de Producción (`75.119.136.151`):**
   - Ruta en producción de `andara` (`andarasoft.com`): `/home/developer/Projects/andara` (o donde resida `porque-andara.php`; nota: `/home/developer/Projects/andarasalon/public_html` contiene la app Laravel de `andarasalon.com`).
   - Comando de despliegue por SSH desde el entorno local:
     ```bash
     ssh root@75.119.136.151 "cd /home/developer/Projects/andara && git pull origin main"
     ```

---

## 🔄 Estado Actual e Hilo de Conversación (Continuación en Local)

Al abrir este proyecto desde el **Agente Local (WSL / Escritorio)** y pedir continuar:
1. **Contexto de lo ya preparado en el repositorio (`origin/main`):**
   - Se ha configurado [`.ddev/config.yaml`](file:///home/antigravity/staging-environment/andara/.ddev/config.yaml) con `router_http_port: "33002"`, `router_https_port: "33003"`, `host_webserver_port: "8084"`, `additional_fqdns: [andarasoft.com, www.andarasoft.com]` y `disable_settings_management: true`.
   - Se ha creado [`.ddev/docker-compose.static-ip.yaml`](file:///home/antigravity/staging-environment/andara/.ddev/docker-compose.static-ip.yaml) fijando la IP interna `172.18.0.20` en la red `ddev_default`.
   - Se ha creado el script automatizado [`scripts/setup_production_ddev_and_vhosts.sh`](file:///home/antigravity/staging-environment/andara/scripts/setup_production_ddev_and_vhosts.sh).
2. **Acción inmediata a ejecutar por SSH desde Local (`ssh root@75.119.136.151`):**
   - Conectar por SSH a `root@75.119.136.151` (`vmi2545399`).
   - Verificar dónde están los proyectos en `/home/developer/Projects/` (`barriosdesevilla.es`, `goinvesting.es`, `pinomontano.es`, `sevilla-este.es`, `tukigocloud`, `andarasalon`, `andara`).
   - Asegurar que **todos los proyectos DDEV** en `/home/developer/Projects/*` tengan su IP interna fijada a fuego en `.ddev/docker-compose.static-ip.yaml` (en la red `ddev_default`) coincidiendo con las IPs de `/etc/apache2/sites-available/*.conf`, para que al reiniciar Docker nunca cambien las IPs ni fallen las redirecciones del proxy inverso Apache.
   - Clonar/actualizar `https://github.com/staging-environment/andara.git` en producción, levantar su entorno DDEV (`ddev start`) y crear/activar el VirtualHost de Apache `/etc/apache2/sites-available/andarasoft.com.conf` (y `andarasoft.com-le-ssl.conf`) apuntando al contenedor DDEV de Andara.
