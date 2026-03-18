# Troubleshooting

Problemas comuns e como resolver.

## Erro de autenticacao

### "Invalid token" ou "Token expired"

**Causa**: O timestamp do seu computador esta dessincronizado com o servidor.

**Solucao**:
```bash
# Verificar hora local
date

# Verificar hora do servidor
bash scripts/aapanel_api.sh system GetSystemTotal | python3 -c "import sys,json; print(json.load(sys.stdin))"
```

Se houver diferenca significativa, sincronize o relogio:
```bash
# macOS
sudo sntp -sS time.apple.com

# Linux
sudo ntpdate -u ntp.ubuntu.com
```

### "IP not in whitelist"

**Causa**: O IP da sua maquina nao esta na whitelist do aaPanel.

**Solucao**:
1. Descubra seu IP: `curl -s https://api.ipify.org`
2. Acesse o painel: `https://168.231.92.99:17198`
3. Va em **Settings > API Interface > IP Whitelist**
4. Adicione seu IP

**Nota**: Se seu IP muda frequentemente (conexao dinamica), considere usar um VPN com IP fixo.

---

## Erro de conexao

### "Connection refused" ou timeout

**Possiveis causas**:
1. Servidor desligado
2. Porta 17198 bloqueada no firewall do servidor
3. Firewall do ISP bloqueando a porta

**Verificar conectividade**:
```bash
# Testar porta
nc -zv 168.231.92.99 17198

# Testar com curl
curl -sk https://168.231.92.99:17198/ -o /dev/null -w "%{http_code}"
```

### "SSL certificate problem"

**Causa**: O aaPanel usa certificado auto-assinado.

**Solucao**: O script `aapanel_api.sh` ja usa `-k` (insecure) no curl. Se usar outro metodo, desabilite a verificacao SSL.

---

## Problemas com Node.js

### Projeto nao inicia

```bash
# Ver logs
bash scripts/aapanel_api.sh nodejs get_project_log '{"project_name":"MEU_PROJETO"}'

# Verificar se a porta esta em uso
bash scripts/aapanel_api.sh nodejs check_port_is_used '{"port":"3000"}'

# Reiniciar
bash scripts/aapanel_api.sh nodejs restart_project '{"project_name":"MEU_PROJETO"}'
```

### "Module not found"

```bash
# Reinstalar dependencias
bash scripts/aapanel_api.sh nodejs reinstall_packages '{"project_name":"MEU_PROJETO"}'

# Ou rebuild
bash scripts/aapanel_api.sh nodejs rebuild_project '{"project_name":"MEU_PROJETO"}'
```

### Versao do Node.js incompativel

```bash
# Ver versoes disponiveis
bash scripts/aapanel_api.sh nodejs get_nodejs_version

# Mudar versao
bash scripts/aapanel_api.sh nodejs set_project_nodejs_version '{"project_name":"MEU_PROJETO","version":"20"}'
```

---

## Problemas com banco de dados

### MySQL nao conecta remotamente

```bash
# Verificar acesso
bash scripts/aapanel_api.sh database GetDatabaseAccess '{"name":"meu_db"}'

# Liberar acesso (% = qualquer IP)
bash scripts/aapanel_api.sh database SetDatabaseAccess '{"name":"meu_db","access":"%"}'

# Verificar porta no firewall
bash scripts/aapanel_api.sh firewall GetList '{"p":1,"limit":50}'

# Abrir porta 3306
bash scripts/aapanel_api.sh firewall AddAcceptPort '{"port":"3306","type":"tcp","ps":"MySQL"}'
```

### Esqueceu a senha do banco

```bash
bash scripts/aapanel_api.sh database ResDatabasePassword '{"id":ID,"name":"meu_db","password":"NovaSenha123!"}'
```

---

## Problemas com firewall

### Porta aberta mas nao acessivel

Possivel conflito entre firewall classico e System Firewall v2.

```bash
# Verificar ambos
bash scripts/aapanel_api.sh firewall GetList '{"p":1,"limit":50}'
bash scripts/aapanel_api.sh safe get_rules_list

# Info do firewall
bash scripts/aapanel_api.sh safe get_firewall_info
```

---

## Problemas com SSL

### Certificado nao emitido

```bash
# Verificar: o dominio aponta para o IP do servidor?
# O site esta acessivel na porta 80?

# Tentar com DNS
bash scripts/aapanel_api.sh ssl apply_cert_api '{"domains":["meusite.com"],"auth_type":"dns"}'
```

---

## Dicas gerais

1. **Sempre verifique os logs** antes de tudo
2. **Reinicie o Nginx** apos mudancas de configuracao:
   ```bash
   bash scripts/aapanel_api.sh system ServiceAdmin '{"name":"nginx","type":"restart"}'
   ```
3. **Verifique espaco em disco** se algo parar de funcionar:
   ```bash
   bash scripts/aapanel_api.sh system GetDiskInfo
   ```
4. **Libere memoria** se o servidor estiver lento:
   ```bash
   bash scripts/aapanel_api.sh system ReMemory
   ```
