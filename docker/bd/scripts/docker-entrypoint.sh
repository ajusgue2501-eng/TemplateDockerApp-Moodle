#!/bin/sh

# Comprobamos si el directorio de datos esta vacio
# Si no existe la carpeta mysql dentro de DB_DATADIR inicializamos la base de datos
if [ ! -d "${DB_DATADIR}/mysql" ]; then
    echo "Inicializando base de datos..."
    mariadb-install-db --user=${DB_USER} --datadir=${DB_DATADIR}
fi

# Arrancamos MariaDB en segundo plano con el usuario y datadir configurados
echo "Arrancando MariaDB..."
mariadbd-safe --user=${DB_USER} --datadir=${DB_DATADIR} &
PID=$!

# Esperamos unos segundos para que el servidor este listo
sleep 10

# Configuramos el usuario root y creamos la base de datos y usuario de aplicacion
/usr/bin/mariadb -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';
CREATE DATABASE ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
EOF

# Si existe la carpeta /entrypointsql ejecutamos todos los scripts SQL que contenga
if [ -d "/entrypointsql" ]; then
    for f in /entrypointsql/*.sql; do
        if [ -f "$f" ]; then
            echo "Ejecutando $f..."
            /usr/bin/mariadb -u root -p"${DB_ROOT_PASS}" < "$f"
        fi
    done
fi

# Mantenemos el proceso principal en ejecucion esperando al PID de MariaDB
wait $PID