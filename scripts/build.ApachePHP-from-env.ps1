# Parametros que recibe el script
Param(
    # Ruta al archivo de variables de entorno
    [string]$EnvFile = ".\env\dev.apachephp.env",
    # Ruta al Dockerfile que se usara
    [string]$Dockerfile = "docker/http/apache+php/apache-php.dev.dockerfile",
    # Nombre y etiqueta de la imagen que se construira
    [string]$Tag = "apachephp:dev"
)

# Verifica que el archivo de entorno exista
if (-not (Test-Path $EnvFile)) {
    Write-Error "Env file '$EnvFile' not found."
    exit 1
}

# Lee todas las lineas del archivo de entorno
$lines = Get-Content $EnvFile -ErrorAction Stop
# Inicializa lista de argumentos de construccion
$buildArgs = @()

# Recorre cada linea del archivo
foreach ($line in $lines) {
    # Elimina espacios en blanco
    $line = $line.Trim()
    # Ignora lineas vacias o comentarios
    if (-not $line -or $line.StartsWith('#')) { continue }
    # Ignora lineas sin el simbolo =
    if ($line -notmatch '=') { continue }
    # Divide la linea en clave y valor
    $parts = $line -split '=', 2
    $k = $parts[0].Trim()
    $v = $parts[1].Trim()
    # Elimina comillas dobles si existen
    if ($v.StartsWith('"') -and $v.EndsWith('"')) { $v = $v.Substring(1, $v.Length - 2) }
    # Elimina comillas simples si existen
    if ($v.StartsWith("'") -and $v.EndsWith("'")) { $v = $v.Substring(1, $v.Length - 2) }
    # Agrega argumento de construccion para Docker
    $buildArgs += '--build-arg'
    $buildArgs += "$k=$v"
}

# Construye el comando docker build con todos los argumentos
$argsSTR = @('build', '--no-cache', '-f', $Dockerfile, '-t', $Tag) + $buildArgs + '.'

# Muestra el comando que se ejecutara y lo lanza
Write-Host "Ejecutando: docker $($argsSTR -join ' ')" & docker @argsSTR

# Captura el codigo de salida del comando
$code = $LASTEXITCODE
# Si el codigo no es 0, muestra error y termina
if ($code -ne 0) {
    Write-Error "docker build fallo con codigo $code"
    exit $code
}
