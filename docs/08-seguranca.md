# Boas Praticas de Seguranca

## API Key

- **NUNCA** compartilhe a API Key em repositorios publicos
- Use variaveis de ambiente: `export AAPANEL_API_KEY=...`
- Rotacione a key periodicamente no painel

## IP Whitelist

- Mantenha apenas IPs necessarios na whitelist
- Remova IPs antigos regularmente
- Use VPN com IP fixo se possivel

## Firewall

- Mantenha o firewall **sempre ativo**
- Abra apenas portas necessarias
- Use regras especificas de IP quando possivel
- Feche portas de desenvolvimento apos testes

```bash
# Verificar portas abertas
bash scripts/aapanel_api.sh firewall GetList '{"p":1,"limit":100}'

# Fechar porta desnecessaria
bash scripts/aapanel_api.sh firewall DelAcceptPort '{"id":ID_DA_REGRA}'
```

## SSH

- Use chaves SSH em vez de senhas
- Mude a porta padrao do SSH
- Desabilite login como root

```bash
# Verificar configuracao SSH
bash scripts/aapanel_api.sh safe_ssh GetSshInfo
```

## SSL/HTTPS

- Sempre use SSL nos sites em producao
- Renove certificados antes de expirar
- Force HTTPS (redirecionar HTTP -> HTTPS)

## Banco de Dados

- Use senhas fortes (minimo 16 caracteres, mix de tipos)
- Restrinja acesso a IPs especificos (evite `%`)
- Faca backups regulares

```bash
# Restringir acesso ao IP do app
bash scripts/aapanel_api.sh database SetDatabaseAccess '{"name":"meu_db","access":"127.0.0.1"}'
```

## Backups

- Configure backups automaticos diarios
- Teste restauracao periodicamente
- Armazene backups em local diferente do servidor

```bash
# Backup automatico diario do banco
bash scripts/aapanel_api.sh crontab AddCrontab '{
  "name": "Backup DB Diario",
  "type": "day",
  "hour": "3",
  "minute": "0",
  "sType": "database",
  "sName": "meu_db",
  "backupTo": "localhost",
  "save": "7"
}'

# Backup automatico diario do site
bash scripts/aapanel_api.sh crontab AddCrontab '{
  "name": "Backup Site Diario",
  "type": "day",
  "hour": "3",
  "minute": "30",
  "sType": "site",
  "sName": "meusite.com",
  "backupTo": "localhost",
  "save": "7"
}'
```

## Atualizacoes

- Mantenha o aaPanel atualizado
- Atualize regularmente: Node.js, Nginx, MySQL, PHP

```bash
# Verificar atualizacao do painel
bash scripts/aapanel_api.sh ajax UpdatePanel '{"check":true}'
```

## Monitoramento

- Configure alertas para uso alto de CPU/memoria
- Monitore logs de erro regularmente
- Use cron jobs para health checks

```bash
# Health check automatico
bash scripts/aapanel_api.sh crontab AddCrontab '{
  "name": "Health Check",
  "type": "hour",
  "hour": "",
  "minute": "0",
  "sBody": "curl -sf http://localhost:3000/health || echo \"APP DOWN\" | mail -s \"Alert\" seu@email.com",
  "sType": "toShell"
}'
```
