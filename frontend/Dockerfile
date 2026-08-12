# Imagen oficial Nginx sobre Alpine
FROM nginx:1.27-alpine

# Configuración del servidor
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Archivos estáticos de la aplicación
COPY index.html /usr/share/nginx/html/index.html
COPY css /usr/share/nginx/html/css
COPY js /usr/share/nginx/html/js
COPY pages /usr/share/nginx/html/pages

EXPOSE 80
