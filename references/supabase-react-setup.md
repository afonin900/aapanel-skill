# Guia: Supabase + React/TypeScript no aaPanel

## Opção 1: Supabase Cloud (Recomendado)

Usar Supabase hospedado (supabase.com) e conectar do app React no servidor.

### Passo a passo

1. **Criar projeto no Supabase Cloud:**
   - Acessar https://supabase.com/dashboard
   - Criar novo projeto
   - Anotar: `SUPABASE_URL` e `SUPABASE_ANON_KEY`

2. **Preparar o app React/TypeScript localmente:**
   ```bash
   npm create vite@latest meu-app -- --template react-ts
   cd meu-app
   npm install @supabase/supabase-js
   ```

3. **Configurar variáveis de ambiente:**
   ```env
   VITE_SUPABASE_URL=https://xxxx.supabase.co
   VITE_SUPABASE_ANON_KEY=eyJhbGciOi...
   ```

4. **Build do app:**
   ```bash
   npm run build
   ```

5. **Deploy no servidor via aaPanel:**

   a. Criar diretório:
   ```bash
   bash scripts/aapanel_api.sh files CreateDir '{"path":"/www/wwwroot/meu-app"}'
   ```

   b. Upload do build (zip o diretório `dist/`):
   ```bash
   bash scripts/aapanel_api.sh files DownloadFile '{"url":"URL_DO_ZIP","path":"/www/wwwroot/meu-app","filename":"dist.zip"}'
   bash scripts/aapanel_api.sh files UnZip '{"sfile":"/www/wwwroot/meu-app/dist.zip","dfile":"/www/wwwroot/meu-app","type":"zip"}'
   ```

   c. Criar site no Nginx para servir os arquivos estáticos:
   ```bash
   bash scripts/aapanel_api.sh site AddSite '{"webname":"{\"domain\":\"meusite.com\",\"domainlist\":[],\"count\":0}","path":"/www/wwwroot/meu-app/dist","type_id":0,"type":"PHP","version":"00","port":"80","ps":"React App"}'
   ```

   d. Configurar SSL:
   ```bash
   bash scripts/aapanel_api.sh ssl apply_cert_api '{"domains":["meusite.com"],"auth_type":"http"}'
   ```

### Para SSR/Next.js (Node.js):

Se o app usar SSR, criar como projeto Node.js:

```bash
# Criar projeto Node.js
bash scripts/aapanel_api.sh nodejs create_project '{"project_name":"meu-app","project_path":"/www/wwwroot/meu-app","run_script":"npm start","node_version":"20","port":"3000"}'

# Instalar dependências
bash scripts/aapanel_api.sh nodejs install_packages '{"project_name":"meu-app"}'

# Abrir porta no firewall
bash scripts/aapanel_api.sh firewall AddAcceptPort '{"port":"3000","type":"tcp","ps":"Next.js App"}'

# Configurar proxy reverso (Nginx → Node.js)
bash scripts/aapanel_api.sh nodejs bind_extranet '{"project_name":"meu-app"}'

# Iniciar
bash scripts/aapanel_api.sh nodejs start_project '{"project_name":"meu-app"}'
```

---

## Opção 2: Supabase Self-hosted (Docker)

### Requisitos
- Docker instalado no servidor
- Mínimo 2GB RAM, 2 CPU cores
- Portas: 5432 (PostgreSQL), 8000 (Kong API), 3000 (Studio)

### Passo a passo

1. **Instalar Docker via aaPanel:**
   ```bash
   bash scripts/aapanel_api.sh plugin install_plugin '{"sName":"docker","version":"latest"}'
   ```

2. **Criar diretório:**
   ```bash
   bash scripts/aapanel_api.sh files CreateDir '{"path":"/opt/supabase"}'
   ```

3. **Baixar docker-compose do Supabase:**
   ```bash
   bash scripts/aapanel_api.sh files DownloadFile '{"url":"https://raw.githubusercontent.com/supabase/supabase/master/docker/docker-compose.yml","path":"/opt/supabase","filename":"docker-compose.yml"}'
   ```

4. **Baixar .env.example:**
   ```bash
   bash scripts/aapanel_api.sh files DownloadFile '{"url":"https://raw.githubusercontent.com/supabase/supabase/master/docker/.env.example","path":"/opt/supabase","filename":".env"}'
   ```

5. **Editar .env com configurações:**
   ```bash
   bash scripts/aapanel_api.sh files SaveFileBody '{"path":"/opt/supabase/.env","data":"POSTGRES_PASSWORD=sua-senha-segura\nJWT_SECRET=seu-jwt-secret-com-pelo-menos-32-caracteres\nANON_KEY=seu-anon-key\nSERVICE_ROLE_KEY=seu-service-role-key\nSITE_URL=https://meusite.com\nAPI_EXTERNAL_URL=https://api.meusite.com","encoding":"utf-8"}'
   ```

6. **Abrir portas necessárias:**
   ```bash
   bash scripts/aapanel_api.sh firewall AddAcceptPort '{"port":"5432","type":"tcp","ps":"PostgreSQL"}'
   bash scripts/aapanel_api.sh firewall AddAcceptPort '{"port":"8000","type":"tcp","ps":"Supabase API"}'
   bash scripts/aapanel_api.sh firewall AddAcceptPort '{"port":"3000","type":"tcp","ps":"Supabase Studio"}'
   ```

7. **Criar cron job para iniciar Supabase:**
   ```bash
   bash scripts/aapanel_api.sh crontab AddCrontab '{"name":"Start Supabase","type":"startUp","sBody":"cd /opt/supabase && docker compose up -d","sType":"toShell"}'
   ```

8. **Executar via terminal SSH ou cron imediato:**
   ```bash
   bash scripts/aapanel_api.sh crontab StartTask '{"id":ID_DA_TAREFA}'
   ```

### Conectando o app React ao Supabase self-hosted:

```typescript
// src/lib/supabase.ts
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://168.231.92.99:8000'  // ou domínio configurado
const supabaseKey = 'seu-anon-key'

export const supabase = createClient(supabaseUrl, supabaseKey)
```

---

## Stack completa recomendada

| Componente | Tecnologia | Onde |
|------------|-----------|------|
| Frontend | React + TypeScript (Vite) | aaPanel Node.js project ou static site |
| Backend API | Supabase (Edge Functions / PostgREST) | Supabase Cloud ou Docker no servidor |
| Banco de dados | PostgreSQL (via Supabase) | Supabase Cloud ou Docker |
| Auth | Supabase Auth | Supabase Cloud ou Docker |
| Storage | Supabase Storage | Supabase Cloud ou Docker |
| Proxy reverso | Nginx (via aaPanel) | Servidor |
| SSL | Let's Encrypt (via aaPanel) | Servidor |
| CI/CD | GitHub Actions + aaPanel API | GitHub + Servidor |
