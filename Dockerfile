FROM nginx:1.27-alpine

# htpasswd para la clave de acceso
RUN apk add --no-cache apache2-utils

COPY nginx.conf /etc/nginx/conf.d/default.conf
# La imagen oficial de nginx ejecuta los .sh de esta carpeta al arrancar
COPY docker-entrypoint.sh /docker-entrypoint.d/40-mapa-auth.sh
RUN chmod +x /docker-entrypoint.d/40-mapa-auth.sh

COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80
