# Imagen base que usaremos para construir el contenedor
FROM alpine:latest

# Variables de entorno configurables en tiempo de construcción
ARG DB_PORT=${DB_PORT} \
    DB_USER=${DB_USER} \
    DB_PASS=${DB_PASS} \
    DB_ROOT_PASS=${DB_ROOT_PASS} \
    DB_NAME=${DB_NAME} \
    DB_DATADIR=${DB_DATADIR} \
    DB_LOG_DIR=${DB_LOG_DIR}

# Variables de entorno que estarán disponibles en el contenedor
ENV DB_PORT=${DB_PORT} \
    DB_DATADIR=${DB_DATADIR} \
    DB_ROOT_PASS=${DB_ROOT_PASS} \
    DB_NAME=${DB_NAME} \
    DB_USER=${DB_USER} \
    DB_PASS=${DB_PASS} \
    DB_LOG_DIR=${DB_LOG_DIR}

# Instalar mariadb y utilidades necesarias
RUN apk update && \
    apk add --no-cache mariadb mariadb-client mariadb-server-utils && \
    addgroup -S ${DB_USER} && \
    adduser -S ${DB_USER} -G ${DB_USER} && \
    mkdir -p ${DB_DATADIR} ${DB_LOG_DIR} /entrypointsql && \
    chown -R ${DB_USER}:${DB_USER} ${DB_DATADIR} ${DB_LOG_DIR} /entrypointsql && \
    chmod -R 755 ${DB_DATADIR} ${DB_LOG_DIR} /entrypointsql && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/* && \
    mariadb-install-db --user=${DB_USER} --datadir=${DB_DATADIR}

# Copiar script de arranque al contenedor
COPY ./docker/bd/scripts/docker-entrypoint.sh /entrypoint.sh

# Copiar archivos SQL iniciales
COPY ./docker/bd/sql/*.sql /entrypointsql/

# Copiar configuración de MySQL/MariaDB
COPY ./docker/bd/conf/mysql.dev.cnf /etc/my.cnf

# Ajustar permisos del script y directorios
RUN chown -R ${DB_USER}:${DB_USER} /entrypoint* && chmod 755 /entrypoint.sh && ls -la /entrypoint*

# Convertir saltos de línea a formato UNIX y dar permisos de ejecución
RUN dos2unix /entrypoint.sh && chmod 755 /entrypoint.sh

# Exponer el puerto de la base de datos
EXPOSE ${DB_PORT}

# Definir el script de arranque por defecto
ENTRYPOINT ["sh", "/entrypoint.sh" ]