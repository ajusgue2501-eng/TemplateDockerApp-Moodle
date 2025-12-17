# Define parametro con ruta al archivo de entorno
Param(
    [string]$envFile = ".\env\dev.apachephp.env"
)

# Inicializa diccionario para guardar variables de entorno
$envVars = @{}

# Verifica que el archivo de entorno exista
if (-not (Test-Path $envFile)) {
    Write-Error "Archivo de entorno '$envFile' no encontrado."
    exit 1
}

# Lee el archivo de entorno linea por linea y guarda clave=valor
Get-Content $envFile | ForEach-Object {
    if ($_ -match '^\s*([^=]+)=(.*)$') {
        $envVars[$matches[1]] = $matches[2]
    }
}

# Configura variables a partir del archivo de entorno
$imageName = $envVars['IMAGE_NAME']
$containerName = $envVars['CONTAINER_NAME'] 
$ip = $envVars['SERVER_IP']

$moodleservername = $envVars['MOODLE_SERVER_NAME']
$servername = $envVars['SERVER_NAME']
$moodleserverport = $envVars['MOODLE_SERVER_PORT']

$MOODLE_VOLUME_PATH = $envVars['MOODLE_VOLUME_PATH']
$volumePath = $envVars['VOLUME_PATH']
$networkName = $envVars['NETWORK_NAME']

# Si la red no existe y se definieron parametros, crearla
if (
        $envVars['NETWORK_NAME'] -and `
        $envVars['NETWORK_SUBNET'] -and `
        $envVars['NETWORK_SUBNET_GATEWAY'] -and `
        $envVars['IP'] -and `
        -not (docker network ls --filter "name=^${envVars['NETWORK_NAME]}$" --format "{{.Name}}")
    ) {
        $networkName = $envVars['NETWORK_NAME']
        
        Write-Host "Creando red: $networkName"
        docker network create $networkName --subnet=$($envVars['NETWORK_SUBNET']) --gateway=$($envVars['NETWORK_SUBNET_GATEWAY'])
    }

# Elimina el contenedor si ya existe
if (docker ps -a --filter "name=^${containerName}$" --format "{{.Names}}" | Select-Object -First 1) {
    Write-Host "Eliminando contenedor existente: $containerName"
    docker stop $containerName 2>$null
    docker rm $containerName 2>$null
}

# Construye el comando docker run con todos los parametros
$dockerCmd = @(
    "docker run -d",
    "--name ${containerName}",
    "-p ${moodleserverport}:80",
    "-v ${volumePath}:/var/www/localhost/htdocs",
    "-v ${MOODLE_VOLUME_PATH}:/var/www/${moodleservername}",
    "-v .\logs\apachephp:/var/log/apache2",
    "--env-file $envFile",
    "--hostname $containerName",
    "--network $networkName",
    "--ip $ip",
    "--add-host ${servername}:${ip}",
    "--add-host ${moodleservername}:${ip}",
    $imageName
) -join ' '

# Muestra el comando que se ejecutara
Write-Host "Ejecutando: $dockerCmd"

# Ejecuta el comando docker run
Invoke-Expression $dockerCmd
