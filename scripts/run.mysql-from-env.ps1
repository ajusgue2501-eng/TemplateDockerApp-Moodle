# Define parametro con ruta al archivo de entorno
param(
    [string]$envFile = ".\env\dev.mysql.env"
)

# Inicializa diccionario para guardar variables de entorno
$envVars = @{}

# Verifica que el archivo de entorno exista
if (-not (Test-Path $envFile)) {
    Write-Error "Env file '$envFile' not found."
    exit 1
} 

# Lee el archivo de entorno linea por linea y guarda clave=valor
Get-Content $envFile | ForEach-Object {
    if ($_ -match '^\s*([^=]+)=(.*)$') {
        $envVars[$matches[1]] = $matches[2]
    }
}

# Configura variables a partir del archivo de entorno
$containerName = $envVars['DB_CONTAINER_NAME']
#$dbName = $envVars['DB_NAME']
#$dbUSer = $envVars['DB_USER']
#$dbPass = $envVars['DB_PASS']
#$dbRootPass = $envVars['DB_ROOT_PASS']
$dbDataDir = $envVars['DB_DATADIR']
$dbLogDir = $envVars['DB_LOG_DIR']
$portMapping = $envVars['DB_PORT_MAPPING'] 
$imageName = $envVars['DB_IMAGE_NAME']
$networkName = $envVars['DB_NETWORK_NAME']
$ip = $envVars["DB_IP"]

# Elimina el contenedor si ya existe
if (docker ps -a --filter "name=^${containerName}$" --format "{{.Names}}" | Select-Object -First 1) {
    Write-Host "Eliminando contenedor existente: $containerName"
    docker stop $containerName 2>$null
    docker rm $containerName 2>$null
}

# Construye el comando docker run con todos los parametros
$dockerCmd = @(
    "docker run -d",
    "--name $containerName",
    "-p $portMapping",
    "-v .\mysql_data:$dbDataDir",
    "-v .\logs\mysql:$dbLogDir",
    "--env-file $envFile",
    "--hostname $containerName",
    "--network $networkName",
    "--ip $ip",
    "--hostentry ${ip} mysqlhost",
    $imageName
) -join ' '

# Muestra el comando que se ejecutara
Write-Host "Ejecutando: $dockerCmd"

# Ejecuta el comando docker run
Invoke-Expression $dockerCmd
