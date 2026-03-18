# Instalacao da Skill aaPanel

## Pre-requisitos

- **Claude Code** instalado e funcionando
- Acesso ao servidor aaPanel em `https://168.231.92.99:17198`
- API Key do aaPanel configurada
- IP da maquina na whitelist do painel

## Passo 1: Clonar o repositorio

```bash
git clone https://github.com/professordyx/aapanel-skill.git
cd aapanel-skill
```

## Passo 2: Copiar para o Claude Code

```bash
# Criar diretorio da skill
mkdir -p ~/.claude/skills/aapanel

# Copiar arquivos essenciais
cp SKILL.md ~/.claude/skills/aapanel/
cp -r scripts ~/.claude/skills/aapanel/
cp -r references ~/.claude/skills/aapanel/
```

## Passo 3: Configurar a whitelist de IP

1. Acesse `https://168.231.92.99:17198` no navegador
2. Va em **Settings > API Interface**
3. Ative a API se ainda nao estiver ativa
4. Adicione o IP da sua maquina na **IP Whitelist**
5. A API Key ja esta configurada: `b4uzdFJT7wJSqGnemqa1vRKhyrIKYeDp`

### Como descobrir seu IP

```bash
curl -s https://api.ipify.org
```

## Passo 4: Testar a conexao

```bash
bash ~/.claude/skills/aapanel/scripts/aapanel_api.sh system GetSystemTotal
```

Se retornar um JSON com informacoes do sistema, esta funcionando!

## Passo 5: Usar no Claude Code

Abra o Claude Code e digite comandos em linguagem natural:

```
> Mostre o status do servidor
> Liste os arquivos em /www/wwwroot
> Crie um site para meudominio.com
```

A skill sera ativada automaticamente quando voce mencionar termos como:
- "servidor", "aaPanel", "painel"
- "deploy", "subir aplicacao"
- "firewall", "SSL", "backup"
- "Node.js", "React", "TypeScript"
- "banco de dados", "Supabase"

## Estrutura instalada

```
~/.claude/skills/aapanel/
├── SKILL.md                    # Definicao da skill
├── scripts/
│   └── aapanel_api.sh          # Script de chamadas API
└── references/
    ├── api-catalog.md           # 170+ endpoints documentados
    └── supabase-react-setup.md  # Guia Supabase + React
```

## Atualizacao

Para atualizar a skill:

```bash
cd aapanel-skill
git pull
cp SKILL.md ~/.claude/skills/aapanel/
cp -r scripts ~/.claude/skills/aapanel/
cp -r references ~/.claude/skills/aapanel/
```
