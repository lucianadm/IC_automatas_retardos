# Ejecucion con Icarus Verilog en Windows. Requiere iverilog y vvp en PATH.
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$build = Join-Path $root 'simulaciones'
New-Item -ItemType Directory -Force -Path $build | Out-Null
foreach ($app in @('iverilog', 'vvp')) {
    if (-not (Get-Command $app -ErrorAction SilentlyContinue)) {
        throw "No se encontro $app en PATH. Instala Icarus Verilog antes de ejecutar."
    }
}
Push-Location $build
try {
    Write-Host 'Simulando miniACA...'
    & iverilog -g2012 -Wall -s tb_miniaca_autocheck -o miniaca.vvp `
        (Join-Path $root 'miniACA/miniaca.v') (Join-Path $root 'miniACA/tests/miniaca_autocheck_tb.v')
    if ($LASTEXITCODE -ne 0) { throw 'Fallo compilacion miniACA' }
    & vvp 'miniaca.vvp'
    if ($LASTEXITCODE -ne 0) { throw 'Fallo test miniACA' }

    Write-Host 'Simulando retardos...'
    & iverilog -g2012 -Wall -s tb_tffchain_autocheck -o tffchain.vvp `
        (Join-Path $root 'retardos/tffchain.v') (Join-Path $root 'retardos/tests/tffchain_autocheck_tb.v')
    if ($LASTEXITCODE -ne 0) { throw 'Fallo compilacion retardos' }
    & vvp 'tffchain.vvp'
    if ($LASTEXITCODE -ne 0) { throw 'Fallo test retardos' }
    Write-Host "Pruebas completas. Ver VCD en $build"
} finally {
    Pop-Location
}
