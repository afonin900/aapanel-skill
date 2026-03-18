#!/bin/bash
# Configurar backups automaticos diarios no aaPanel
# Usage: bash backup-automatico.sh [site_name] [db_name]
#
# Exemplo:
#   bash backup-automatico.sh meusite.com meu_db

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
API="bash ${SCRIPT_DIR}/../scripts/aapanel_api.sh"

SITE_NAME="${1:-}"
DB_NAME="${2:-}"

echo "=== Configuracao de Backups Automaticos ==="

if [ -n "$SITE_NAME" ]; then
    echo "[1] Criando backup diario do site: ${SITE_NAME}..."
    $API crontab AddCrontab "{\"name\":\"Backup Site ${SITE_NAME}\",\"type\":\"day\",\"hour\":\"3\",\"minute\":\"0\",\"sType\":\"site\",\"sName\":\"${SITE_NAME}\",\"backupTo\":\"localhost\",\"save\":\"7\"}"
    echo "    -> Backup do site configurado para 03:00, mantendo 7 copias."
fi

if [ -n "$DB_NAME" ]; then
    echo "[2] Criando backup diario do banco: ${DB_NAME}..."
    $API crontab AddCrontab "{\"name\":\"Backup DB ${DB_NAME}\",\"type\":\"day\",\"hour\":\"3\",\"minute\":\"30\",\"sType\":\"database\",\"sName\":\"${DB_NAME}\",\"backupTo\":\"localhost\",\"save\":\"7\"}"
    echo "    -> Backup do banco configurado para 03:30, mantendo 7 copias."
fi

if [ -z "$SITE_NAME" ] && [ -z "$DB_NAME" ]; then
    echo "Nenhum site ou banco especificado."
    echo "Uso: bash backup-automatico.sh [site_name] [db_name]"
    echo ""
    echo "Exemplos:"
    echo "  bash backup-automatico.sh meusite.com meu_db  # Ambos"
    echo "  bash backup-automatico.sh meusite.com          # So site"
    echo "  bash backup-automatico.sh '' meu_db            # So banco"
    exit 1
fi

echo ""
echo "=== Backups configurados! ==="
echo "Verifique em: bash scripts/aapanel_api.sh crontab GetCrontab"
