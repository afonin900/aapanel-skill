#!/bin/bash
# Setup Supabase Self-hosted via Docker no aaPanel
# Usage: bash setup-supabase-docker.sh <postgres_password> <jwt_secret>
#
# Exemplo:
#   bash setup-supabase-docker.sh "MinhaSenhaForte123!" "meu-jwt-secret-com-32-chars-minimo"

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
API="bash ${SCRIPT_DIR}/../scripts/aapanel_api.sh"

POSTGRES_PASSWORD="${1:?Uso: bash setup-supabase-docker.sh <postgres_password> <jwt_secret>}"
JWT_SECRET="${2:?Uso: bash setup-supabase-docker.sh <postgres_password> <jwt_secret>}"

echo "=== Setup Supabase Self-hosted ==="

# 1. Verificar/instalar Docker
echo "[1/7] Verificando Docker..."
$API plugin install_plugin '{"sName":"docker","version":"latest"}'

# 2. Criar diretorio
echo "[2/7] Criando /opt/supabase..."
$API files CreateDir '{"path":"/opt/supabase"}'

# 3. Download docker-compose
echo "[3/7] Baixando docker-compose.yml..."
$API files DownloadFile '{"url":"https://raw.githubusercontent.com/supabase/supabase/master/docker/docker-compose.yml","path":"/opt/supabase","filename":"docker-compose.yml"}'

# 4. Download .env
echo "[4/7] Baixando .env..."
$API files DownloadFile '{"url":"https://raw.githubusercontent.com/supabase/supabase/master/docker/.env.example","path":"/opt/supabase","filename":".env"}'

# 5. Configurar .env
echo "[5/7] Configurando variaveis..."
$API files SaveFileBody "{\"path\":\"/opt/supabase/.env\",\"data\":\"POSTGRES_PASSWORD=${POSTGRES_PASSWORD}\\nJWT_SECRET=${JWT_SECRET}\\nANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9\\nSERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9\\nSITE_URL=http://localhost:3000\\nAPI_EXTERNAL_URL=http://localhost:8000\",\"encoding\":\"utf-8\"}"

# 6. Abrir portas
echo "[6/7] Abrindo portas no firewall..."
$API firewall AddAcceptPort '{"port":"5432","type":"tcp","ps":"PostgreSQL - Supabase"}'
$API firewall AddAcceptPort '{"port":"8000","type":"tcp","ps":"Supabase API Gateway"}'
$API firewall AddAcceptPort '{"port":"3000","type":"tcp","ps":"Supabase Studio"}'

# 7. Criar cron para auto-start
echo "[7/7] Configurando auto-start..."
$API crontab AddCrontab '{"name":"Start Supabase","type":"startUp","sBody":"cd /opt/supabase && docker compose up -d","sType":"toShell"}'

echo ""
echo "=== Supabase configurado! ==="
echo ""
echo "Para iniciar agora, execute o cron job criado ou acesse o servidor via SSH:"
echo "  cd /opt/supabase && docker compose up -d"
echo ""
echo "Acessos:"
echo "  Studio:     http://YOUR_SERVER_IP:3000"
echo "  API:        http://YOUR_SERVER_IP:8000"
echo "  PostgreSQL: YOUR_SERVER_IP:5432"
echo ""
echo "IMPORTANTE: Gere JWT keys reais em https://supabase.com/docs/guides/self-hosting#api-keys"
