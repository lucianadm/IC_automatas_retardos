#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$ROOT/simulaciones"
mkdir -p "$BUILD_DIR"
command -v iverilog >/dev/null || { echo 'Error: falta iverilog en PATH' >&2; exit 1; }
command -v vvp >/dev/null || { echo 'Error: falta vvp en PATH' >&2; exit 1; }

cd "$BUILD_DIR"
echo 'Simulando miniACA...'
iverilog -g2012 -Wall -s tb_miniaca_autocheck -o miniaca.vvp \
  "$ROOT/miniACA/miniaca.v" "$ROOT/miniACA/tests/miniaca_autocheck_tb.v"
vvp miniaca.vvp

echo 'Simulando retardos...'
iverilog -g2012 -Wall -s tb_tffchain_autocheck -o tffchain.vvp \
  "$ROOT/retardos/tffchain.v" "$ROOT/retardos/tests/tffchain_autocheck_tb.v"
vvp tffchain.vvp

echo "Simulaciones completas. Ver VCD en $BUILD_DIR"
