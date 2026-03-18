# aaPanel Skill para Claude Code

Skill completa para gerenciar um servidor **Linux Ubuntu** via **aaPanel** diretamente do Claude Code. Permite criar sites, gerenciar arquivos, bancos de dados, apps Node.js/React, firewall, SSL, cron jobs, backups, Docker e muito mais.

## Visao Geral

| Item | Detalhe |
|------|---------|
| **Servidor** | `https://168.231.92.99:17198` |
| **OS** | Linux Ubuntu |
| **Painel** | aaPanel (BT Panel) |
| **Metodo HTTP** | POST (todos os endpoints) |
| **Autenticacao** | API Key + HMAC (timestamp + md5) |

## Estrutura do Repositorio

```
aapanel-skill/
├── README.md                           # Este arquivo
├── SKILL.md                            # Definicao da skill para Claude Code
├── scripts/
│   └── aapanel_api.sh                  # Script CLI para chamadas autenticadas
├── references/
│   ├── api-catalog.md                  # Catalogo completo de 170+ endpoints
│   └── supabase-react-setup.md         # Guia: Supabase + React/TypeScript
├── docs/
│   ├── 01-instalacao.md                # Como instalar a skill
│   ├── 02-autenticacao.md              # Como funciona a autenticacao
│   ├── 03-guia-rapido.md              # Guia rapido com exemplos
│   ├── 04-categorias-api.md            # Resumo de todas as categorias
│   ├── 05-deploy-react-typescript.md   # Deploy completo React+TS
│   ├── 06-supabase-setup.md            # Setup Supabase (cloud e self-hosted)
│   ├── 07-troubleshooting.md           # Solucao de problemas comuns
│   └── 08-seguranca.md                # Boas praticas de seguranca
└── examples/
    ├── deploy-react-app.sh             # Exemplo: deploy React app
    ├── setup-supabase-docker.sh        # Exemplo: Supabase self-hosted
    ├── backup-automatico.sh            # Exemplo: backup agendado
    └── setup-completo.sh               # Exemplo: stack completa
```

## Instalacao Rapida

### 1. Copiar a skill para o Claude Code

```bash
# Clonar o repositorio
git clone https://github.com/professordyx/aapanel-skill.git

# Copiar para o diretorio de skills do Claude Code
mkdir -p ~/.claude/skills/aapanel
cp -r aapanel-skill/SKILL.md ~/.claude/skills/aapanel/
cp -r aapanel-skill/scripts ~/.claude/skills/aapanel/
cp -r aapanel-skill/references ~/.claude/skills/aapanel/
```

### 2. Configurar IP na whitelist

Acesse o painel aaPanel em `https://168.231.92.99:17198` e va em:
**Settings > API Interface > IP Whitelist** — adicione o IP da sua maquina.

### 3. Testar a conexao

```bash
bash ~/.claude/skills/aapanel/scripts/aapanel_api.sh system GetSystemTotal
```

## Como Usar

Apos instalar, basta pedir ao Claude Code em linguagem natural:

- *"Crie um site no servidor para meudominio.com"*
- *"Faca deploy da minha app React no servidor"*
- *"Configure o Supabase no servidor"*
- *"Abra a porta 3000 no firewall"*
- *"Instale o Node.js 20 no servidor"*
- *"Faca backup do banco de dados"*
- *"Veja o status do servidor"*

## Categorias de API Disponiveis

| # | Categoria | Endpoints | Descricao |
|---|-----------|-----------|-----------|
| 1 | Sistema | 12 | CPU, memoria, disco, rede, servicos |
| 2 | Websites | 30+ | Criar, deletar, configurar sites |
| 3 | Dominios | 3 | Adicionar, listar, remover dominios |
| 4 | Arquivos | 14 | Upload, download, criar, editar, compactar |
| 5 | Banco de Dados | 25+ | MySQL: criar, backup, importar |
| 6 | FTP | 6 | Contas FTP |
| 7 | Firewall | 20+ | Portas, IPs, forwarding, geo-blocking |
| 8 | Cron Jobs | 8 | Agendar, executar, monitorar |
| 9 | SSL/HTTPS | 4 | Let's Encrypt, certificados |
| 10 | Software | 3 | Instalar, desinstalar plugins |
| 11 | Node.js | 30+ | Projetos, modulos, dominios, logs |
| 12 | Python | 20+ | Projetos, pacotes, dominios |
| 13 | Proxy Reverso | 15+ | Criar, cache, headers |
| 14 | Backup | 4 | Sites e databases |
| 15 | Logs | 6 | Painel, sites, erros, cron |
| 16 | Configuracao | 4 | Painel settings |
| 17 | DNS | 1+ | Registros DNS (plugin) |
| 18 | Docker | 3+ | Containers, imagens |

> **Total: 170+ endpoints catalogados**

## Stack Recomendada

| Componente | Tecnologia | Onde |
|------------|-----------|------|
| Frontend | React + TypeScript (Vite) | aaPanel Node.js ou static site |
| Backend API | Supabase (PostgREST) | Supabase Cloud ou Docker |
| Banco de dados | PostgreSQL (via Supabase) | Supabase Cloud ou Docker |
| Auth | Supabase Auth | Supabase |
| Proxy reverso | Nginx (via aaPanel) | Servidor |
| SSL | Let's Encrypt (via aaPanel) | Servidor |

## Licenca

MIT

## Autor

Gerado e mantido com [Claude Code](https://claude.ai/claude-code)
