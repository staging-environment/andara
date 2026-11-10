# Workspace Rules & Context: Andara Soft (`andara`)

## 📌 Entorno de Producción y Accesos
- **Proyecto:** Andara Soft (`staging-environment/andara`)
- **Dominio de Producción:** `https://andarasoft.com`
- **Servidor de Producción (IP):** `75.119.136.151`
- **Usuario SSH:** `root` (`ssh root@75.119.136.151`)
- **Ruta en Producción:** `/home/developer/Projects/andarasalon/public_html`
- **Servidor Web:** `Apache/2.4.58 (Ubuntu)`
- **Plataforma SaaS Vinculada (`SUX_SALON`):** `https://andarasalon.com` (`161.97.107.80`)

## 🛠️ Arquitectura del Proyecto
- Enrutador frontal en `index.php` apoyado en `.htaccess` (`RewriteRule . index.php [L]`).
- Configuración centralizada de correo SMTP (`PHPMailer`) y constante `SUX_SALON` en `includes/variables_configuracion.php`.
- Envío asíncrono del formulario de contacto mediante `js/app.js` hacia `process-contact.php`.

## 🚀 Flujo Git y Despliegue (REGLA OBLIGATORIA)
1. Realizar los cambios, añadir y commitear en la rama **`main`**:
   ```bash
   git add <archivos>
   git commit -m "feat/fix: descripción del cambio"
   git push origin main
   ```
2. Desplegar en el servidor de producción (`root@75.119.136.151`):
   ```bash
   ssh root@75.119.136.151 "cd /home/developer/Projects/andara && git pull origin main"
   ```

## 🔄 Continuación Inmediata al Abrir en Local (WSL)
Si el usuario indica continuar con la configuración en producción:
1. Ejecutar por SSH en `root@75.119.136.151`:
   `ssh root@75.119.136.151 "curl -fsSL https://raw.githubusercontent.com/staging-environment/andara/main/scripts/setup_production_ddev_and_vhosts.sh | bash"`
2. Verificar en `root@75.119.136.151`:
   - Que todos los proyectos DDEV en `/home/developer/Projects/*` tengan su IP interna fija en `.ddev/docker-compose.static-ip.yaml` sincronizada con `/etc/apache2/sites-available/*.conf`.
   - Que el contenedor `ddev-andara-web` esté levantado y el VirtualHost `/etc/apache2/sites-available/andarasoft.com.conf` (y SSL) esté habilitado y sirviendo `https://andarasoft.com`.
