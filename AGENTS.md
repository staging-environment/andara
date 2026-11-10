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
   - Ruta en producción: `/home/developer/Projects/andarasalon/public_html`
   - Comando de despliegue por SSH:
     ```bash
     ssh root@75.119.136.151 "cd /home/developer/Projects/andarasalon/public_html && git pull origin main"
     ```
   - *Nota sobre el entorno de ejecución:* Desde el entorno **Local / Escritorio (WSL)** se dispone de conexión SSH directa con claves locales hacia `root@75.119.136.151`. Desde el **Agente Cloud (`☁️`)**, el proxy del sandbox (`agy-plugin-proxy`) solo permite tráfico HTTP/HTTPS saliente y bloquea conexiones TCP crudas al puerto `22` (`SSH`), pero sí permite verificar el estado HTTP/HTTPS público de `https://andarasoft.com` (`75.119.136.151`) y hacer `git push origin main`.
