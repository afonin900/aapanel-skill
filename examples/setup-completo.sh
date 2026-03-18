#!/bin/bash
# Setup completo: React + TypeScript + Supabase Cloud + aaPanel
# Usage: bash setup-completo.sh <domain> <build_zip_url> <supabase_url> <supabase_key>
#
# Exemplo:
#   bash setup-completo.sh meusite.com https://url/dist.zip https://xxxx.supabase.co eyJhbGciOi...

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
API="bash ${SCRIPT_DIR}/../scripts/aapanel_api.sh"

DOMAIN="${1:?Uso: bash setup-completo.sh <domain> <build_zip_url> <supabase_url> <supabase_key>}"
ZIP_URL="${2:?Informe a URL do build ZIP}"
SUPABASE_URL="${3:?Informe a URL do Supabase}"
SUPABASE_KEY="${4:?Informe a Anon Key do Supabase}"
APP_PATH="/www/wwwroot/${DOMAIN}"

echo "============================================"
echo "  Setup Completo: ${DOMAIN}"
echo "============================================"
echo ""

# 1. Verificar sistema
echo "[1/10] Verificando sistema..."
$API system GetSystemTotal
echo ""

# 2. Instalar Node.js
echo "[2/10] Garantindo Node.js instalado..."
$API plugin install_plugin '{"sName":"nodejs","version":"20"}'
echo ""

# 3. Criar diretorio
echo "[3/10] Criando ${APP_PATH}..."
$API files CreateDir "{\"path\":\"${APP_PATH}\"}"
echo ""

# 4. Download build
echo "[4/10] Baixando build..."
$API files DownloadFile "{\"url\":\"${ZIP_URL}\",\"path\":\"${APP_PATH}\",\"filename\":\"dist.zip\"}"
echo ""

# 5. Extrair
echo "[5/10] Extraindo..."
$API files UnZip "{\"sfile\":\"${APP_PATH}/dist.zip\",\"dfile\":\"${APP_PATH}\",\"type\":\"zip\"}"
$API files DeleteFile "{\"path\":\"${APP_PATH}/dist.zip\"}"
echo ""

# 6. Configurar .env
echo "[6/10] Configurando variaveis de ambiente..."
$API files SaveFileBody "{\"path\":\"${APP_PATH}/.env\",\"data\":\"VITE_SUPABASE_URL=${SUPABASE_URL}\\nVITE_SUPABASE_ANON_KEY=${SUPABASE_KEY}\\nNODE_ENV=production\",\"encoding\":\"utf-8\"}"
echo ""

# 7. Criar site
echo "[7/10] Criando site Nginx..."
$API site AddSite "{\"webname\":\"{\\\"domain\\\":\\\"${DOMAIN}\\\",\\\"domainlist\\\":[],\\\"count\\\":0}\",\"path\":\"${APP_PATH}\",\"type_id\":0,\"type\":\"PHP\",\"version\":\"00\",\"port\":\"80\",\"ps\":\"React+Supabase - ${DOMAIN}\"}"
echo ""

# 8. SSL
echo "[8/10] Configurando SSL..."
$API ssl apply_cert_api "{\"domains\":[\"${DOMAIN}\"],\"auth_type\":\"http\"}"
echo ""

# 9. Backup automatico
echo "[9/10] Configurando backup..."
$API crontab AddCrontab "{\"name\":\"Backup ${DOMAIN}\",\"type\":\"day\",\"hour\":\"3\",\"minute\":\"0\",\"sType\":\"site\",\"sName\":\"${DOMAIN}\",\"backupTo\":\"localhost\",\"save\":\"7\"}"
echo ""

# 10. Status final
echo "[10/10] Verificando..."
$API system GetNetWork
echo ""

echo "============================================"
echo "  Deploy concluido!"
echo "============================================"
echo ""
echo "  Site:     https://${DOMAIN}"
echo "  Supabase: ${SUPABASE_URL}"
echo "  Backups:  Diarios as 03:00 (7 copias)"
echo ""
echo "  Proximos passos:"
echo "  1. Verifique se o DNS de ${DOMAIN} aponta para 168.231.92.99"
echo "  2. Configure SPA routing no Nginx (try_files)"
echo "  3. Teste o acesso: curl -I https://${DOMAIN}"
echo "============================================"
