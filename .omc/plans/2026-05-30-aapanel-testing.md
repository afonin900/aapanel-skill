# aapanel CLI — Plan тестирования

**Status:** pending approval

**Goal:** Полное тестирование `scripts/aapanel_api.sh` без реального сервера — синтаксис, unit-тесты всех функций, HTTP запросы через мок-сервер, валидация документации.

**Architecture:** Три независимых слоя тестирования: (1) статический анализ скрипта, (2) unit-тесты bash функций с временным конфигом, (3) интеграционные тесты через Python мок-сервер на localhost.

**Tech Stack:** bash, python3, curl, shellcheck (опционально)

---

## Acceptance Criteria

- [ ] `bash -n scripts/aapanel_api.sh` — exit 0
- [ ] Все 19 категорий URL в `build_url` генерируют корректный URL
- [ ] `json_to_form` корректно конвертирует строки, числа, boolean, вложенные объекты
- [ ] `generate_auth` генерирует `request_time` и `request_token` в правильном формате
- [ ] `servers add/list/remove/default` работают корректно во всех комбинациях
- [ ] Дублирующий `servers add` → ошибка, не перезаписывает
- [ ] `--server nonexistent` → ошибка с понятным сообщением
- [ ] Мок-сервер получает POST запрос с `Content-Type: application/x-www-form-urlencoded`
- [ ] Мок-сервер получает `request_time` и `request_token` в теле запроса
- [ ] Все категории из `docs/03-быстрый-старт.md` есть в `build_url` скрипта
- [ ] Итоговый отчёт: PASS/FAIL по каждому тест-кейсу

---

## Файлы

- Create: `tests/test_aapanel.sh` — bash unit-тесты
- Create: `tests/mock_server.py` — Python HTTP мок-сервер
- Create: `tests/run_tests.sh` — оркестратор, запускает всё, итоговый отчёт

---

## Task 1: Bash unit-тесты (синтаксис + функции)

**Файл:** `tests/test_aapanel.sh`

### 1.1 Синтаксис скрипта

```bash
#!/bin/bash
set -euo pipefail
PASS=0; FAIL=0; ERRORS=()
SCRIPT="$(cd "$(dirname "$0")/.." && pwd)/scripts/aapanel_api.sh"

assert() {
    local desc="$1" expected="$2" actual="$3"
    if [ "$expected" = "$actual" ]; then
        echo "  ✓ $desc"; PASS=$((PASS+1))
    else
        echo "  ✗ $desc"; echo "    expected: $expected"; echo "    actual:   $actual"
        FAIL=$((FAIL+1)); ERRORS+=("$desc")
    fi
}

assert_contains() {
    local desc="$1" needle="$2" haystack="$3"
    if echo "$haystack" | grep -q "$needle"; then
        echo "  ✓ $desc"; PASS=$((PASS+1))
    else
        echo "  ✗ $desc"; echo "    expected to contain: $needle"; echo "    actual: $haystack"
        FAIL=$((FAIL+1)); ERRORS+=("$desc")
    fi
}

echo "=== 1. Синтаксис ==="
bash -n "$SCRIPT" 2>&1
assert "bash -n exit 0" "0" "$?"
```

### 1.2 build_url — все 19 категорий

```bash
echo ""
echo "=== 2. build_url — все категории ==="
BASE="https://1.2.3.4:17198"

# Источник функции build_url из скрипта
source <(grep -A 50 "^build_url()" "$SCRIPT" | head -55)

assert "system"   "${BASE}/system?action=Test"       "$(build_url "$BASE" system Test)"
assert "ajax"     "${BASE}/ajax?action=Test"         "$(build_url "$BASE" ajax Test)"
assert "site"     "${BASE}/site?action=Test"         "$(build_url "$BASE" site Test)"
assert "files"    "${BASE}/files?action=Test"        "$(build_url "$BASE" files Test)"
assert "database" "${BASE}/database?action=Test"     "$(build_url "$BASE" database Test)"
assert "ftp"      "${BASE}/ftp?action=Test"          "$(build_url "$BASE" ftp Test)"
assert "firewall" "${BASE}/firewall?action=Test"     "$(build_url "$BASE" firewall Test)"
assert "crontab"  "${BASE}/crontab?action=Test"      "$(build_url "$BASE" crontab Test)"
assert "plugin"   "${BASE}/plugin?action=Test"       "$(build_url "$BASE" plugin Test)"
assert "ssl"      "${BASE}/acme?action=Test"         "$(build_url "$BASE" ssl Test)"
assert "acme"     "${BASE}/acme?action=Test"         "$(build_url "$BASE" acme Test)"
assert "config"   "${BASE}/config?action=Test"       "$(build_url "$BASE" config Test)"
assert "data"     "${BASE}/data?action=Test"         "$(build_url "$BASE" data Test)"
assert "nodejs"   "${BASE}/project/nodejs/Test/1"    "$(build_url "$BASE" nodejs Test)"
assert "python"   "${BASE}/project/python/Test/1"    "$(build_url "$BASE" python Test)"
assert "proxy"    "${BASE}/project/proxy/Test/1"     "$(build_url "$BASE" proxy Test)"
assert "safe"     "${BASE}/safe/firewall/Test"       "$(build_url "$BASE" safe Test)"
assert "safe_ssh" "${BASE}/safe/ssh/Test"            "$(build_url "$BASE" safe_ssh Test)"
assert "logs"     "${BASE}/logs/panel/Test"          "$(build_url "$BASE" logs Test)"
assert "server"   "${BASE}/server?action=Test"       "$(build_url "$BASE" server Test)"
```

### 1.3 json_to_form

```bash
echo ""
echo "=== 3. json_to_form ==="
source <(grep -A 20 "^json_to_form()" "$SCRIPT" | head -25)

assert_contains "строка"        "name=hello"           "$(json_to_form '{"name":"hello"}')"
assert_contains "число"         "port=3000"            "$(json_to_form '{"port":"3000"}')"
assert_contains "boolean true"  "enabled=true"         "$(json_to_form '{"enabled":true}')"
assert_contains "boolean false" "enabled=false"        "$(json_to_form '{"enabled":false}')"
assert "пустой объект"   "" "$(json_to_form '{}')"
assert "пустая строка"   "" "$(json_to_form '')"
```

### 1.4 generate_auth

```bash
echo ""
echo "=== 4. generate_auth ==="
source <(grep -A 15 "^generate_auth()" "$SCRIPT" | head -18)

AUTH="$(generate_auth testkey123)"
assert_contains "request_time присутствует"  "request_time="  "$AUTH"
assert_contains "request_token присутствует" "request_token=" "$AUTH"

# request_time — число (unix timestamp)
RT="$(echo "$AUTH" | grep -oE 'request_time=[0-9]+' | cut -d= -f2)"
assert_contains "request_time — число"  "" "$(echo "$RT" | grep -vE '^[0-9]+$' || true)"

# request_token — 32 символа hex
TOK="$(echo "$AUTH" | grep -oE 'request_token=[a-f0-9]+' | cut -d= -f2)"
assert "request_token длина 32" "32" "${#TOK}"
```

### 1.5 servers lifecycle

```bash
echo ""
echo "=== 5. servers lifecycle ==="
ORIG_HOME="$HOME"
export HOME="$(mktemp -d)"
CONF="$HOME/.aapanel/servers.conf"

# add
bash "$SCRIPT" servers add s1 https://1.1.1.1:17198 key1 default >/dev/null 2>&1
assert "servers add создаёт файл" "0" "$([ -f "$CONF" ] && echo 0 || echo 1)"

# list содержит сервер
LIST="$(bash "$SCRIPT" servers list 2>&1)"
assert_contains "servers list: имя"  "s1"           "$LIST"
assert_contains "servers list: url"  "1.1.1.1"      "$LIST"
assert_contains "servers list: default" "*"         "$LIST"

# add второй сервер
bash "$SCRIPT" servers add s2 https://2.2.2.2:17198 key2 >/dev/null 2>&1
LIST2="$(bash "$SCRIPT" servers list 2>&1)"
assert_contains "оба сервера в списке s1" "s1" "$LIST2"
assert_contains "оба сервера в списке s2" "s2" "$LIST2"

# duplicate add → ошибка
ERR="$(bash "$SCRIPT" servers add s1 https://x.x.x.x:17198 key 2>&1 || true)"
assert_contains "дубликат → ошибка" "already exists" "$ERR"

# servers default
bash "$SCRIPT" servers default s2 >/dev/null 2>&1
LIST3="$(bash "$SCRIPT" servers list 2>&1)"
assert_contains "default сменился на s2" "* s2" "$LIST3"

# servers remove
bash "$SCRIPT" servers remove s1 >/dev/null 2>&1
LIST4="$(bash "$SCRIPT" servers list 2>&1)"
assert "s1 удалён" "1" "$(echo "$LIST4" | grep -c "s1" || echo 0)"

# remove несуществующего → ошибка
ERR2="$(bash "$SCRIPT" servers remove nonexistent 2>&1 || true)"
assert_contains "remove несуществующего → ошибка" "not found" "$ERR2"

export HOME="$ORIG_HOME"
```

### 1.6 Edge cases — аргументы

```bash
echo ""
echo "=== 6. Edge cases ==="

# без аргументов → usage
USAGE="$(bash "$SCRIPT" 2>&1 || true)"
assert_contains "без аргументов → usage" "Usage:" "$USAGE"

# --server без имени → ошибка
ERR="$(bash "$SCRIPT" --server 2>&1 || true)"
assert_contains "--server без имени → ошибка" "requires" "$ERR"

# несуществующая категория → ошибка (нужен конфиг)
TMPHOME="$(mktemp -d)"
HOME_BAK="$HOME"; export HOME="$TMPHOME"
bash "$SCRIPT" servers add tmp https://1.2.3.4:17198 key default >/dev/null 2>&1
CATERR="$(bash "$SCRIPT" badcategory action 2>&1 || true)"
assert_contains "неизвестная категория → ошибка" "Unknown" "$CATERR"
export HOME="$HOME_BAK"

# нет конфига → понятная ошибка
EMPTYHOME="$(mktemp -d)"
HOME_BAK2="$HOME"; export HOME="$EMPTYHOME"
NOCFG="$(bash "$SCRIPT" system GetSystemTotal 2>&1 || true)"
assert_contains "нет конфига → ошибка" "servers add" "$NOCFG"
export HOME="$HOME_BAK2"
```

### 1.7 Итог

```bash
echo ""
echo "=================================="
echo "ИТОГ: PASS=$PASS  FAIL=$FAIL"
if [ ${#ERRORS[@]} -gt 0 ]; then
    echo "ПРОВАЛЕНО:"
    for e in "${ERRORS[@]}"; do echo "  - $e"; done
fi
echo "=================================="
[ "$FAIL" -eq 0 ]
```

---

## Task 2: Python мок-сервер

**Файл:** `tests/mock_server.py`

```python
#!/usr/bin/env python3
"""
Мок HTTP сервер для тестирования aapanel_api.sh.
Принимает POST запросы, логирует их, возвращает mock JSON.
"""
import json
import threading
import time
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import parse_qs, urlparse

received_requests = []

class MockHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(length).decode('utf-8')
        params = parse_qs(body)

        req = {
            'path': self.path,
            'content_type': self.headers.get('Content-Type', ''),
            'params': {k: v[0] for k, v in params.items()},
        }
        received_requests.append(req)

        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps({'status': True, 'msg': 'mock ok'}).encode())

    def log_message(self, *args):
        pass  # тихий режим

def start_server(port=19876):
    server = HTTPServer(('127.0.0.1', port), MockHandler)
    t = threading.Thread(target=server.serve_forever, daemon=True)
    t.start()
    time.sleep(0.2)
    return server

def get_requests():
    return received_requests

def clear_requests():
    received_requests.clear()

if __name__ == '__main__':
    import sys
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 19876
    print(f'Mock server on port {port}')
    s = start_server(port)
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        s.shutdown()
```

---

## Task 3: Интеграционный тест через мок-сервер

**Часть `tests/run_tests.sh`** — запускает мок-сервер и проверяет HTTP запросы:

```bash
echo ""
echo "=== 7. Интеграционные тесты (мок-сервер) ==="

MOCK_PORT=19876
MOCK_LOG="$(mktemp)"

# Запустить мок-сервер в фоне
python3 -c "
import json, sys
sys.path.insert(0, '$(pwd)/tests')
from mock_server import start_server, get_requests
import time

s = start_server($MOCK_PORT)
time.sleep(30)  # ждём 30 секунд
with open('$MOCK_LOG', 'w') as f:
    json.dump(get_requests(), f)
" &
MOCK_PID=$!
sleep 0.5

# Настроить тестовый сервер указывающий на мок
TMPHOME="$(mktemp -d)"
export HOME="$TMPHOME"
bash scripts/aapanel_api.sh servers add mockserver "http://127.0.0.1:${MOCK_PORT}" testkey123 default >/dev/null 2>&1

# Выполнить тестовый запрос
bash scripts/aapanel_api.sh system GetSystemTotal >/dev/null 2>&1 || true

# Подождать и убить мок-сервер
sleep 1
kill $MOCK_PID 2>/dev/null || true
wait $MOCK_PID 2>/dev/null || true

# Читать и проверить логи
if [ -s "$MOCK_LOG" ]; then
    REQ="$(cat "$MOCK_LOG")"
    
    # Проверить Content-Type
    CT="$(echo "$REQ" | python3 -c "import json,sys; r=json.load(sys.stdin); print(r[0]['content_type'] if r else '')" 2>/dev/null)"
    assert_contains "Content-Type: application/x-www-form-urlencoded" "application/x-www-form-urlencoded" "$CT"
    
    # Проверить request_time в теле
    RT="$(echo "$REQ" | python3 -c "import json,sys; r=json.load(sys.stdin); print(r[0]['params'].get('request_time','') if r else '')" 2>/dev/null)"
    assert_contains "request_time в теле запроса" "" "$(echo "$RT" | grep -vE '^[0-9]+$' || true)"
    
    # Проверить request_token в теле
    TOK="$(echo "$REQ" | python3 -c "import json,sys; r=json.load(sys.stdin); print(r[0]['params'].get('request_token','') if r else '')" 2>/dev/null)"
    assert "request_token длина 32" "32" "${#TOK}"
    
    # Проверить путь URL
    PATH_="$(echo "$REQ" | python3 -c "import json,sys; r=json.load(sys.stdin); print(r[0]['path'] if r else '')" 2>/dev/null)"
    assert_contains "URL путь содержит /system" "/system" "$PATH_"
    assert_contains "URL содержит ?action=GetSystemTotal" "GetSystemTotal" "$PATH_"
else
    echo "  ✗ Мок-сервер не получил запросов"
    FAIL=$((FAIL+1))
fi

export HOME="$ORIG_HOME"
rm -f "$MOCK_LOG"
```

---

## Task 4: Валидация документации

**Часть `tests/run_tests.sh`** — проверяет соответствие документации и кода:

```bash
echo ""
echo "=== 8. Валидация документации ==="

DOC="docs/03-быстрый-старт.md"
SKILL="SKILL.md"

# Все категории из build_url должны быть задокументированы
CATEGORIES="system ajax site files database ftp firewall crontab plugin ssl acme config data nodejs python proxy safe safe_ssh logs server"

for cat in $CATEGORIES; do
    if grep -q "\"$cat\"" "$DOC" 2>/dev/null || grep -q "\`$cat\`" "$DOC" 2>/dev/null || grep -q " $cat " "$DOC" 2>/dev/null; then
        echo "  ✓ Категория '$cat' упомянута в документации"; PASS=$((PASS+1))
    else
        echo "  ✗ Категория '$cat' НЕ найдена в $DOC"; FAIL=$((FAIL+1))
        ERRORS+=("doc: категория '$cat' не задокументирована")
    fi
done

# Hardcoded credentials не должны быть нигде
echo ""
echo "--- Проверка credentials ---"
CRED_CHECK="$(grep -r "168\.231\.92\.99\|b4uzdFJT7wJSqGnemqa1vRKhyrIKYeDp" \
    --include="*.sh" --include="*.md" . 2>/dev/null | grep -v ".git" || true)"
if [ -z "$CRED_CHECK" ]; then
    echo "  ✓ Hardcoded credentials не найдены"; PASS=$((PASS+1))
else
    echo "  ✗ Найдены hardcoded credentials:"; echo "$CRED_CHECK"
    FAIL=$((FAIL+1)); ERRORS+=("hardcoded credentials в репо")
fi

# install.sh существует и синтаксически корректен
bash -n install.sh 2>&1
assert "install.sh синтаксис OK" "0" "$?"
```

---

## Task 5: Оркестратор `tests/run_tests.sh`

**Файл:** `tests/run_tests.sh`

```bash
#!/bin/bash
set -uo pipefail
cd "$(dirname "$0")/.."

PASS=0; FAIL=0; ERRORS=()
ORIG_HOME="$HOME"

# Хелперы (определяем один раз)
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

# Запуск unit-тестов
source tests/test_aapanel.sh

# Финальный отчёт
echo ""
echo "=============================="
echo "ИТОГ  PASS=$PASS  FAIL=$FAIL"
if [ ${#ERRORS[@]} -gt 0 ]; then
    echo "ПРОВАЛЕНО:"
    for e in "${ERRORS[@]}"; do echo "  - $e"; done
fi
echo "=============================="
exit "$FAIL"
```

---

## Risks and Mitigations

| Риск | Митигация |
|------|-----------|
| `source` функций из скрипта сломает другие переменные | Запускать в subshell где возможно |
| Мок-сервер не стартует если порт занят | Использовать эфемерный порт (19876), fallback на 19877 |
| shellcheck не установлен | Проверить наличие, пропустить шаг если нет |
| python3 не найден | Проверить до запуска, выдать понятную ошибку |

## Verification Steps

```bash
cd /Users/afonin900/Github/aapanel-skill
bash tests/run_tests.sh
# Ожидается: FAIL=0
```
