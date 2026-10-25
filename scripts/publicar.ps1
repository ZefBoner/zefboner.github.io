<#
.SYNOPSIS
    Sube los cambios a GitHub (git add + commit + push).

.DESCRIPTION
    Hace commit de todo lo que haya cambiado y lo empuja a GitHub.
    En cuanto termina el push, GitHub Actions construye y publica el sitio
    (tarda 1-2 minutos en estar en linea).

.EXAMPLE
    .\scripts\publicar.ps1 "HTB: Codify"

.EXAMPLE
    .\scripts\publicar.ps1            # usa un mensaje de commit automatico
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Mensaje
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot
Push-Location $Root
try {
    if (-not (Test-Path (Join-Path $Root '.git'))) {
        Write-Host "Esta carpeta todavia no es un repositorio git." -ForegroundColor Red
        Write-Host "Primero crea el repo en GitHub y conectalo (ver README, seccion 'Subirlo a GitHub')."
        return
    }

    $cambios = git status --porcelain
    if ([string]::IsNullOrWhiteSpace($cambios)) {
        Write-Host "No hay cambios para publicar." -ForegroundColor Yellow
        return
    }

    Write-Host "Cambios a publicar:" -ForegroundColor Cyan
    git status --short
    Write-Host ""

    if ([string]::IsNullOrWhiteSpace($Mensaje)) {
        $Mensaje = "Actualiza el sitio ($(Get-Date -Format 'yyyy-MM-dd HH:mm'))"
    }

    git add -A
    git commit -m $Mensaje

    # Nombre de la rama actual (main o master)
    $rama = (git rev-parse --abbrev-ref HEAD).Trim()
    git push origin $rama

    Write-Host ""
    Write-Host "  Publicado." -ForegroundColor Green
    Write-Host "  GitHub esta construyendo el sitio. En 1-2 minutos estara en linea."
    Write-Host "  Progreso del build:  https://github.com/ZefBoner/ZefBoner.github.io/actions"
    Write-Host "  Sitio:               https://zefboner.github.io"
    Write-Host ""
}
finally {
    Pop-Location
}
