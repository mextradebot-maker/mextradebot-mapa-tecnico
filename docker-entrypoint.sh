#!/bin/sh
# Crea el archivo de claves desde las variables de entorno (nunca se guarda una clave en el repositorio).
# Si faltan, el contenedor NO arranca: es mejor que no se publique a que se publique sin clave.
set -e

if [ -z "$MAPA_USER" ] || [ -z "$MAPA_PASS" ]; then
  echo "ERROR: faltan las variables MAPA_USER y MAPA_PASS. El mapa no se inicia sin autenticacion." >&2
  exit 1
fi

htpasswd -bBc /etc/nginx/.htpasswd "$MAPA_USER" "$MAPA_PASS"
# El proceso de nginx corre como usuario "nginx": debe poder leer el archivo (solo contiene el hash bcrypt)
chown root:nginx /etc/nginx/.htpasswd
chmod 640 /etc/nginx/.htpasswd
echo "Mapa tecnico: autenticacion configurada para el usuario $MAPA_USER."
