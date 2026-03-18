---
name: aapanel
description: |
  Gerenciar servidor Linux Ubuntu via aaPanel — criar sites, gerenciar arquivos,
  bancos de dados, Node.js/React apps, firewall, SSL, cron jobs, backups e Docker.
  Use quando o usuário mencionar 'aaPanel', 'painel do servidor', 'gerenciar servidor',
  'criar site', 'subir aplicação', 'deploy no servidor', 'configurar servidor',
  'instalar no servidor', 'upload para servidor', 'gerenciar VPS', 'ambiente Linux',
  'configurar banco de dados no servidor', 'Supabase no servidor', 'deploy React',
  'deploy TypeScript', 'deploy Node.js', 'gerenciar firewall', 'SSL do servidor',
  'backup do servidor', ou qualquer variação de gerenciamento de servidor via painel.
---

# aaPanel — Gerenciamento de Servidor Linux Ubuntu

Painel de controle para gerenciar servidor Linux Ubuntu com suporte a websites, Node.js/React apps, bancos de dados, firewall, SSL, e mais.

**Servidor:** `https://168.231.92.99:17198`
**Autenticação:** API Key com assinatura por timestamp (ver seção Auth)

## Autenticação

Todas as requisições usam **POST** e requerem dois parâmetros de assinatura:

| Parâmetro | Valor |
|-----------|-------|
| `request_time` | Unix timestamp atual |
| `request_token` | `md5(str(request_time) + md5(api_key))` |

A API Key está configurada no servidor. Use o script `scripts/aapanel_api.sh` para fazer chamadas autenticadas.

**Importante:** O IP da máquina chamadora deve estar na whitelist do painel.

## Workflows principais

### 1. Deploy de App React + TypeScript

1. **Verificar sistema:** `GetSystemTotal` para confirmar recursos
2. **Instalar Node.js:** Via software management (`install_plugin` com `sName=nodejs`)
3. **Criar projeto Node.js:** `/project/nodejs/create_project/1`
4. **Upload dos arquivos:** Via `files?action=upload` ou `DownloadFile` (de URL)
5. **Instalar dependências:** `/project/nodejs/install_packages/1`
6. **Configurar domínio:** `/project/nodejs/project_add_domain/1`
7. **Habilitar proxy reverso:** `/project/nodejs/bind_extranet/1`
8. **Configurar SSL:** `acme?action=apply_cert_api`
9. **Iniciar app:** `/project/nodejs/start_project/1`

### 2. Configurar Supabase (Self-hosted)

Supabase requer Docker. Workflow:

1. **Instalar Docker:** Via software management
2. **Criar diretório:** `files?action=CreateDir` → `/opt/supabase`
3. **Download docker-compose:** `files?action=DownloadFile` com URL do Supabase
4. **Criar arquivo .env:** `files?action=SaveFileBody` com configurações
5. **Abrir portas:** Firewall → abrir 5432 (PostgreSQL), 8000 (API), 3000 (Studio)
6. **Executar:** Via terminal/SSH iniciar `docker compose up -d`

Alternativamente, usar Supabase Cloud (hosted) e conectar via variáveis de ambiente no app.

### 3. Gerenciamento de Banco de Dados MySQL

1. **Criar database:** `database?action=AddDatabase`
2. **Configurar acesso remoto:** `database?action=SetDatabaseAccess`
3. **Backup:** `database?action=ToBackup`
4. **Importar SQL:** `database?action=InputSql`

## Referência da API

Para o catálogo completo de 170+ endpoints: [references/api-catalog.md](references/api-catalog.md)

**Categorias disponíveis:**

| Categoria | Endpoints | Descrição |
|-----------|-----------|-----------|
| Sistema | 12 | CPU, memória, disco, rede, serviços |
| Websites | 30+ | Criar, deletar, configurar sites PHP |
| Domínios | 3 | Adicionar, listar, remover domínios |
| Arquivos | 14 | Upload, download, criar, editar, compactar |
| Banco de Dados | 25+ | MySQL: criar, backup, importar, configurar |
| FTP | 6 | Criar, deletar, configurar contas FTP |
| Firewall | 20+ | Portas, IPs, forwarding, geo-blocking |
| Cron Jobs | 8 | Agendar, executar, monitorar tarefas |
| SSL/HTTPS | 4 | Let's Encrypt, deploy certificados |
| Software | 3 | Instalar, desinstalar plugins |
| Node.js | 30+ | Projetos, módulos, domínios, logs |
| Python | 20+ | Projetos, pacotes, domínios |
| Proxy Reverso | 15+ | Criar, configurar, cache, headers |
| Logs | 6 | Painel, sites, erros, cron |
| Backup | 4 | Sites, databases |
| Configuração | 4 | Painel settings |

## Script utilitário

O script `scripts/aapanel_api.sh` automatiza chamadas autenticadas:

```bash
# Status do sistema
bash scripts/aapanel_api.sh system GetSystemTotal

# Listar arquivos
bash scripts/aapanel_api.sh files GetDir '{"path":"/www/wwwroot"}'

# Criar diretório
bash scripts/aapanel_api.sh files CreateDir '{"path":"/www/wwwroot/meu-app"}'

# Upload de arquivo remoto
bash scripts/aapanel_api.sh files DownloadFile '{"url":"https://example.com/file.zip","path":"/www/wwwroot","filename":"file.zip"}'

# Criar banco de dados
bash scripts/aapanel_api.sh database AddDatabase '{"name":"meu_db","db_user":"meu_user","password":"senha123","codeing":"utf8mb4","address":"127.0.0.1","dtype":"MySQL","ps":"App database"}'

# Criar projeto Node.js
bash scripts/aapanel_api.sh nodejs create_project '{"project_name":"meu-react-app","project_path":"/www/wwwroot/meu-react-app","run_script":"npm start","node_version":"20","port":"3000"}'

# Abrir porta no firewall
bash scripts/aapanel_api.sh firewall AddAcceptPort '{"port":"3000","type":"tcp","ps":"React app"}'

# Solicitar certificado SSL
bash scripts/aapanel_api.sh ssl apply_cert_api '{"domains":["meusite.com"],"auth_type":"http"}'
```

Veja referência completa dos endpoints em [references/api-catalog.md](references/api-catalog.md).
