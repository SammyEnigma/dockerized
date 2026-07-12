#!/bin/bash
# Assert the PHP version list is consistent across the two places it is spelled:
#   - build/config.sh        PHP_VERSIONS   (drives Dockerfile generation)
#   - docker-bake.hcl        PHP_MATRIX     (drives the matrix build targets)
#
# The matrix refactor (Phase 2) collapsed 48 hand-written per-PHP target blocks
# into bake `matrix` targets, but bake HCL cannot source config.sh, so the PHP
# list still exists in both files. This check makes any drift between them loud
# (fails CI) instead of silently building a version in one but not the other.
#
# Also verifies each PHP_MATRIX entry's `nn` (compact, e.g. 84) is exactly its
# `v` (dotted, e.g. 8.4) with the dot removed — the two are used to build
# dockerfile names and tags respectively and must correspond.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BAKE="$PROJECT_ROOT/docker-bake.hcl"

# shellcheck source=config.sh
source "$SCRIPT_DIR/config.sh"

# config.sh side: PHP_VERSIONS array, sorted.
cfg_versions="$(printf '%s\n' "${PHP_VERSIONS[@]}" | sort)"

# docker-bake.hcl side: parse the PHP_MATRIX default block. Each entry looks
# like `{ v = "8.4", nn = "84" }`. Pull v + nn per line.
matrix_block="$(awk '/variable "PHP_MATRIX"/{f=1} f{print} f&&/^}/{exit}' "$BAKE")"
if [[ -z "$matrix_block" ]]; then
    echo "[ERROR] could not find PHP_MATRIX block in $BAKE" >&2
    exit 1
fi

bake_versions="$(grep -oE 'v = "[^"]+"' <<<"$matrix_block" | sed -E 's/v = "([^"]+)"/\1/' | sort)"

# 1) same set of versions in both files
if [[ "$cfg_versions" != "$bake_versions" ]]; then
    echo "[ERROR] PHP version drift between config.sh and docker-bake.hcl:" >&2
    diff <(echo "config.sh PHP_VERSIONS:";  echo "$cfg_versions") \
         <(echo "bake PHP_MATRIX v=:";      echo "$bake_versions") >&2 || true
    exit 1
fi

# 2) each PHP_MATRIX entry's nn == v with the dot removed
fail=0
while IFS= read -r line; do
    v="$(grep -oE 'v = "[^"]+"'  <<<"$line" | sed -E 's/v = "([^"]+)"/\1/')"
    nn="$(grep -oE 'nn = "[^"]+"' <<<"$line" | sed -E 's/nn = "([^"]+)"/\1/')"
    [[ -z "$v" || -z "$nn" ]] && continue
    expect="${v/./}"
    if [[ "$nn" != "$expect" ]]; then
        echo "[ERROR] PHP_MATRIX entry v=$v has nn=$nn, expected $expect" >&2
        fail=1
    fi
done < <(grep -E 'v = "' <<<"$matrix_block")
[[ $fail -eq 0 ]] || exit 1

echo "[OK] PHP versions in sync: $(tr '\n' ' ' <<<"$cfg_versions")"
