#!/bin/bash
# Deploy de App React/TypeScript no aaPanel
# Usage: bash deploy-react-app.sh <domain> <build_zip_url>
#
# Exemplo:
#   bash deploy-react-app.sh meusite.com https://github.com/user/repo/releases/download/v1/dist.zip

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
API="bash ${SCRIPT_DIR}/../scripts/aapanel_api.sh"

DOMAIN="${1:?Uso: bash deploy-react-app.sh <domain> <build_zip_url>}"
ZIP_URL="${2:?Uso: bash deploy-react-app.sh <domain> <build_zip_url>}"
APP_PATH="/www/wwwroot/${DOMAIN}"

echo "=== Deploy React App: ${DOMAIN} ==="

# 1. Criar diretorio
echo "[1/6] Criando diretorio ${APP_PATH}..."
$API files CreateDir "{\"path\":\"${APP_PATH}\"}"

# 2. Download do build
echo "[2/6] Baixando build..."
$API files DownloadFile "{\"url\":\"${ZIP_URL}\",\"path\":\"${APP_PATH}\",\"filename\":\"dist.zip\"}"

# 3. Extrair
echo "[3/6] Extraindo arquivos..."
$API files UnZip "{\"sfile\":\"${APP_PATH}/dist.zip\",\"dfile\":\"${APP_PATH}\",\"type\":\"zip\"}"

# 4. Limpar ZIP
echo "[4/6] Limpando..."
$API files DeleteFile "{\"path\":\"${APP_PATH}/dist.zip\"}"

# 5. Criar site
echo "[5/6] Criando site no Nginx..."
$API site AddSite "{\"webname\":\"{\\\"domain\\\":\\\"${DOMAIN}\\\",\\\"domainlist\\\":[],\\\"count\\\":0}\",\"path\":\"${APP_PATH}\",\"type_id\":0,\"type\":\"PHP\",\"version\":\"00\",\"port\":\"80\",\"ps\":\"React App - ${DOMAIN}\"}"

# 6. SSL
echo "[6/6] Configurando SSL..."
$API ssl apply_cert_api "{\"domains\":[\"${DOMAIN}\"],\"auth_type\":\"http\"}"

echo ""
echo "=== Deploy concluido! ==="
echo "Site: https://${DOMAIN}"
echo ""
echo "NOTA: Configure o Nginx para SPA routing (try_files) se usar React Router."
