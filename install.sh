#!/bin/bash
# install.sh — устанавливает `aapanel` как глобальную команду
# Запуск из корня репозитория: bash install.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="${SCRIPT_DIR}/scripts/aapanel_api.sh"
SYSTEM_BIN="/usr/local/bin"
USER_BIN="${HOME}/.local/bin"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info() { echo -e "${GREEN}[+]${NC} $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $*"; }
error() { echo -e "${RED}[x]${NC} $*" >&2; }

if [ ! -f "$SOURCE" ]; then
    error "Файл не найден: $SOURCE"
    error "Запустите из корня репозитория: bash install.sh"
    exit 1
fi

# Выбираем место установки
if [ "$(id -u)" = "0" ] || sudo -n true 2>/dev/null; then
    DEST="${SYSTEM_BIN}/aapanel"
    USE_SUDO=true
else
    warn "Нет прав sudo — устанавливаем в ${USER_BIN}"
    DEST="${USER_BIN}/aapanel"
    USE_SUDO=false
    mkdir -p "$USER_BIN"
fi

# Устанавливаем
if [ "$USE_SUDO" = true ]; then
    sudo cp "$SOURCE" "$DEST"
    sudo chmod +x "$DEST"
else
    cp "$SOURCE" "$DEST"
    chmod +x "$DEST"
fi

info "Установлено: ${DEST}"

# Проверка PATH
DEST_DIR="$(dirname "$DEST")"
if ! echo "$PATH" | tr ':' '\n' | grep -qx "$DEST_DIR"; then
    warn "Директория ${DEST_DIR} не в PATH. Добавьте в ~/.bashrc или ~/.zshrc:"
    warn "  export PATH=\"${DEST_DIR}:\${PATH}\""
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN} aapanel CLI успешно установлен!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Добавьте сервер:"
echo "  aapanel servers add hetzner https://YOUR_IP:17198 YOUR_API_KEY default"
echo ""
echo "Список серверов:"
echo "  aapanel servers list"
echo ""
echo "Пример запроса:"
echo "  aapanel --server hetzner system GetSystemTotal"
echo "  aapanel system GetSystemTotal   # использует сервер по умолчанию"
echo ""
echo "Конфиг серверов: ~/.aapanel/servers.conf"
echo ""
