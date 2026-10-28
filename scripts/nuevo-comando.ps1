<#
.SYNOPSIS
    Añade un comando/técnica al arsenal (_data/arsenal.yml).

.EXAMPLE
    .\scripts\nuevo-comando.ps1 -Cmd "sudo -l" -Fase "Escalada de privilegios" -Desc "Listar permisos sudo del usuario actual" -Tags "linux,sudo,privesc"

.EXAMPLE
    .\scripts\nuevo-comando.ps1 -Cmd "crackmapexec smb <IP> -u user -p pass" -Fase "Movimiento lateral" -Desc "Spray de credenciales por SMB" -Tags "ad,smb,cme" -Ref "HTB: Forest" -RefUrl "/posts/htb-forest/"

.NOTES
    Fases sugeridas: Reconocimiento, Enumeración, Acceso inicial, Transferencia de archivos,
    Credenciales, Movimiento lateral, Escalada de privilegios, Persistencia,
    Análisis / DFIR, Reversing, C2, Cripto
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)] [string]$Cmd,
    [Parameter(Mandatory = $true)] [string]$Fase,
    [Parameter(Mandatory = $true)] [string]$Desc,
    [string]$Tags = "",                # separadas por comas
    [string]$Ref = "",                 # nombre del writeup (opcional)
    [string]$RefUrl = ""               # url del writeup (opcional, p.ej. /posts/htb-foo/)
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot
$File = Join-Path $Root "_data\arsenal.yml"
if (-not (Test-Path $File)) { throw "No existe $File" }

# Comillas simples de YAML: se escapan duplicándolas.
function Q([string]$s) { "'" + ($s -replace "'", "''") + "'" }

$tagsYaml = "[]"
if (-not [string]::IsNullOrWhiteSpace($Tags)) {
    $list = ($Tags -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ } | ForEach-Object { Q $_ }) -join ', '
    $tagsYaml = "[$list]"
}

$block = @()
$block += ""
$block += "- cmd: $(Q $Cmd)"
$block += "  fase: $(Q $Fase)"
$block += "  desc: $(Q $Desc)"
$block += "  tags: $tagsYaml"
if (-not [string]::IsNullOrWhiteSpace($Ref) -and -not [string]::IsNullOrWhiteSpace($RefUrl)) {
    $block += "  refs:"
    $block += "    - nombre: $(Q $Ref)"
    $block += "      url: $(Q $RefUrl)"
} else {
    $block += "  refs: []"
}

# Asegura salto de línea final y añade en UTF-8 sin BOM
$current = [System.IO.File]::ReadAllText($File, [System.Text.Encoding]::UTF8)
if ($current.Length -gt 0 -and -not $current.EndsWith("`n")) { $current += "`n" }
$current += (($block -join "`n") + "`n")
$Utf8SinBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($File, $current, $Utf8SinBom)

Write-Host ""
Write-Host "  Comando añadido al arsenal:" -ForegroundColor Green
Write-Host "    $Cmd"
Write-Host "    fase: $Fase   tags: $Tags"
if ($Ref) { Write-Host "    ref:  $Ref -> $RefUrl" }
Write-Host ""
Write-Host "  Previsualiza con  .\scripts\servir.ps1  o publica con  .\scripts\publicar.ps1" -ForegroundColor DarkGray
Write-Host ""
