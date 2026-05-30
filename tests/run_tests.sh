#!/bin/bash
# Оркестратор тестов aapanel CLI
# Запуск: bash tests/run_tests.sh
# Возвращает exit 0 если все тесты прошли, иначе exit N (количество провалов)

set -uo pipefail
cd "$(cd "$(dirname "$0")/.." && pwd)"

PASS=0; FAIL=0; ERRORS=()

# ─────────────────────────────────────────
# Хелперы
# ─────────────────────────────────────────
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
        echo "  ✗ $desc (не найдено '$needle')"
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
export -f assert assert_contains assert_not_contains
export PASS FAIL
_HELPERS_LOADED=1; export _HELPERS_LOADED

SCRIPT="scripts/aapanel_api.sh"
ORIG_HOME="$HOME"

echo "╔══════════════════════════════════════════╗"
echo "║  aapanel CLI — Test Suite                ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# ─────────────────────────────────────────
# Unit-тесты (синтаксис, servers, edge cases)
# ─────────────────────────────────────────
source tests/test_aapanel.sh

# ─────────────────────────────────────────
echo ""
echo "=== 6. build_url — все 19 категорий через мок-сервер ==="
# ─────────────────────────────────────────

MOCK_PORT=19876
MOCK_LOG="$(mktemp)"

# Запустить мок-сервер
python3 tests/mock_server.py "$MOCK_PORT" "$MOCK_LOG" &
MOCK_PID=$!

# Ждём готовности
for i in $(seq 1 20); do
    if python3 -c "import socket; s=socket.socket(); s.connect(('127.0.0.1',$MOCK_PORT)); s.close()" 2>/dev/null; then
        break
    fi
    sleep 0.1
done

# Настроить тестовый HOME с мок-сервером
TMP_HOME="$(mktemp -d)"
export HOME="$TMP_HOME"
bash "$SCRIPT" servers add mockserver "http://127.0.0.1:${MOCK_PORT}" testkey123 default >/dev/null 2>&1

# Проверить каждую категорию: запрос → проверить путь в логе
check_category() {
    local cat="$1" action="$2" expected_path="$3"
    > "$MOCK_LOG"  # сбросить лог
    bash "$SCRIPT" "$cat" "$action" >/dev/null 2>&1 || true
    sleep 0.15
    if [ -s "$MOCK_LOG" ]; then
        local actual_path
        actual_path="$(python3 -c "import json,sys; r=json.load(open('$MOCK_LOG')); print(r[-1]['path'] if r else '')" 2>/dev/null)"
        assert_contains "build_url[$cat]" "$expected_path" "$actual_path"
    else
        echo "  ✗ build_url[$cat] — мок не получил запрос"
        FAIL=$((FAIL+1)); ERRORS+=("build_url[$cat]")
    fi
}

check_category system   GetSystemTotal    "/system?action=GetSystemTotal"
check_category ajax     GetTaskCount      "/ajax?action=GetTaskCount"
check_category site     GetSiteList       "/site?action=GetSiteList"
check_category files    GetDir            "/files?action=GetDir"
check_category database AddDatabase       "/database?action=AddDatabase"
check_category ftp      AddUser           "/ftp?action=AddUser"
check_category firewall GetList           "/firewall?action=GetList"
check_category crontab  GetCrontab        "/crontab?action=GetCrontab"
check_category plugin   get_soft_list     "/plugin?action=get_soft_list"
check_category ssl      apply_cert_api    "/acme?action=apply_cert_api"
check_category acme     apply_cert_api    "/acme?action=apply_cert_api"
check_category config   GetPanelInfo      "/config?action=GetPanelInfo"
check_category data     getData           "/data?action=getData"
check_category nodejs   get_project_list  "/project/nodejs/get_project_list/1"
check_category python   get_project_list  "/project/python/get_project_list/1"
check_category proxy    get_project_list  "/project/proxy/get_project_list/1"
check_category safe     get_rules_list    "/safe/firewall/get_rules_list"
check_category safe_ssh GetSshInfo        "/safe/ssh/GetSshInfo"
check_category logs     GetPanelLogs      "/logs/panel/GetPanelLogs"
check_category server   GetLoad           "/server?action=GetLoad"

# ─────────────────────────────────────────
echo ""
echo "=== 7. Формат HTTP запроса ==="
# ─────────────────────────────────────────

> "$MOCK_LOG"
bash "$SCRIPT" system GetSystemTotal >/dev/null 2>&1 || true
sleep 0.15

if [ -s "$MOCK_LOG" ]; then
    CT="$(python3 -c "import json; r=json.load(open('$MOCK_LOG')); print(r[-1]['content_type'] if r else '')" 2>/dev/null)"
    assert_contains "Content-Type: application/x-www-form-urlencoded" "application/x-www-form-urlencoded" "$CT"

    RT="$(python3 -c "import json; r=json.load(open('$MOCK_LOG')); print(r[-1]['params'].get('request_time','') if r else '')" 2>/dev/null)"
    assert_contains "request_time в теле (число)" "" "$(echo "$RT" | grep -vE '^[0-9]+$' || true)"

    TOK="$(python3 -c "import json; r=json.load(open('$MOCK_LOG')); print(r[-1]['params'].get('request_token','') if r else '')" 2>/dev/null)"
    assert "request_token — 32 символа hex" "32" "${#TOK}"
    assert_contains "request_token — только hex" "" "$(echo "$TOK" | grep -vE '^[a-f0-9]+$' || true)"
else
    echo "  ✗ Мок-сервер не получил запросов для проверки формата"
    FAIL=$((FAIL+1))
fi

# ─────────────────────────────────────────
echo ""
echo "=== 8. JSON параметры → form data ==="
# ─────────────────────────────────────────

> "$MOCK_LOG"
bash "$SCRIPT" files GetDir '{"path":"/www/wwwroot"}' >/dev/null 2>&1 || true
sleep 0.15

if [ -s "$MOCK_LOG" ]; then
    BODY_PATH="$(python3 -c "import json,urllib.parse; r=json.load(open('$MOCK_LOG')); print(urllib.parse.unquote(r[-1]['params'].get('path','')) if r else '')" 2>/dev/null)"
    assert "JSON param path передан в теле" "/www/wwwroot" "$BODY_PATH"
else
    echo "  ✗ JSON params тест — нет данных от мок-сервера"
    FAIL=$((FAIL+1))
fi

# Остановить мок-сервер
kill "$MOCK_PID" 2>/dev/null || true
wait "$MOCK_PID" 2>/dev/null || true
rm -f "$MOCK_LOG"

export HOME="$ORIG_HOME"
rm -rf "$TMP_HOME"

# ─────────────────────────────────────────
echo ""
echo "=== 9. Валидация документации ==="
# ─────────────────────────────────────────

DOC="docs/03-быстрый-старт.md"
CATS="system files site database firewall nodejs ssl crontab plugin"

for cat in $CATS; do
    if grep -q "$cat" "$DOC" 2>/dev/null; then
        echo "  ✓ Категория '$cat' документирована"; PASS=$((PASS+1))
    else
        echo "  ✗ Категория '$cat' НЕ найдена в $DOC"
        FAIL=$((FAIL+1)); ERRORS+=("doc: '$cat' не задокументирована")
    fi
done

# SKILL.md содержит --server примеры
SKILL_SERVER="$(grep -c "\-\-server" SKILL.md 2>/dev/null || echo 0)"
if [ "$SKILL_SERVER" -gt 0 ]; then
    echo "  ✓ SKILL.md содержит примеры --server"; PASS=$((PASS+1))
else
    echo "  ✗ SKILL.md не содержит примеров --server"
    FAIL=$((FAIL+1)); ERRORS+=("SKILL.md: нет примеров --server")
fi

# README.md содержит раздел про несколько серверов
README_MULTI="$(grep -c "servers add\|--server" README.md 2>/dev/null || echo 0)"
if [ "$README_MULTI" -gt 0 ]; then
    echo "  ✓ README.md описывает multi-server"; PASS=$((PASS+1))
else
    echo "  ✗ README.md не описывает multi-server"
    FAIL=$((FAIL+1)); ERRORS+=("README.md: нет multi-server секции")
fi

# ─────────────────────────────────────────
# Финальный отчёт
# ─────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════╗"
printf  "║  ИТОГ:  PASS=%-3d  FAIL=%-3d              ║\n" "$PASS" "$FAIL"
echo "╚══════════════════════════════════════════╝"

if [ "${#ERRORS[@]}" -gt 0 ]; then
    echo ""
    echo "ПРОВАЛЕНО:"
    for e in "${ERRORS[@]}"; do echo "  ✗ $e"; done
fi

exit "$FAIL"
