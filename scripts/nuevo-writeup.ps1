<#
.SYNOPSIS
    Crea un writeup nuevo a partir de una plantilla.

.DESCRIPTION
    Copia la plantilla elegida a _posts/ con el nombre de archivo correcto
    (fecha-slug), rellena el titulo, la fecha y las categorias, y crea la
    carpeta de imagenes en assets/img/posts/<slug>/.

.EXAMPLE
    .\scripts\nuevo-writeup.ps1 -Tipo maquina -Titulo "HTB: Codify"

.EXAMPLE
    .\scripts\nuevo-writeup.ps1 -Tipo sherlock -Titulo "Sherlock: Brutus" -Categorias "HackTheBox,Sherlocks"

.EXAMPLE
    .\scripts\nuevo-writeup.ps1 -Tipo challenge -Titulo "Flag Command" -Categorias "CTF,Cyber Apocalypse 2025"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('maquina', 'sherlock', 'challenge', 'lab')]
    [string]$Tipo,

    [Parameter(Mandatory = $true)]
    [string]$Titulo,

    # Lista separada por comas. Si se omite, se usan valores por defecto segun el tipo.
    [string]$Categorias
)

$ErrorActionPreference = 'Stop'

# Raiz del proyecto (carpeta padre de /scripts)
$Root = Split-Path -Parent $PSScriptRoot
$Plantilla = Join-Path $Root "_plantillas\$Tipo.md"

if (-not (Test-Path $Plantilla)) {
    throw "No existe la plantilla: $Plantilla"
}

# Categorias por defecto segun el tipo
if ([string]::IsNullOrWhiteSpace($Categorias)) {
    $Categorias = switch ($Tipo) {
        'maquina'   { 'HackTheBox,Machines' }
        'sherlock'  { 'HackTheBox,Sherlocks' }
        'challenge' { 'CTF' }
        'lab'       { 'Labs' }
    }
}
# "A,B" -> "A, B" para el front matter YAML
$CategoriasYaml = ($Categorias -split ',' | ForEach-Object { $_.Trim() }) -join ', '

# Slug a partir del titulo: minusculas, sin acentos, guiones
function Get-Slug([string]$texto) {
    $t = $texto.ToLowerInvariant()
    $t = $t.Normalize([Text.NormalizationForm]::FormD)
    $t = ($t.ToCharArray() | Where-Object {
        [Globalization.CharUnicodeInfo]::GetUnicodeCategory($_) -ne [Globalization.UnicodeCategory]::NonSpacingMark
    }) -join ''
    $t = $t -replace '[^a-z0-9]+', '-'
    return $t.Trim('-')
}

$Slug = Get-Slug $Titulo
if ([string]::IsNullOrWhiteSpace($Slug)) { throw "El titulo no produce un slug valido." }

$Fecha = Get-Date -Format 'yyyy-MM-dd'
$FechaFront = Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz'
$FechaFront = $FechaFront -replace ':(\d\d)$', '$1'  # zona +06:00 -> +0600 estilo Jekyll

$NombreArchivo = "$Fecha-$Slug.md"
$Destino = Join-Path $Root "_posts\$NombreArchivo"

if (Test-Path $Destino) {
    throw "Ya existe un writeup con ese nombre: $NombreArchivo"
}

# Leer plantilla como UTF-8 (Get-Content usa ANSI por defecto en Windows PowerShell)
$Contenido = [System.IO.File]::ReadAllText($Plantilla, [System.Text.Encoding]::UTF8)
$Contenido = $Contenido.Replace('__TITULO__', $Titulo)
$Contenido = $Contenido.Replace('__FECHA__', $FechaFront)
$Contenido = $Contenido.Replace('__CATEGORIAS__', $CategoriasYaml)
$Contenido = $Contenido.Replace('__PLATAFORMA__', 'HackTheBox')
$Contenido = $Contenido.Replace('__EVENTO__', 'Nombre del CTF')
$Contenido = $Contenido.Replace('__NOMBRE__', $Titulo)
$Contenido = $Contenido.Replace('__LINK__', 'https://')

# Insertar media_subpath para que las imagenes salgan de la carpeta del slug
$Contenido = $Contenido -replace '(?m)^(categories: .*)$', "`$1`nmedia_subpath: /assets/img/posts/$Slug"

# Escribir como UTF-8 sin BOM
$Utf8SinBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($Destino, $Contenido, $Utf8SinBom)

# Carpeta de imagenes
$CarpetaImg = Join-Path $Root "assets\img\posts\$Slug"
New-Item -ItemType Directory -Force -Path $CarpetaImg | Out-Null

Write-Host ""
Write-Host "  Writeup creado" -ForegroundColor Green
Write-Host "  --------------------------------------------------"
Write-Host "  Post:      _posts\$NombreArchivo"
Write-Host "  Imagenes:  assets\img\posts\$Slug\  (pega aqui tus capturas)"
Write-Host ""
Write-Host "  1) Editalo con tu editor favorito."
Write-Host "  2) Vista previa:   .\scripts\servir.ps1"
Write-Host "  3) Publicar:       .\scripts\publicar.ps1 `"$Titulo`""
Write-Host ""
