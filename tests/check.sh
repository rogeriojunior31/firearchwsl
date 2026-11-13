#!/bin/bash
# Static checks for firearchwsl. Run from anywhere: bash tests/check.sh
#   1. bash -n on every script
#   2. shellcheck (if installed)
#   3. fish -n on the fish config (if fish is installed)
#   4. i18n: every key used exists in en.sh, every catalog has the same keys
#      as en.sh, and each translation keeps the same printf placeholders.
# Exit code is the number of failed checks.
set -uo pipefail
# One collation for every sort/comm/join below, whatever the user's locale.
export LC_ALL=C

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 1

failures=0
pass() { printf '  \e[32m✔\e[0m %s\n' "$*"; }
fail() { printf '  \e[31m✖\e[0m %s\n' "$*"; failures=$((failures + 1)); }
note() { printf '  \e[90m↷ %s\e[0m\n' "$*"; }

# Every .sh plus the extensionless commands in bin/.
mapfile -t scripts < <(git ls-files '*.sh' 'bin/*' 2>/dev/null ||
  find . -type f \( -name '*.sh' -o -path './bin/*' \) -not -path './.git/*')

echo "bash -n"
bad=0
for f in "${scripts[@]}"; do
  bash -n "$f" || { fail "$f"; bad=1; }
done
((bad)) || pass "${#scripts[@]} scripts parse"

echo "shellcheck"
if command -v shellcheck &>/dev/null; then
  if shellcheck -x -S warning "${scripts[@]}"; then pass "no warnings"; else fail "shellcheck reported problems"; fi
else
  note "shellcheck not installed — skipped"
fi

echo "fish -n"
if command -v fish &>/dev/null; then
  if fish -n default/config.fish; then pass "default/config.fish"; else fail "default/config.fish"; fi
else
  note "fish not installed — skipped"
fi

echo "i18n"
# Keys of a catalog, one per line: "key<TAB>placeholders" (e.g. "user.exists	%s").
catalog_keys() {
  bash -c '
    declare -A MSG=()
    source "$1"
    for k in "${!MSG[@]}"; do
      p="$(grep -oE "%[sd]" <<<"${MSG[$k]//%%/}" | tr -d "\n")"
      printf "%s\t%s\n" "$k" "$p"
    done | sort
  ' _ "$1"
}

en_keys="$(catalog_keys install/i18n/en.sh)"

# Keys referenced by the code: `t key` calls plus the step titles in STEPS.
used="$(
  {
    grep -hoE '\bt "?[a-z_]+\.[a-z_0-9]+' "${scripts[@]}" | sed -E 's/^t "?//'
    grep -hoE '"step\.[a-z_]+\|' install.sh | tr -d '"|'
    echo usage
  } | sort -u
)"
missing="$(comm -23 <(echo "$used") <(cut -f1 <<<"$en_keys"))"
if [[ -z "$missing" ]]; then
  pass "every key used in the code exists in en.sh ($(wc -l <<<"$used") keys)"
else
  fail "keys used but missing from en.sh: $(tr '\n' ' ' <<<"$missing")"
fi
unused="$(comm -13 <(echo "$used") <(cut -f1 <<<"$en_keys"))"
[[ -z "$unused" ]] || note "keys defined but never used: $(tr '\n' ' ' <<<"$unused")"

for catalog in install/i18n/*.sh; do
  [[ "$catalog" == install/i18n/en.sh ]] && continue
  name="$(basename "$catalog" .sh)"
  keys="$(catalog_keys "$catalog")"
  only_en="$(comm -23 <(cut -f1 <<<"$en_keys") <(cut -f1 <<<"$keys"))"
  only_here="$(comm -13 <(cut -f1 <<<"$en_keys") <(cut -f1 <<<"$keys"))"
  wrong_args="$(join -t $'\t' <(echo "$en_keys") <(echo "$keys") | awk -F'\t' '$2 != $3 { print $1 }')"
  [[ -z "$only_en" ]] || fail "$name: missing keys (falls back to English): $(tr '\n' ' ' <<<"$only_en")"
  [[ -z "$only_here" ]] || fail "$name: keys not in en.sh: $(tr '\n' ' ' <<<"$only_here")"
  [[ -z "$wrong_args" ]] || fail "$name: placeholders differ from en.sh in: $(tr '\n' ' ' <<<"$wrong_args")"
  [[ -n "$only_en$only_here$wrong_args" ]] || pass "$name: same keys and placeholders as en.sh"
done

echo "bootstrap.ps1"
# `irm | iex` turns a BOM into a stray U+FEFF that breaks parsing, and
# Windows PowerShell 5.1 reads BOM-less non-ASCII as ANSI: ASCII only.
if LC_ALL=C grep -q '[^[:print:][:space:]]' bootstrap.ps1; then
  fail "bootstrap.ps1 must be pure ASCII without BOM (write accents as \\uXXXX)"
else
  pass "bootstrap.ps1 is pure ASCII"
fi

echo "line endings"
crlf="$(git ls-files --eol 2>/dev/null | awk '$2 ~ /crlf/ { print $NF }')"
if [[ -z "$crlf" ]]; then pass "LF everywhere"; else fail "CRLF in: $(tr '\n' ' ' <<<"$crlf")"; fi

echo
if ((failures)); then
  printf '\e[31m%d check(s) failed\e[0m\n' "$failures"
else
  printf '\e[32mall checks passed\e[0m\n'
fi
exit "$failures"
