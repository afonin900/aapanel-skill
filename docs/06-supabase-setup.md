# Configuracao do Supabase

Duas opcoes para usar Supabase com seu app React/TypeScript.

## Opcao 1: Supabase Cloud (Recomendado)

A forma mais simples e confiavel. O Supabase hospeda tudo para voce.

### Passo 1: Criar projeto

1. Acesse https://supabase.com/dashboard
2. Crie um novo projeto
3. Anote as credenciais:
   - `SUPABASE_URL` (ex: `https://xxxx.supabase.co`)
   - `SUPABASE_ANON_KEY` (ex: `eyJhbGciOi...`)

### Passo 2: Configurar no app

```typescript
// src/lib/supabase.ts
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY

export const supabase = createClient(supabaseUrl, supabaseKey)
```

### Passo 3: Deploy com variaveis

```bash
# Configurar .env no servidor
bash scripts/aapanel_api.sh files SaveFileBody '{
  "path": "/www/wwwroot/meu-app/.env",
  "data": "VITE_SUPABASE_URL=https://xxxx.supabase.co\nVITE_SUPABASE_ANON_KEY=eyJhbGciOi...",
  "encoding": "utf-8"
}'
```

### Vantagens do Cloud

- Zero manutencao de infraestrutura
- Backups automaticos
- CDN global
- Auth, Storage, Realtime inclusos
- Free tier generoso

---

## Opcao 2: Supabase Self-hosted (Docker)

Para ter controle total dos dados no seu servidor.

### Requisitos

- Minimo **2GB RAM** e **2 CPU cores**
- Docker instalado
- Portas disponiveis: 5432, 8000, 3000

### Passo 1: Instalar Docker

```bash
bash scripts/aapanel_api.sh plugin install_plugin '{"sName":"docker","version":"latest"}'
```

### Passo 2: Preparar diretorios

```bash
bash scripts/aapanel_api.sh files CreateDir '{"path":"/opt/supabase"}'
```

### Passo 3: Baixar arquivos do Supabase

```bash
# docker-compose.yml
bash scripts/aapanel_api.sh files DownloadFile '{
  "url": "https://raw.githubusercontent.com/supabase/supabase/master/docker/docker-compose.yml",
  "path": "/opt/supabase",
  "filename": "docker-compose.yml"
}'

# .env.example
bash scripts/aapanel_api.sh files DownloadFile '{
  "url": "https://raw.githubusercontent.com/supabase/supabase/master/docker/.env.example",
  "path": "/opt/supabase",
  "filename": ".env"
}'
```

### Passo 4: Configurar variaveis

```bash
bash scripts/aapanel_api.sh files SaveFileBody '{
  "path": "/opt/supabase/.env",
  "data": "POSTGRES_PASSWORD=sua-senha-segura-aqui\nJWT_SECRET=seu-jwt-secret-com-pelo-menos-32-caracteres\nANON_KEY=seu-anon-key\nSERVICE_ROLE_KEY=seu-service-role-key\nSITE_URL=https://meusite.com\nAPI_EXTERNAL_URL=https://api.meusite.com\nSTUDIO_DEFAULT_ORGANIZATION=Minha Org\nSTUDIO_DEFAULT_PROJECT=Meu Projeto",
  "encoding": "utf-8"
}'
```

### Passo 5: Abrir portas

```bash
# PostgreSQL
bash scripts/aapanel_api.sh firewall AddAcceptPort '{"port":"5432","type":"tcp","ps":"PostgreSQL - Supabase"}'

# API Gateway (Kong)
bash scripts/aapanel_api.sh firewall AddAcceptPort '{"port":"8000","type":"tcp","ps":"Supabase API"}'

# Studio (Dashboard)
bash scripts/aapanel_api.sh firewall AddAcceptPort '{"port":"3000","type":"tcp","ps":"Supabase Studio"}'
```

### Passo 6: Iniciar Supabase

Crie um cron job para iniciar no boot:

```bash
bash scripts/aapanel_api.sh crontab AddCrontab '{
  "name": "Start Supabase",
  "type": "startUp",
  "sBody": "cd /opt/supabase && docker compose up -d",
  "sType": "toShell"
}'
```

Execute imediatamente:

```bash
bash scripts/aapanel_api.sh crontab StartTask '{"id":ID_DA_TAREFA}'
```

### Passo 7: Conectar do app

```typescript
// src/lib/supabase.ts
import { createClient } from '@supabase/supabase-js'

// Para self-hosted, use o IP do servidor
const supabaseUrl = 'https://168.231.92.99:8000'
const supabaseKey = 'seu-anon-key'

export const supabase = createClient(supabaseUrl, supabaseKey)
```

### Gerenciamento

```bash
# Ver status dos containers (via cron)
bash scripts/aapanel_api.sh crontab AddCrontab '{
  "name": "Supabase Status",
  "type": "minute",
  "minute": "0",
  "hour": "",
  "sBody": "cd /opt/supabase && docker compose ps > /tmp/supabase-status.txt",
  "sType": "toShell"
}'

# Ler status
bash scripts/aapanel_api.sh files GetFileBody '{"path":"/tmp/supabase-status.txt"}'

# Reiniciar Supabase (criar e executar cron)
# sBody: "cd /opt/supabase && docker compose restart"

# Atualizar Supabase
# sBody: "cd /opt/supabase && docker compose pull && docker compose up -d"
```

---

## Comparacao

| Aspecto | Cloud | Self-hosted |
|---------|-------|-------------|
| Setup | 5 minutos | 30+ minutos |
| Manutencao | Zero | Voce gerencia |
| Custo | Free tier + planos | Apenas servidor |
| Performance | CDN global | Depende do servidor |
| Dados | Nos servidores Supabase | No seu servidor |
| Backups | Automaticos | Manual |
| Recomendado para | Maioria dos casos | Compliance, dados sensiveis |
