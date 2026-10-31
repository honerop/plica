#!/usr/bin/env bash
set -euo pipefail
plica="${1:-./.build/plica}"

# Use a real executable, not a shell builtin, and test PATH, explicit run,
# absolute paths and ./ relative paths while preserving the shell's cwd.
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
cat > "$tmpdir/plica-external-test" <<'EOF'
#!/usr/bin/env sh
printf 'plica-external:%s:%s\n' "$1" "$2"
EOF
chmod +x "$tmpdir/plica-external-test"

output="$(
  {
    printf 'pwd\nfiles .\ncapture printf hello\n'
    printf 'run plica-external-test one two\n'
    printf 'plica-external-test three four\n'
    printf '%s five six\n' "$tmpdir/plica-external-test"
    printf 'cd %s\n' "$tmpdir"
    printf './plica-external-test seven eight\n'
    printf 'run\n'
    if [[ -x /usr/bin/env ]]; then
      printf 'run /usr/bin/env printf plica-usr-bin-ok\n'
    fi
    printf 'exit\n'
  } | PATH="$tmpdir:$PATH" "$plica"
)"
printf '%s\n' "$output" | grep -Fq 'Plica 0.1'
printf '%s\n' "$output" | grep -Fq '"name"'
printf '%s\n' "$output" | grep -Fq '"stdout":"hello"'
printf '%s\n' "$output" | grep -Fq '"code":0'
printf '%s\n' "$output" | grep -Fq 'plica-external:one:two'
printf '%s\n' "$output" | grep -Fq 'plica-external:three:four'
printf '%s\n' "$output" | grep -Fq 'plica-external:five:six'
printf '%s\n' "$output" | grep -Fq 'plica-external:seven:eight'
printf '%s\n' "$output" | grep -Fq 'plica: usage: run PROGRAM [ARGS...]'
if [[ -x /usr/bin/env ]]; then
  printf '%s\n' "$output" | grep -Fq 'plica-usr-bin-ok'
fi
echo 'Plica smoke test passed'
