# Imagen base que usaremos para construir el contenedor
FROM alpine:latest

# Variables de entorno configurables en tiempo de construccion
ARG MOODLE_SERVER_PORT=${MOODLE_SERVER_PORT}
ARG MOODLE_SERVER_NAME=${MOODLE_SERVER_NAME}

# Variables de entorno que estaran disponibles en el contenedor
ENV MOODLE_SERVER_PORT=${MOODLE_SERVER_PORT}
ENV MOODLE_SERVER_NAME=${MOODLE_SERVER_NAME}

# Exponer el puerto del servidor Moodle
EXPOSE ${MOODLE_SERVER_PORT}
# Exponer el puerto usado por Xdebug
EXPOSE 9003

# Actualizar paquetes e instalar Apache y PHP con extensiones necesarias
RUN apk update && apk upgrade && \
    apk --no-cache add apache2 apache2-utils apache2-proxy php php-apache2 \
    php-curl php-gd php-mbstring php-intl php-mysqli php-xml php-zip \
    php-ctype php-dom php-iconv php-simplexml php-openssl php-sodium php-tokenizer php-xdebug

# Crear carpeta para Moodle y ajustar permisos
RUN mkdir -p /var/www/${MOODLE_SERVER_PORT} \
    && chown -R apache:apache /var/www/${MOODLE_SERVER_PORT} \
    && chmod -R 755 /var/www/${MOODLE_SERVER_PORT}

# Copiar configuracion principal de Apache
COPY ./docker/http/apache+php/conf/httpd.conf /etc/apache2/httpd.conf

# Copiar configuracion de Xdebug para PHP
COPY ./docker/http/apache+php/conf.d/php-xdebug.ini /etc/php84/conf.d/php-xdebug.ini

# Copiar configuraciones adicionales de Apache
COPY ./docker/http/apache+php/conf.d/*.conf /etc/apache2/conf.d/

# Definir el proceso de arranque por defecto: iniciar Apache en primer plano
ENTRYPOINT ["httpd", "-D", "FOREGROUND"]
