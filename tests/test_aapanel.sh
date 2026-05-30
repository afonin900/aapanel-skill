#!/bin/bash
# Unit-тесты aapanel_api.sh
# Запускается через tests/run_tests.sh (переменные PASS/FAIL/ERRORS определены там)
# или самостоятельно: bash tests/test_aapanel.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT="$SCRIPT_DIR/scripts/aapanel_api.sh"

# Если запускаем напрямую — определяем хелперы
if [ -z "${_HELPERS_LOADED:-}" ]; then
    PASS=0; FAIL=0; ERRORS=()
    assert() {
        local desc="$1" expected="$2" actual="$3"
        if [ "$expected" = "$actual" ]; then
            echo "  ✓ $desc"; PASS=$((PASS+1))
        else
            echo "  ✗ $desc (ожидалось: '$expected', получено: '$actual')"
            FAIL=$((FAIL+1)); ERRORS+=("$desc")
        fi
    }
    assert_contains() {
        local desc="$1" needle="$2" haystack="$3"
        if echo "$haystack" | grep -q "$needle"; then
            echo "  ✓ $desc"; PASS=$((PASS+1))
        else
            echo "  ✗ $desc (не найдено '$needle' в: $haystack)"
            FAIL=$((FAIL+1)); ERRORS+=("$desc")
        fi
    }
    assert_not_contains() {
        local desc="$1" needle="$2" haystack="$3"
        if ! echo "$haystack" | grep -q "$needle"; then
            echo "  ✓ $desc"; PASS=$((PASS+1))
        else
            echo "  ✗ $desc (найдено '$needle', не должно быть)"
            FAIL=$((FAIL+1)); ERRORS+=("$desc")
        fi
    }
fi

ORIG_HOME="${HOME}"

# ─────────────────────────────────────────
echo "=== 1. Синтаксис ==="
# ─────────────────────────────────────────

SYNTAX_OUT="$(bash -n "$SCRIPT" 2>&1)"
SYNTAX_EXIT=$?
assert "bash -n exit 0" "0" "$SYNTAX_EXIT"
assert "нет синтаксических ошибок" "" "$SYNTAX_OUT"

# ─────────────────────────────────────────
echo ""
echo "=== 2. servers — lifecycle ==="
# ─────────────────────────────────────────

TMP_HOME="$(mktemp -d)"
export HOME="$TMP_HOME"

# add первого сервера (default)
OUT="$(bash "$SCRIPT" servers add s1 https://1.1.1.1:17198 key1 default 2>&1)"
assert_contains "servers add: сообщение об успехе" "Added server" "$OUT"
assert "servers add: файл создан" "0" "$([ -f "$TMP_HOME/.aapanel/servers.conf" ] && echo 0 || echo 1)"

# list
LIST="$(bash "$SCRIPT" servers list 2>&1)"
assert_contains "servers list: имя s1"    "s1"       "$LIST"
assert_contains "servers list: URL"       "1.1.1.1"  "$LIST"
assert_contains "servers list: default *" "*"        "$LIST"

# add второго
bash "$SCRIPT" servers add s2 https://2.2.2.2:17198 key2 >/dev/null 2>&1
LIST2="$(bash "$SCRIPT" servers list 2>&1)"
assert_contains "два сервера: s1" "s1" "$LIST2"
assert_contains "два сервера: s2" "s2" "$LIST2"

# дубликат → ошибка
ERR="$(bash "$SCRIPT" servers add s1 https://x.x.x.x:17198 dupkey 2>&1 || true)"
assert_contains "дубликат → ошибка" "already exists" "$ERR"

# servers default
bash "$SCRIPT" servers default s2 >/dev/null 2>&1
LIST3="$(bash "$SCRIPT" servers list 2>&1)"
assert_contains "default сменился на s2" "* s2" "$LIST3"
assert_not_contains "s1 больше не default" "* s1" "$LIST3"

# servers remove
bash "$SCRIPT" servers remove s1 >/dev/null 2>&1
LIST4="$(bash "$SCRIPT" servers list 2>&1)"
assert "s1 удалён из списка" "0" "$(echo "$LIST4" | grep -c " s1")"

# remove несуществующего → ошибка
ERR2="$(bash "$SCRIPT" servers remove nonexistent 2>&1 || true)"
assert_contains "remove несуществующего → ошибка" "not found" "$ERR2"

export HOME="$ORIG_HOME"
rm -rf "$TMP_HOME"

# ─────────────────────────────────────────
echo ""
echo "=== 3. Аргументы и edge cases ==="
# ─────────────────────────────────────────

# без аргументов → usage
USAGE="$(bash "$SCRIPT" 2>&1 || true)"
assert_contains "без аргументов → Usage" "Usage:" "$USAGE"

# --server без имени → ошибка
ERR="$(bash "$SCRIPT" --server 2>&1 || true)"
assert_contains "--server без имени → ошибка" "requires" "$ERR"

# нет конфига → понятная ошибка
TMP2="$(mktemp -d)"
HOME="$TMP2" bash "$SCRIPT" system GetSystemTotal 2>/tmp/nocfg_err.txt || true
NOCFG="$(cat /tmp/nocfg_err.txt)"
assert_contains "нет конфига → подсказка" "servers add" "$NOCFG"
rm -rf "$TMP2" /tmp/nocfg_err.txt

# несуществующий --server → ошибка
TMP3="$(mktemp -d)"
HOME="$TMP3" bash "$SCRIPT" servers add real https://1.2.3.4:17198 k >/dev/null 2>&1
ERR3="$(HOME="$TMP3" bash "$SCRIPT" --server nonexistent system GetSystemTotal 2>&1 || true)"
assert_contains "--server несуществующий → ошибка" "not found" "$ERR3"
rm -rf "$TMP3"

# unknown category → ошибка
TMP4="$(mktemp -d)"
HOME="$TMP4" bash "$SCRIPT" servers add s https://1.2.3.4:17198 k >/dev/null 2>&1
ERR4="$(HOME="$TMP4" bash "$SCRIPT" badcat action 2>&1 || true)"
assert_contains "неизвестная категория → ошибка" "Unknown" "$ERR4"
rm -rf "$TMP4"

# ─────────────────────────────────────────
echo ""
echo "=== 4. Нет hardcoded credentials ==="
# ─────────────────────────────────────────

CRED="$(grep -r "168\.231\.92\.99\|b4uzdFJT7wJSqGnemqa1vRKhyrIKYeDp" \
    "$SCRIPT_DIR" --include="*.sh" --include="*.md" \
    --exclude-dir=".git" --exclude-dir=".omc" --exclude-dir="tests" 2>/dev/null || true)"
assert "нет hardcoded IP/key в .sh/.md" "" "$CRED"

# ─────────────────────────────────────────
echo ""
echo "=== 5. install.sh синтаксис ==="
# ─────────────────────────────────────────

INSTALL_OUT="$(bash -n "$SCRIPT_DIR/install.sh" 2>&1)"
INSTALL_EXIT=$?
assert "install.sh bash -n exit 0" "0" "$INSTALL_EXIT"
assert "install.sh нет синтаксических ошибок" "" "$INSTALL_OUT"

# Итог при самостоятельном запуске
if [ -z "${_HELPERS_LOADED:-}" ]; then
    echo ""
    echo "=============================="
    echo "ИТОГ  PASS=$PASS  FAIL=$FAIL"
    if [ "${#ERRORS[@]}" -gt 0 ]; then
        echo "ПРОВАЛЕНО:"
        for e in "${ERRORS[@]}"; do echo "  - $e"; done
    fi
    echo "=============================="
    exit "$FAIL"
fi
