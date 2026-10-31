#!/usr/bin/env bash
set -euo pipefail
plica="${1:-./.build/plica}"
output="$(printf 'pwd\nfiles .\ncapture printf hello\nexit\n' | "$plica")"
printf '%s\n' "$output" | grep -Fq 'Plica 0.1'
printf '%s\n' "$output" | grep -Fq '"name"'
printf '%s\n' "$output" | grep -Fq '"stdout":"hello"'
printf '%s\n' "$output" | grep -Fq '"code":0'
echo 'Plica smoke test passed'
