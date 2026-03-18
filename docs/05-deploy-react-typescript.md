# Deploy de App React + TypeScript

Guia completo para fazer deploy de uma aplicacao React com TypeScript no servidor via aaPanel.

## Opcao A: Site Estatico (Vite Build)

Para apps React que geram arquivos estaticos (SPA).

### 1. Build local

```bash
# No seu projeto local
npm run build
# Gera a pasta dist/
```

### 2. Comprimir para upload

```bash
cd dist
zip -r ../dist.zip .
```

### 3. Hospedar o ZIP (temporariamente)

Suba o `dist.zip` para algum lugar acessivel por URL (GitHub release, S3, etc.).

### 4. Deploy no servidor

```bash
# Criar diretorio
bash scripts/aapanel_api.sh files CreateDir '{"path":"/www/wwwroot/meu-react-app"}'

# Download do build
bash scripts/aapanel_api.sh files DownloadFile '{"url":"https://URL_DO_ZIP/dist.zip","path":"/www/wwwroot/meu-react-app","filename":"dist.zip"}'

# Extrair
bash scripts/aapanel_api.sh files UnZip '{"sfile":"/www/wwwroot/meu-react-app/dist.zip","dfile":"/www/wwwroot/meu-react-app","type":"zip"}'

# Limpar ZIP
bash scripts/aapanel_api.sh files DeleteFile '{"path":"/www/wwwroot/meu-react-app/dist.zip"}'

# Criar site Nginx
bash scripts/aapanel_api.sh site AddSite '{"webname":"{\"domain\":\"meusite.com\",\"domainlist\":[],\"count\":0}","path":"/www/wwwroot/meu-react-app","type_id":0,"type":"PHP","version":"00","port":"80","ps":"React App"}'

# SSL (Let's Encrypt)
bash scripts/aapanel_api.sh ssl apply_cert_api '{"domains":["meusite.com"],"auth_type":"http"}'
```

### 5. Configurar SPA routing

Para que o React Router funcione, configure o Nginx para redirecionar tudo para `index.html`:

```bash
# Ler configuracao atual do Nginx
bash scripts/aapanel_api.sh files GetFileBody '{"path":"/www/server/panel/vhost/nginx/meusite.com.conf"}'

# Adicionar try_files na configuracao
# (editar via SaveFileBody adicionando: try_files $uri $uri/ /index.html;)
```

---

## Opcao B: App SSR/Node.js (Next.js, Remix, etc.)

Para apps que precisam de servidor Node.js.

### 1. Preparar no servidor

```bash
# Criar diretorio
bash scripts/aapanel_api.sh files CreateDir '{"path":"/www/wwwroot/meu-nextjs"}'

# Verificar Node.js instalado
bash scripts/aapanel_api.sh nodejs is_install_nodejs

# Instalar Node.js se necessario
bash scripts/aapanel_api.sh plugin install_plugin '{"sName":"nodejs","version":"20"}'
```

### 2. Upload do projeto

```bash
# Comprimir projeto (excluindo node_modules)
# Localmente: tar -czf projeto.tar.gz --exclude=node_modules --exclude=.git .

# Download no servidor
bash scripts/aapanel_api.sh files DownloadFile '{"url":"URL_DO_ARQUIVO","path":"/www/wwwroot/meu-nextjs","filename":"projeto.tar.gz"}'

# Extrair
bash scripts/aapanel_api.sh files UnZip '{"sfile":"/www/wwwroot/meu-nextjs/projeto.tar.gz","dfile":"/www/wwwroot/meu-nextjs","type":"tar.gz"}'
```

### 3. Criar projeto Node.js

```bash
# Criar projeto
bash scripts/aapanel_api.sh nodejs create_project '{"project_name":"meu-nextjs","project_path":"/www/wwwroot/meu-nextjs","run_script":"npm start","node_version":"20","port":"3000"}'

# Instalar dependencias
bash scripts/aapanel_api.sh nodejs install_packages '{"project_name":"meu-nextjs"}'
```

### 4. Configurar acesso externo

```bash
# Abrir porta no firewall
bash scripts/aapanel_api.sh firewall AddAcceptPort '{"port":"3000","type":"tcp","ps":"Next.js"}'

# Configurar proxy reverso (Nginx -> Node)
bash scripts/aapanel_api.sh nodejs bind_extranet '{"project_name":"meu-nextjs"}'

# Adicionar dominio
bash scripts/aapanel_api.sh nodejs project_add_domain '{"project_name":"meu-nextjs","domain":"meusite.com"}'
```

### 5. Iniciar e monitorar

```bash
# Iniciar
bash scripts/aapanel_api.sh nodejs start_project '{"project_name":"meu-nextjs"}'

# Verificar status
bash scripts/aapanel_api.sh nodejs get_project_run_state '{"project_name":"meu-nextjs"}'

# Ver logs
bash scripts/aapanel_api.sh nodejs get_project_log '{"project_name":"meu-nextjs"}'
```

---

## Variaveis de Ambiente

Para configurar `.env` no servidor:

```bash
bash scripts/aapanel_api.sh files SaveFileBody '{"path":"/www/wwwroot/meu-app/.env","data":"VITE_SUPABASE_URL=https://xxxx.supabase.co\nVITE_SUPABASE_ANON_KEY=eyJhbGciOi...\nNODE_ENV=production","encoding":"utf-8"}'
```

## CI/CD Automatizado

Crie um cron job para pull automatico do Git:

```bash
bash scripts/aapanel_api.sh crontab AddCrontab '{"name":"Deploy React App","type":"minute","hour":"","minute":"30","sBody":"cd /www/wwwroot/meu-app && git pull && npm install && npm run build","sType":"toShell"}'
```

Ou use GitHub Actions chamando a API do aaPanel diretamente.
