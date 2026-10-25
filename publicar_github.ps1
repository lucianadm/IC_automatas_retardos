<#[
.SYNOPSIS
  Crea un repositorio PRIVADO en la cuenta GitHub autenticada y sube este proyecto.
.REQUIREMENTS
  Git y GitHub CLI (gh) instalados. Ejecutar primero: gh auth login
.EXAMPLE
  .\publicar_github.ps1
  .\publicar_github.ps1 -RepoName 'mis-circuitos'  # Privado por defecto
#>
param([string]$RepoName = 'IC_automatas_retardos')
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path

foreach ($program in @('git','gh')) {
    if (-not (Get-Command $program -ErrorAction SilentlyContinue)) {
        throw "Falta '$program'. Instala Git y GitHub CLI (gh)."
    }
}
& gh auth status
if ($LASTEXITCODE -ne 0) { throw 'Primero ejecuta: gh auth login' }
$username = (& gh api user --jq '.login').Trim()
if ($LASTEXITCODE -ne 0 -or -not $username) { throw 'No pude identificar el usuario GitHub' }
$repo = "$username/$RepoName"

# Consulta la lista de repositorios para evitar publicar sobre uno existente.
$names = @(& gh repo list $username --limit 1000 --json name --jq '.[].name')
if ($LASTEXITCODE -ne 0) { throw 'No pude verificar si ya existe el repositorio' }
if ($names -contains $RepoName) {
    throw "El repositorio $repo ya existe. Se detuvo para no sobrescribirlo."
}

Push-Location $root
try {
    if (-not (Test-Path (Join-Path $root '.git'))) {
        & git init -b main
        if ($LASTEXITCODE -ne 0) { throw 'No se pudo inicializar Git' }
    }
    & git add .
    if ($LASTEXITCODE -ne 0) { throw 'Error en git add' }
    & git -c user.name=$username -c "user.email=$username@users.noreply.github.com" commit -m 'Documentar miniACA y tffchain con RTL y pruebas'
    if ($LASTEXITCODE -ne 0) { throw 'Error al crear el commit inicial' }

    & gh repo create $repo --private --source . --remote origin --push
    if ($LASTEXITCODE -ne 0) { throw 'No se pudo crear el repositorio o enviar los archivos' }
    Write-Host "Repositorio PRIVADO creado: https://github.com/$repo"
} finally {
    Pop-Location
}
