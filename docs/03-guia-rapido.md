# Guia Rapido — aaPanel API

Exemplos praticos usando o script `aapanel_api.sh`.

## Sintaxe

```bash
bash scripts/aapanel_api.sh <categoria> <acao> ['<parametros_json>']
```

## Categorias disponiveis

`system` `ajax` `site` `files` `database` `ftp` `firewall` `crontab` `plugin` `ssl` `config` `data` `nodejs` `python` `proxy` `safe` `safe_ssh` `logs` `server`

---

## Sistema

```bash
# Status geral do sistema
bash scripts/aapanel_api.sh system GetSystemTotal

# Info de disco
bash scripts/aapanel_api.sh system GetDiskInfo

# Metricas em tempo real
bash scripts/aapanel_api.sh system GetNetWork

# Reiniciar Nginx
bash scripts/aapanel_api.sh system ServiceAdmin '{"name":"nginx","type":"restart"}'

# Liberar memoria
bash scripts/aapanel_api.sh system ReMemory
```

## Arquivos

```bash
# Listar diretorio
bash scripts/aapanel_api.sh files GetDir '{"path":"/www/wwwroot"}'

# Criar diretorio
bash scripts/aapanel_api.sh files CreateDir '{"path":"/www/wwwroot/meu-app"}'

# Criar arquivo
bash scripts/aapanel_api.sh files CreateFile '{"path":"/www/wwwroot/meu-app/index.html"}'

# Ler conteudo de arquivo
bash scripts/aapanel_api.sh files GetFileBody '{"path":"/www/wwwroot/meu-app/index.html"}'

# Salvar conteudo
bash scripts/aapanel_api.sh files SaveFileBody '{"path":"/www/wwwroot/meu-app/index.html","data":"<h1>Hello World</h1>","encoding":"utf-8"}'

# Download de URL
bash scripts/aapanel_api.sh files DownloadFile '{"url":"https://example.com/file.zip","path":"/www/wwwroot","filename":"file.zip"}'

# Extrair ZIP
bash scripts/aapanel_api.sh files UnZip '{"sfile":"/www/wwwroot/file.zip","dfile":"/www/wwwroot/meu-app","type":"zip"}'

# Compactar
bash scripts/aapanel_api.sh files Zip '{"sfile":"/www/wwwroot/meu-app","dfile":"/www/wwwroot/meu-app.zip","type":"zip"}'

# Permissoes
bash scripts/aapanel_api.sh files SetFileAccess '{"filename":"/www/wwwroot/meu-app","user":"www","access":"755","all":true}'

# Deletar
bash scripts/aapanel_api.sh files DeleteFile '{"path":"/www/wwwroot/file.zip"}'
bash scripts/aapanel_api.sh files DeleteDir '{"path":"/www/wwwroot/meu-app-antigo"}'
```

## Websites

```bash
# Listar sites
bash scripts/aapanel_api.sh data getData '{"table":"sites","limit":20,"p":1,"type":-1}'

# Criar site
bash scripts/aapanel_api.sh site AddSite '{"webname":"{\"domain\":\"meusite.com\",\"domainlist\":[],\"count\":0}","path":"/www/wwwroot/meusite.com","type_id":0,"type":"PHP","version":"00","port":"80","ps":"Meu Site"}'

# Parar site
bash scripts/aapanel_api.sh site SiteStop '{"id":1,"name":"meusite.com"}'

# Iniciar site
bash scripts/aapanel_api.sh site SiteStart '{"id":1,"name":"meusite.com"}'

# Deletar site (com tudo)
bash scripts/aapanel_api.sh site DeleteSite '{"id":1,"webname":"meusite.com","ftp":1,"database":1,"path":1}'
```

## Banco de Dados MySQL

```bash
# Listar bancos
bash scripts/aapanel_api.sh data getData '{"table":"databases","limit":20,"p":1}'

# Criar banco
bash scripts/aapanel_api.sh database AddDatabase '{"name":"meu_db","db_user":"meu_user","password":"SenhaForte123!","codeing":"utf8mb4","address":"127.0.0.1","dtype":"MySQL","ps":"App database"}'

# Alterar senha
bash scripts/aapanel_api.sh database ResDatabasePassword '{"id":1,"name":"meu_db","password":"NovaSenha456!"}'

# Permitir acesso remoto
bash scripts/aapanel_api.sh database SetDatabaseAccess '{"name":"meu_db","access":"%"}'

# Backup
bash scripts/aapanel_api.sh database ToBackup '{"id":1}'

# Importar SQL
bash scripts/aapanel_api.sh database InputSql '{"file":"/www/backup/dump.sql","name":"meu_db"}'
```

## Firewall

```bash
# Listar regras
bash scripts/aapanel_api.sh firewall GetList '{"p":1,"limit":50}'

# Abrir porta
bash scripts/aapanel_api.sh firewall AddAcceptPort '{"port":"3000","type":"tcp","ps":"React App"}'

# Abrir range de portas
bash scripts/aapanel_api.sh firewall AddAcceptPort '{"port":"8000-8100","type":"tcp","ps":"Services"}'

# Bloquear IP
bash scripts/aapanel_api.sh firewall AddDropAddress '{"port":"1.2.3.4","type":"drop","ps":"Atacante"}'
```

## Node.js

```bash
# Listar projetos
bash scripts/aapanel_api.sh nodejs get_project_list

# Criar projeto
bash scripts/aapanel_api.sh nodejs create_project '{"project_name":"meu-react","project_path":"/www/wwwroot/meu-react","run_script":"npm start","node_version":"20","port":"3000"}'

# Instalar dependencias
bash scripts/aapanel_api.sh nodejs install_packages '{"project_name":"meu-react"}'

# Iniciar/Parar/Reiniciar
bash scripts/aapanel_api.sh nodejs start_project '{"project_name":"meu-react"}'
bash scripts/aapanel_api.sh nodejs stop_project '{"project_name":"meu-react"}'
bash scripts/aapanel_api.sh nodejs restart_project '{"project_name":"meu-react"}'

# Proxy reverso (Nginx -> Node)
bash scripts/aapanel_api.sh nodejs bind_extranet '{"project_name":"meu-react"}'

# Logs
bash scripts/aapanel_api.sh nodejs get_project_log '{"project_name":"meu-react"}'
```

## SSL/HTTPS

```bash
# Solicitar certificado Let's Encrypt
bash scripts/aapanel_api.sh ssl apply_cert_api '{"domains":["meusite.com","www.meusite.com"],"auth_type":"http"}'

# Ver certificado do site
bash scripts/aapanel_api.sh site GetSSL '{"siteName":"meusite.com"}'
```

## Cron Jobs

```bash
# Listar tarefas
bash scripts/aapanel_api.sh crontab GetCrontab

# Criar tarefa (executar script todo dia as 3h)
bash scripts/aapanel_api.sh crontab AddCrontab '{"name":"Backup diario","type":"day","hour":"3","minute":"0","sBody":"bash /scripts/backup.sh","sType":"toShell"}'

# Executar agora
bash scripts/aapanel_api.sh crontab StartTask '{"id":1}'
```

## Software

```bash
# Listar software instalado
bash scripts/aapanel_api.sh plugin get_soft_list

# Instalar Node.js
bash scripts/aapanel_api.sh plugin install_plugin '{"sName":"nodejs","version":"20"}'

# Instalar Docker
bash scripts/aapanel_api.sh plugin install_plugin '{"sName":"docker","version":"latest"}'
```
