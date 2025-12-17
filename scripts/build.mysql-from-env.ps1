# Define parametros con valores por defecto
param(
    # Ruta al archivo de variables de entorno
    [string]$envFile = ".\env\dev.mysql.env"
)

# Inicializa diccionario para guardar variables de entorno
$envVars = @{}

# Verifica que el archivo de entorno exista
if (-not (Test-Path $envFile)) {
    Write-Error "Env file '$envFile' not found."
    exit 1
} 

# Lee el archivo de entorno linea por linea
Get-Content $envFile | ForEach-Object {
    # Si la linea tiene formato clave=valor la guarda en el diccionario
    if ($_ -match '^\s*([^=]+)=(.*)$') {
        $envVars[$matches[1]] = $matches[2]
    }
}

# Obtiene la ruta al Dockerfile desde las variables
$Dockerfile = $envVars['DB_DOCKERFILE']
# Obtiene el nombre de la imagen desde las variables
$Tag = $envVars['DB_IMAGE_NAME']

# Construye los argumentos de build para Docker usando las variables
$buildArgsSTR = @(
    "--build-arg DB_USER=" + $envVars['DB_USER'],
    "--build-arg DB_PASS=" + $envVars['DB_PASS'],
    "--build-arg DB_ROOT_PASS=" + $envVars['DB_ROOT_PASS'],
    "--build-arg DB_DATADIR=" + $envVars['DB_DATADIR'],
    "--build-arg DB_PORT=" + $envVars['DB_PORT'],
    "--build-arg DB_NAME=" + $envVars['DB_NAME'],
    "--build-arg DB_LOG_DIR=" + $envVars['DB_LOG_DIR']
) -join ' '

# Construye el comando docker build completo
$cmddockerSTR = @('docker build', '--no-cache', '-f', $Dockerfile, '-t', $Tag, $buildArgsSTR, '.') -join ' '

# Muestra el comando que se ejecutara
Write-Host "Ejecutando: docker $cmddockerSTR" 

# Ejecuta el comando docker build
Invoke-Expression $cmddockerSTR

# Captura el codigo de salida del comando
$code = $LASTEXITCODE

# Si el codigo no es 0 muestra error y termina
if ($code -ne 0) {
    Write-Error "docker build fallo con codigo $code"
    exit $code
}
