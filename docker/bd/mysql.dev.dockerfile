FROM alpine:latest

# Variables de entorno configurables
ARG DB_PORT=${DB_PORT} \
    DB_USER=${DB_USER} \
    DB_PASS=${DB_PASS} \
    DB_ROOT_PASS=${DB_ROOT_PASS} \
    DB_NAME=${DB_NAME} \
    DB_DATADIR=${DB_DATADIR} \
    DB_LOG_DIR=${DB_LOG_DIR}


ENV DB_PORT=${DB_PORT} \
    DB_DATADIR=${DB_DATADIR} \
    DB_ROOT_PASS=${DB_ROOT_PASS} \
    DB_NAME=${DB_NAME} \
    DB_USER=${DB_USER} \
    DB_PASS=${DB_PASS} \
    DB_LOG_DIR=${DB_LOG_DIR}

# Instalar mariadb y cliente
RUN apk update && \
    apk add --no-cache mariadb mariadb-client mariadb-server-utils && \
    addgroup -S ${DB_USER} && \
    adduser -S ${DB_USER} -G ${DB_USER} && \
    mkdir -p ${DB_DATADIR} /run/mysqld ${DB_LOG_DIR} /entrypointsql && \
    chown -R ${DB_USER}:${DB_USER} ${DB_DATADIR} /run/mysqld /var/log/mysql /entrypointsql && \
    chmod -R 755 ${DB_DATADIR} /run/mysqld ${DB_LOG_DIR} /entrypointsql && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/* && \
    mariadb-install-db --user=${DB_USER} --datadir=${DB_DATADIR}

COPY ./docker/bd/scripts/docker-entrypoint.sh /entrypoint.sh
COPY ./docker/bd/sql/*.sql /entrypointsql/
COPY ./docker/bd/conf/mysql.dev.cnf /etc/my.cnf
RUN  chown -R ${DB_USER}:${DB_USER} /entrypoint* && chmod 755 /entrypoint.sh && ls -la /entrypoint*
RUN dos2unix /entrypoint.sh && chmod 755 /entrypoint.sh

USER ${DB_USER}
# Exponer puerto
EXPOSE ${DB_PORT}

# Entrypoint y comando por defecto
ENTRYPOINT ["sh", "/entrypoint.sh" ]

