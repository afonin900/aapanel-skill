# aaPanel API — Полный каталог endpoints

**Метод:** Все endpoints используют **POST**
**Content-Type:** `application/x-www-form-urlencoded`

## Аутентификация

Каждый запрос должен содержать:

| Параметр | Значение |
|----------|----------|
| `request_time` | Unix timestamp (например: `1711900000`) |
| `request_token` | `md5(str(request_time) + md5(api_key))` |

**API Key:** Настраивается в панели в Settings > API Interface. Хранится в `~/.aapanel/servers.conf`.
**IP Whitelist:** IP вызывающей машины должен быть в whitelist панели.

---

## Table of Contents

- [1. Sistema](#1-sistema)
- [2. Websites](#2-websites)
- [3. Domínios](#3-domínios)
- [4. Arquivos](#4-arquivos)
- [5. Banco de Dados MySQL](#5-banco-de-dados-mysql)
- [6. FTP](#6-ftp)
- [7. Firewall](#7-firewall)
- [8. Cron Jobs](#8-cron-jobs)
- [9. SSL/HTTPS](#9-sslhttps)
- [10. Software/Plugins](#10-softwareplugins)
- [11. Node.js](#11-nodejs)
- [12. Python](#12-python)
- [13. Proxy Reverso](#13-proxy-reverso)
- [14. Backup](#14-backup)
- [15. Logs](#15-logs)
- [16. Configuração do Painel](#16-configuração-do-painel)
- [17. DNS](#17-dns)
- [18. Docker](#18-docker)

---

## 1. Sistema

### Informações do sistema
```
POST /system?action=GetSystemTotal
```
Retorna: OS, versão do painel, CPU, memória, uptime, IPs.

### Informações de disco
```
POST /system?action=GetDiskInfo
```
Retorna: partições, pontos de montagem, inodes, capacidade.

### Métricas em tempo real
```
POST /system?action=GetNetWork
```
Retorna: CPU, memória, rede, load em tempo real.

### Liberar memória
```
POST /system?action=ReMemory
```

### Gerenciar serviços
```
POST /system?action=ServiceAdmin
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `name` | string | Nome do serviço (nginx, mysqld, etc.) |
| `type` | string | Ação: start, stop, restart, reload |

### Contagem de tarefas em execução
```
POST /ajax?action=GetTaskCount
```

### Atualizar painel
```
POST /ajax?action=UpdatePanel
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `check` | bool | Apenas verificar (sem instalar) |
| `force` | bool | Forçar atualização |

### Load average
```
POST /ajax?action=get_load_average
```

### CPU e memória
```
POST /ajax?action=GetCpuIo
```

### Disco I/O
```
POST /ajax?action=GetDiskIo
```

### Rede I/O
```
POST /ajax?action=GetNetWorkIo
```

### Configuração do servidor
```
POST /server?action=getConfig
POST /server?action=setConfig
```

---

## 2. Websites

### Listar websites
```
POST /data?action=getData&table=sites
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `p` | int | Página |
| `limit` | int | Itens por página (obrigatório) |
| `type` | int | -1 para todos |
| `order` | string | Ordenação |
| `search` | string | Busca por nome |

### Criar website
```
POST /site?action=AddSite
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `webname` | JSON | `{"domain":"example.com","domainlist":[],"count":0}` |
| `path` | string | Caminho raiz (ex: `/www/wwwroot/example.com`) |
| `type_id` | int | ID da categoria |
| `type` | string | Tipo (PHP) |
| `version` | string | Versão PHP |
| `port` | string | Porta (ex: "80") |
| `ps` | string | Descrição |
| `ftp` | bool | Criar conta FTP |
| `ftp_username` | string | Usuário FTP |
| `ftp_password` | string | Senha FTP |
| `sql` | bool | Criar banco de dados |
| `codeing` | string | Encoding do DB (utf8mb4) |
| `datauser` | string | Usuário do DB |
| `datapassword` | string | Senha do DB |

### Deletar website
```
POST /site?action=DeleteSite
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `id` | int | ID do site |
| `webname` | string | Nome do site |
| `ftp` | int | 1 para deletar FTP junto |
| `database` | int | 1 para deletar DB junto |
| `path` | int | 1 para deletar arquivos |

### Parar website
```
POST /site?action=SiteStop
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `id` | int | ID do site |
| `name` | string | Nome do site |

### Iniciar website
```
POST /site?action=SiteStart
```
Mesmos parâmetros de SiteStop.

### Definir expiração
```
POST /site?action=SetEdate
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `id` | int | ID do site |
| `edate` | string | Data (YYYY-MM-DD ou 0000-00-00 para permanente) |

### Categorias de sites
```
POST /site?action=get_site_types          # Listar
POST /site?action=add_site_type           # Criar (name)
POST /site?action=remove_site_type        # Remover (id)
POST /site?action=set_site_type           # Atribuir (id, type)
```

### Versão PHP
```
POST /site?action=GetPHPVersion           # Listar versões instaladas
POST /site?action=SetPHPVersion           # Definir (siteName, version)
POST /site?action=GetSitePHPVersion       # Ver atual (siteName)
```

### Site padrão
```
POST /site?action=GetDefaultSite
POST /site?action=SetDefaultSite          # (name)
```

### Extensões negadas
```
POST /site?action=GetDenyAccess           # (id, name)
POST /site?action=SetDenyAccess           # (id, name, fix)
```

### Notas do site
```
POST /data?action=setPs&table=sites       # (id, ps)
```

### Diretório raiz
```
POST /data?action=getKey&table=sites&key=path   # (id)
POST /site?action=SetPath                        # (id, path)
POST /site?action=SetSiteRunPath                 # (id, runPath)
```

### Proteções e configurações
```
POST /site?action=GetDirUserINI           # Status proteção anti-cross-site (id, path)
POST /site?action=SetDirUserINI           # Toggle proteção (path)
POST /site?action=logsOpen                # Toggle log de acesso (id)
```

### Proteção por senha
```
POST /site?action=SetHasPwd               # Habilitar (id, username, password)
POST /site?action=CloseHasPwd             # Desabilitar (id)
```

### Limite de tráfego (Nginx)
```
POST /site?action=GetLimitNet             # (id)
POST /site?action=SetLimitNet             # (id, perserver, perip, limit_rate)
POST /site?action=CloseLimitNet           # (id)
```

### Documentos padrão
```
POST /site?action=GetIndex                # (id)
POST /site?action=SetIndex                # (id, Index — separados por vírgula)
```

### Regras de rewrite
```
POST /site?action=GetRewriteList          # (siteName)
```

### Logs do site
```
POST /site?action=GetSiteLogs             # (siteName)
POST /site?action=get_site_errlog         # (siteName)
```

---

## 3. Domínios

### Listar domínios de um site
```
POST /data?action=getData&table=domain
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `search` | int | ID do site |
| `list` | bool | true |

### Adicionar domínio
```
POST /site?action=AddDomain
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `id` | int | ID do site |
| `webname` | string | Nome do site |
| `domain` | string | domínio:porta (múltiplos separados por newline) |

### Remover domínio
```
POST /site?action=DelDomain
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `id` | int | ID do site |
| `webname` | string | Nome do site |
| `domain` | string | Domínio |
| `port` | int | Porta |

---

## 4. Arquivos

### Listar diretório
```
POST /files?action=GetDir
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `path` | string | Caminho do diretório |
| `p` | int | Página |
| `showRow` | int | Itens por página |
| `is_operating` | bool | Mostrar operações |

### Criar arquivo
```
POST /files?action=CreateFile
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `path` | string | Caminho completo do arquivo |

### Criar diretório
```
POST /files?action=CreateDir
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `path` | string | Caminho completo do diretório |

### Deletar arquivo
```
POST /files?action=DeleteFile
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `path` | string | Caminho do arquivo |

### Deletar diretório
```
POST /files?action=DeleteDir
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `path` | string | Caminho do diretório |

### Copiar arquivo
```
POST /files?action=CopyFile
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `sfile` | string | Arquivo origem |
| `dfile` | string | Arquivo destino |

### Mover/renomear arquivo
```
POST /files?action=MvFile
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `sfile` | string | Caminho origem |
| `dfile` | string | Caminho destino |

### Ler conteúdo de arquivo
```
POST /files?action=GetFileBody
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `path` | string | Caminho do arquivo |

### Salvar conteúdo de arquivo
```
POST /files?action=SaveFileBody
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `path` | string | Caminho do arquivo |
| `data` | string | Conteúdo |
| `encoding` | string | Encoding (utf-8) |

### Compactar arquivos
```
POST /files?action=Zip
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `sfile` | string | Arquivo/diretório origem |
| `dfile` | string | Arquivo destino (.zip, .tar.gz) |
| `type` | string | Tipo de compactação |

### Extrair arquivo
```
POST /files?action=UnZip
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `sfile` | string | Arquivo compactado |
| `dfile` | string | Diretório destino |
| `type` | string | Tipo |
| `coding` | string | Encoding |
| `password` | string | Senha (se necessário) |

### Permissões de arquivo
```
POST /files?action=SetFileAccess
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `filename` | string | Caminho do arquivo |
| `user` | string | Proprietário (www, root) |
| `access` | string | Permissões (755, 644) |
| `all` | bool | Recursivo |

### Download de arquivo remoto
```
POST /files?action=DownloadFile
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `url` | string | URL do arquivo |
| `path` | string | Diretório destino |
| `filename` | string | Nome do arquivo |

### Upload de arquivo
```
POST /files?action=upload
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `f_path` | string | Diretório destino |
| `f_name` | string | Nome do arquivo |
| `f_size` | int | Tamanho |
| `f_start` | int | Offset (para upload chunked) |
| `blob` | file | Dados do arquivo |

### Tamanho do diretório
```
POST /files?action=GetDirSize
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `path` | string | Caminho do diretório |

---

## 5. Banco de Dados MySQL

### Listar bancos de dados
```
POST /data?action=getData&table=databases
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `limit` | int | Itens por página |
| `p` | int | Página |
| `order` | string | Ordenação |
| `type` | int | Tipo |
| `search` | string | Busca |

### Criar banco de dados
```
POST /database?action=AddDatabase
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `name` | string | Nome do banco |
| `db_user` | string | Usuário |
| `password` | string | Senha |
| `codeing` | string | Encoding (utf8, utf8mb4) |
| `address` | string | Endereço de acesso (127.0.0.1, %, IP) |
| `dtype` | string | Tipo (MySQL) |
| `sid` | int | Server ID |
| `ps` | string | Descrição |

### Deletar banco de dados
```
POST /database?action=DeleteDatabase
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `id` | int | ID do banco |
| `name` | string | Nome do banco |

### Informações do banco
```
POST /database?action=GetInfo              # (id)
POST /database?action=GetdataInfo          # Visão geral
POST /database?action=get_database_size    # (ids, is_pid)
```

### Senha root do MySQL
```
POST /database?action=SetupPassword
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `password` | string | Nova senha root |
| `sid` | int | Server ID |

### Resetar senha do banco
```
POST /database?action=ResDatabasePassword
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `id` | int | ID do banco |
| `name` | string | Nome do banco |
| `password` | string | Nova senha |

### Permissões de acesso
```
POST /database?action=GetDatabaseAccess    # (name)
POST /database?action=SetDatabaseAccess    # (name, access, ssl)
```
Valores para `access`: `127.0.0.1` (local), `%` (qualquer IP), IP específico.

### Importar SQL
```
POST /database?action=InputSql
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `file` | string | Caminho do arquivo .sql |
| `name` | string | Nome do banco |

### Manutenção
```
POST /database?action=ReTable              # Reparar (db_name)
POST /database?action=OpTable              # Otimizar (db_name)
POST /database?action=AlTable              # Converter engine (db_name, table, engine)
```

### Status e configuração MySQL
```
POST /database?action=GetMySQLInfo         # Info do servidor
POST /database?action=GetDbStatus          # Status
POST /database?action=SetDbConf            # Configuração
POST /database?action=GetRunStatus         # Status runtime
POST /database?action=SetMySQLPort         # Porta (port)
POST /database?action=SetDataDir           # Diretório de dados (datadir)
```

### Binary Log
```
POST /database?action=BinLog               # Toggle (status)
POST /database?action=GetMySQLBinlogs      # Listar
POST /database?action=ClearMySQLBinlog     # Limpar (days)
```

### Logs MySQL
```
POST /database?action=GetErrorLog          # Log de erros (close para fechar)
POST /database?action=GetSlowLogs          # Slow queries
```

### SSL MySQL
```
POST /database?action=check_mysql_ssl_status
POST /database?action=write_ssl_to_mysql
```

### Usuários MySQL
```
POST /database?action=get_mysql_user
```

---

## 6. FTP

### Listar contas FTP
```
POST /data?action=getData&table=ftps
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `limit` | int | Itens por página |
| `p` | int | Página |
| `search` | string | Busca |

### Criar conta FTP
```
POST /ftp?action=AddUser
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `ftp_username` | string | Usuário |
| `ftp_password` | string | Senha |
| `path` | string | Diretório home |
| `ps` | string | Descrição |

### Deletar conta FTP
```
POST /ftp?action=DeleteUser
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `id` | int | ID da conta |
| `username` | string | Usuário |

### Alterar senha FTP
```
POST /ftp?action=SetUserPassword
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `id` | int | ID |
| `ftp_username` | string | Usuário |
| `new_password` | string | Nova senha |

### Habilitar/desabilitar conta FTP
```
POST /ftp?action=SetStatus
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `id` | int | ID |
| `username` | string | Usuário |
| `status` | int | 0 (desabilitar) ou 1 (habilitar) |

---

## 7. Firewall

### Firewall Clássico

#### Listar regras
```
POST /firewall?action=GetList
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `p` | int | Página |
| `limit` | int | Itens por página |

#### Bloquear IP
```
POST /firewall?action=AddDropAddress
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `port` | string | Porta |
| `type` | string | Tipo |
| `ps` | string | Descrição |

#### Desbloquear IP
```
POST /firewall?action=DelDropAddress       # (id)
```

#### Abrir porta
```
POST /firewall?action=AddAcceptPort
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `port` | string | Porta (ex: "3000", "8000-8100") |
| `type` | string | Protocolo (tcp, udp, tcp/udp) |
| `ps` | string | Descrição |

#### Fechar porta
```
POST /firewall?action=DelAcceptPort        # (id)
```

#### Status do firewall
```
POST /firewall?action=SetFirewallStatus    # (status)
```

#### Toggle SSH
```
POST /firewall?action=SetSshStatus         # (status)
```

#### Toggle ping
```
POST /firewall?action=SetPing              # (status)
```

### Firewall v2 (System Firewall)

```
POST /safe/firewall/get_rules_list         # Regras de porta
POST /safe/firewall/get_forward_list       # Port forwarding
POST /safe/firewall/get_ip_rules_list      # Regras de IP
POST /safe/firewall/get_country_list       # Geo-blocking
POST /safe/firewall/create_rules           # Criar regra de porta
POST /safe/firewall/remove_rules           # Remover regra
POST /safe/firewall/modify_rules           # Modificar regra
POST /safe/firewall/create_ip_rules        # Criar regra de IP
POST /safe/firewall/remove_ip_rules        # Remover regra de IP
POST /safe/firewall/modify_ip_rules        # Modificar regra de IP
POST /safe/firewall/create_forward         # Criar port forward
POST /safe/firewall/remove_forward         # Remover forward
POST /safe/firewall/modify_forward         # Modificar forward
POST /safe/firewall/create_country         # Criar regra geográfica
POST /safe/firewall/remove_country         # Remover regra geográfica
POST /safe/firewall/modify_country         # Modificar regra geográfica
POST /safe/firewall/get_countrys           # Listar países
POST /safe/firewall/get_firewall_info      # Info/status do firewall
POST /safe/firewall/firewall_admin         # Toggle firewall
POST /safe/ssh/GetSshInfo                  # Info SSH
```

---

## 8. Cron Jobs

> **AAPanel 8.x (v2 API):** все crontab-операции используют `/v2/crontab` с `action` в POST-теле.
> Скрипт `aapanel` направляет категорию `crontab` на этот endpoint автоматически.

### Список задач
```
POST /v2/crontab  action=GetCrontab
```
| Параметр | Тип | Описание |
|----------|-----|----------|
| `p` | int | Страница |
| `limit` | int | Задач на страницу |

### Создать задачу
```
POST /v2/crontab  action=AddCrontab
```
| Параметр | Тип | Описание |
|----------|-----|----------|
| `name` | string | Название задачи |
| `type` | string | Расписание: `day`, `hour`, `minute-n`, `week`, `month` |
| `where1` | string | Интервал для `minute-n` (число минут); пусто для других |
| `hour` | int | Час запуска (для `day`, `hour`) |
| `minute` | int | Минута запуска |
| `sType` | string | Тип: `toShell`, `toUrl`, `database`, `site` |
| `sBody` | string | Shell-команда (для `toShell`) |
| `sName` | string | Имя сайта/БД (для `site`/`database`); пусто для shell |
| `save` | int | Количество бэкапов; `0` для shell |
| `backupTo` | string | Место бэкапа (`localhost`); пусто для shell |
| `urladdress` | string | URL (для `toUrl`); пусто |
| `save_local` | int | `0` или `1` |
| `notice` | int | Уведомления: `0` или `1` |
| `notice_channel` | string | Канал уведомлений; пусто |

**Пример — shell-скрипт каждый день в 4:00:**
```bash
aapanel crontab AddCrontab '{
  "name":"daily-deploy","type":"day","where1":"",
  "hour":4,"minute":0,
  "sType":"toShell","sBody":"/www/scripts/deploy.sh",
  "sName":"","save":0,"backupTo":"localhost",
  "urladdress":"","save_local":0,"notice":0,"notice_channel":""
}'
```

**Пример — каждые 100 минут:**
```bash
aapanel crontab AddCrontab '{
  "name":"health-check","type":"minute-n","where1":"100",
  "hour":0,"minute":0,
  "sType":"toShell","sBody":"curl -s http://localhost/health",
  "sName":"","save":0,"backupTo":"localhost",
  "urladdress":"","save_local":0,"notice":0,"notice_channel":""
}'
```

### Удалить задачу
```
POST /v2/crontab  action=DelCrontab  id=<id>
```

### Запустить немедленно
```
POST /v2/crontab  action=StartTask  id=<id>
```

### Включить/выключить
```
POST /v2/crontab  action=set_cron_status  id=<id>  status=<0|1>
```

### Изменить задачу
```
POST /v2/crontab  action=EditCrontab  id=<id>  <+ все поля как в AddCrontab>
```

### Логи задачи
```
POST /v2/crontab  action=GetLogs  id=<id>
```

---

## 9. SSL/HTTPS

### Ver SSL do site
```
POST /site?action=GetSSL                   # (siteName)
```

### Deploy de certificado
```
POST /site?action=SetSSL
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `type` | int | Tipo de certificado |
| `siteName` | string | Nome do site |
| `key` | string | Chave privada |
| `csr` | string | Certificado |

### Desabilitar SSL
```
POST /site?action=CloseSSLConf
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `updateOf` | int | Tipo |
| `siteName` | string | Nome do site |

### Let's Encrypt
```
POST /acme?action=apply_cert_api
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `domains` | JSON | Array de domínios `["example.com","www.example.com"]` |
| `id` | int | ID do site |
| `auth_to` | string | Método de autenticação |
| `auth_type` | string | http, dns, tls |
| `auto_wildcard` | bool | Certificado wildcard |

### Renovar certificado
```
POST /acme?action=renew_cert               # (index)
```

---

## 10. Software/Plugins

### Listar software instalado
```
POST /plugin?action=get_soft_list
```

### Instalar software
```
POST /plugin?action=install_plugin
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `sName` | string | Nome do software (nginx, nodejs, docker, etc.) |
| `version` | string | Versão |
| `min_version` | string | Versão mínima |
| `type` | int | Tipo |

### Desinstalar software
```
POST /plugin?action=uninstall_plugin
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `sName` | string | Nome do software |

---

## 11. Node.js

Todos os endpoints usam POST. Padrão: `/project/nodejs/<action>/1`

### Projetos
```
POST /project/nodejs/get_project_list/1        # Listar projetos
POST /project/nodejs/get_project_info/1        # Info do projeto
POST /project/nodejs/get_project_find/1        # Buscar projeto
POST /project/nodejs/get_project_run_state/1   # Estado de execução
POST /project/nodejs/get_project_load_info/1   # Info de carga
```

### CRUD de projetos
```
POST /project/nodejs/create_project/1
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `project_name` | string | Nome do projeto |
| `project_path` | string | Caminho dos arquivos |
| `run_script` | string | Comando de execução (npm start, node index.js) |
| `node_version` | string | Versão do Node.js |
| `port` | string | Porta |

```
POST /project/nodejs/modify_project/1          # Modificar projeto
POST /project/nodejs/remove_project/1          # Deletar projeto
```

### Controle
```
POST /project/nodejs/start_project/1           # Iniciar
POST /project/nodejs/stop_project/1            # Parar
POST /project/nodejs/restart_project/1         # Reiniciar
```

### Versão Node.js
```
POST /project/nodejs/is_install_nodejs/1           # Verificar instalação
POST /project/nodejs/get_nodejs_version/1          # Versões disponíveis
POST /project/nodejs/get_project_nodejs_version/1  # Versão do projeto
POST /project/nodejs/set_project_nodejs_version/1  # Definir versão
```

### Rede
```
POST /project/nodejs/set_project_listen/1      # Definir porta
POST /project/nodejs/check_port_is_used/1      # Verificar porta em uso
POST /project/nodejs/bind_extranet/1           # Habilitar proxy Nginx
POST /project/nodejs/unbind_extranet/1         # Desabilitar proxy
```

### Configuração web
```
POST /project/nodejs/set_config/1              # Configurar web
POST /project/nodejs/clear_config/1            # Limpar configuração
```

### Domínios
```
POST /project/nodejs/project_get_domain/1      # Listar domínios
POST /project/nodejs/project_add_domain/1      # Adicionar domínio
POST /project/nodejs/project_remove_domain/1   # Remover domínio
```

### Pacotes NPM
```
POST /project/nodejs/install_packages/1        # npm install
POST /project/nodejs/update_packages/1         # npm update
POST /project/nodejs/reinstall_packages/1      # Reinstalar
POST /project/nodejs/get_project_modules/1     # Listar módulos
POST /project/nodejs/install_module/1          # Instalar módulo
POST /project/nodejs/uninstall_module/1        # Desinstalar módulo
POST /project/nodejs/upgrade_module/1          # Atualizar módulo
POST /project/nodejs/rebuild_project/1         # npm rebuild
```

### Scripts e logs
```
POST /project/nodejs/get_run_list/1            # Scripts do package.json
POST /project/nodejs/get_project_log/1         # Log do projeto
POST /project/nodejs/get_exec_logs/1           # Logs de execução
POST /project/nodejs/get_ssl_end_date/1        # Validade do SSL
```

---

## 12. Python

Padrão: `/project/python/<action>/1`

### Projetos
```
POST /project/python/get_project_list/1        # Listar
POST /project/python/get_project_info/1        # Info
POST /project/python/get_project_find/1        # Buscar
POST /project/python/get_project_run_state/1   # Estado
POST /project/python/get_project_load_info/1   # Carga
POST /project/python/create_project/1          # Criar
POST /project/python/modify_project/1          # Modificar
POST /project/python/remove_project/1          # Deletar
POST /project/python/start_project/1           # Iniciar
POST /project/python/stop_project/1            # Parar
POST /project/python/restart_project/1         # Reiniciar
```

### Versão Python
```
POST /project/python/get_python_version/1              # Versões disponíveis
POST /project/python/get_project_python_version/1      # Versão do projeto
POST /project/python/set_project_python_version/1      # Definir versão
```

### Domínios e rede
```
POST /project/python/project_get_domain/1      # Listar domínios
POST /project/python/project_add_domain/1      # Adicionar
POST /project/python/project_remove_domain/1   # Remover
POST /project/python/bind_extranet/1           # Proxy externo
POST /project/python/unbind_extranet/1         # Desabilitar
```

### Pacotes pip
```
POST /project/python/get_project_modules/1     # Listar
POST /project/python/install_packages/1        # pip install
POST /project/python/install_module/1          # Instalar específico
POST /project/python/uninstall_module/1        # Desinstalar
```

### Logs
```
POST /project/python/get_project_log/1         # Log do projeto
```

---

## 13. Proxy Reverso

Padrão: `/project/proxy/<action>/1`

### Projetos
```
POST /project/proxy/get_project_list/1         # Listar
POST /project/proxy/get_project_info/1         # Info
POST /project/proxy/get_project_find/1         # Buscar
POST /project/proxy/create_project/1           # Criar
POST /project/proxy/modify_project/1           # Modificar
POST /project/proxy/remove_project/1           # Deletar
```

### Regras de proxy
```
POST /project/proxy/get_proxy_list/1           # Listar regras
POST /project/proxy/add_proxy/1                # Adicionar regra
POST /project/proxy/modify_proxy/1             # Modificar regra
POST /project/proxy/remove_proxy/1             # Remover regra
```

### Configurações avançadas
```
POST /project/proxy/set_content_replace/1      # Substituição de conteúdo
POST /project/proxy/set_proxy_header/1         # Headers customizados
POST /project/proxy/set_proxy_cache/1          # Cache
POST /project/proxy/clear_proxy_cache/1        # Limpar cache
POST /project/proxy/set_gzip/1                 # Compressão
```

### Restrição de IP
```
POST /project/proxy/get_ip_restriction/1       # Listar restrições
POST /project/proxy/set_ip_blacklist/1         # Bloquear IPs
POST /project/proxy/set_ip_whitelist/1         # Permitir IPs
```

### Domínios e logs
```
POST /project/proxy/project_get_domain/1       # Listar domínios
POST /project/proxy/project_add_domain/1       # Adicionar
POST /project/proxy/project_remove_domain/1    # Remover
POST /project/proxy/get_project_log/1          # Log
```

---

## 14. Backup

### Listar backups
```
POST /data?action=getData&table=backup
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `p` | int | Página |
| `limit` | int | Itens |
| `type` | int | 0=site, 1=database |
| `search` | int | ID do site/DB |

### Criar backup de site
```
POST /site?action=ToBackup                 # (id)
```

### Deletar backup de site
```
POST /site?action=DelBackup                # (id do backup)
```

### Backup de banco de dados
```
POST /database?action=ToBackup             # (id)
```

---

## 15. Logs

```
POST /data?action=getData&table=logs&tojs=getLogs   # Logs de operação do painel (p, limit)
POST /config?action=get_panel_error_logs            # Logs de erro do painel
POST /crontab?action=GetLogs                        # Logs de cron (id)
POST /site?action=GetSiteLogs                       # Logs do site (siteName)
POST /site?action=get_site_errlog                   # Erros do site (siteName)
POST /logs/panel/get_logs_bytype                    # Logs por tipo
```

---

## 16. Configuração do Painel

```
POST /config?action=get_config             # Obter configuração
POST /config?action=setPanel               # Definir configuração
POST /config?action=SetControl             # Status de monitoramento
POST /config?action=get_token              # Obter token da API
```

---

## 17. DNS (Plugin dns_manager)

```
POST /plugin?action=a&name=dns_manager&s=act_resolve
```
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `host` | string | Subdomínio (@, www, etc.) |
| `domain` | string | Domínio |
| `value` | string | Valor (IP, CNAME, etc.) |
| `type` | string | A, AAAA, CNAME, MX, TXT, NS |
| `ttl` | int | TTL |
| `act` | string | add, delete, modify |

---

## 18. Docker

Docker é gerenciado via plugin. Endpoints conhecidos:

```
POST /docker?action=get_docker_containers          # Listar containers
POST /docker?action=get_docker_container_details    # Detalhes do container
POST /docker?action=get_docker_images              # Listar imagens
```

Para operações completas de Docker (compose, build, networks), use comandos via terminal SSH ou cron jobs.

---

## Notas

1. **Todas as respostas são JSON.**
2. **Salve cookies entre requisições** para melhor performance.
3. **O IP chamador deve estar na whitelist** do painel (Settings > API Interface).
4. Endpoints não documentados podem ser descobertos via DevTools (F12 > Network) no painel web.
5. Endpoints v2 (`/v2/...`) podem usar header `x-http-token` para autenticação.
