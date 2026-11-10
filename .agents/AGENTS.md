# Workspace Rules & Context: Andara Soft (`andara`)

## 📌 Entorno de Producción y Accesos
- **Proyecto:** Andara Soft (`staging-environment/andara`)
- **Dominio de Producción:** `https://andarasoft.com`
- **Servidor de Producción (IP):** `75.119.136.151`
- **Usuario SSH:** `root` (`ssh root@75.119.136.151`)
- **Ruta en Producción:** `/home/developer/Projects/andarasalon`
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
2. Desplegar en el servidor de producción (`root@75.119.136.151`) en `/home/developer/Projects/andarasalon`:
   ```bash
   ssh root@75.119.136.151 "cd /home/developer/Projects/andarasalon && git pull origin main"
   ```
   *(Disponible vía SSH directo desde el entorno local; desde el agente en la nube `☁️`, el sandbox restringe conexiones salientes al puerto 22 SSH pero permite push a GitHub y verificación HTTP/HTTPS contra `https://andarasoft.com`).*
