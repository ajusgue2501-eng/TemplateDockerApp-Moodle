# CrearRedDocker.ps1
# Script para crear una red en Docker usando PowerShell

<#
.SYNOPSIS
    Crea una red en Docker con configuracion personalizable.
.EXAMPLE
    .\create_network.ps1
    .\create_network.ps1 -NetworkName "MyNetwork" -Driver "bridge"
    .\create_network.ps1 -NetworkName "MyNetwork" -Subnet "192.168.0.0/16" -Gateway "192.168.0.1"
#>

# Parametros que recibe el script
param(
    [string]$NetworkName = "MoodleNet",   # Nombre de la red
    [string]$Driver = "bridge",           # Driver de red (bridge, overlay, host, etc.)
    [string]$Subnet = "172.25.0.0/16",    # Subred opcional
    [string]$Gateway = "172.25.0.1"       # Gateway opcional
)

# Mensaje informativo al crear la red
Write-Host "Creando red Docker: $NetworkName con driver $Driver..." -ForegroundColor Cyan

# Construir comando dinamico para crear la red
$command = "docker network create --driver $Driver"

# Si se especifica subred y gateway se agregan al comando
if ($Subnet -and $Gateway) {
    $command += " --subnet=$Subnet --gateway=$Gateway"
}

# Agrega el nombre de la red al comando
$command += " $NetworkName"

# Ejecuta el comando para crear la red
Invoke-Expression $command

# Muestra las redes disponibles para verificar la creacion
Write-Host "Redes disponibles:" -ForegroundColor Green
docker network ls
