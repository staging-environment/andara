# Regla de Flujo de Trabajo: Commit y Despliegue en Producción (`andara`)

## Datos del Servidor de Producción
- **IP del Servidor:** `75.119.136.151`
- **Usuario SSH:** `root`
- **Acceso SSH:** `ssh root@75.119.136.151`
- **Ruta en Producción:** `/home/developer/Projects/andarasalon/public_html`
- **Dominio Web:** `https://andarasoft.com` (`Apache/2.4.58 (Ubuntu)`)
- **Aplicación SaaS vinculada (`SUX_SALON`):** `https://andarasalon.com`

## Política de Commit, Push y Despliegue
Cada vez que se complete cualquier cambio en este repositorio:

1. **Commit y Push a GitHub:**
   ```bash
   git add <archivos>
   git commit -m "feat/fix: descripción clara del cambio"
   git push origin main
   ```
2. **Despliegue en Producción (`root@75.119.136.151`):**
   - Ruta del proyecto: `/home/developer/Projects/andarasalon/public_html`
   - Si el agente se ejecuta en el entorno local con acceso SSH directo:
     ```bash
     ssh root@75.119.136.151 "cd /home/developer/Projects/andarasalon/public_html && git pull origin main"
     ```
   - Si el agente se ejecuta en el entorno Cloud (`☁️`): el proxy del sandbox bloquea tráfico TCP saliente en el puerto `22` (SSH), por lo que se dejarán los cambios commiteados y pusheados en `origin/main` y se verificará la respuesta HTTP/HTTPS de `https://andarasoft.com`.
