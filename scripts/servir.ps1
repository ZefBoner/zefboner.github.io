<#
.SYNOPSIS
    Vista previa del sitio en http://localhost:4000

.DESCRIPTION
    Levanta Jekyll localmente para ver los cambios antes de publicar.
    - Si tienes Ruby/Bundler instalado, lo usa directamente.
    - Si no, usa Docker (necesitas Docker Desktop abierto).
    Corta con Ctrl+C.

.EXAMPLE
    .\scripts\servir.ps1
#>
[CmdletBinding()]
param(
    [switch]$Docker  # fuerza el uso de Docker aunque haya Ruby
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot
Push-Location $Root
try {
    $hayBundler = -not $Docker -and (Get-Command bundle -ErrorAction SilentlyContinue)

    if ($hayBundler) {
        Write-Host "> Usando Ruby/Bundler local" -ForegroundColor Cyan
        if (-not (Test-Path (Join-Path $Root 'Gemfile.lock'))) {
            bundle install
        }
        bundle exec jekyll serve --livereload --host 127.0.0.1
        return
    }

    $hayDocker = Get-Command docker -ErrorAction SilentlyContinue
    if (-not $hayDocker) {
        Write-Host "No tienes ni Ruby/Bundler ni Docker." -ForegroundColor Red
        Write-Host "Opciones:"
        Write-Host "  - Instala Ruby+Devkit (https://rubyinstaller.org) y vuelve a correr este script."
        Write-Host "  - O abre Docker Desktop."
        Write-Host ""
        Write-Host "No pasa nada si no puedes previsualizar en local: al hacer git push,"
        Write-Host "GitHub construye y publica el sitio igual."
        return
    }

    Write-Host "> Usando Docker (Jekyll en contenedor)" -ForegroundColor Cyan
    Write-Host "  La primera vez tarda unos minutos bajando gemas..." -ForegroundColor DarkGray
    Write-Host "  Cuando diga 'Server running', abre http://localhost:4000" -ForegroundColor DarkGray
    Write-Host ""

    # Volumen para cachear las gemas entre ejecuciones
    docker volume create angxdes-bundle | Out-Null

    docker run --rm -it `
        -p 4000:4000 `
        -v "${Root}:/site" `
        -v "angxdes-bundle:/usr/local/bundle" `
        -w /site `
        ruby:3.4 `
        bash -c "bundle install && bundle exec jekyll serve -H 0.0.0.0 --livereload"
}
finally {
    Pop-Location
}
