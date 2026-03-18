# Categorias da API — Resumo

Visao geral de todas as 18 categorias da API do aaPanel com seus principais endpoints.

## 1. Sistema (`system`, `ajax`, `server`)

Monitoramento e controle do servidor.

| Endpoint | Descricao |
|----------|-----------|
| `system/GetSystemTotal` | Estatisticas gerais (OS, CPU, RAM, uptime) |
| `system/GetDiskInfo` | Particoes de disco |
| `system/GetNetWork` | Metricas em tempo real |
| `system/ReMemory` | Liberar memoria |
| `system/ServiceAdmin` | Iniciar/parar/reiniciar servicos |
| `ajax/GetTaskCount` | Tarefas em execucao |
| `ajax/UpdatePanel` | Atualizar painel |
| `ajax/get_load_average` | Load average |
| `ajax/GetCpuIo` | CPU e memoria |
| `ajax/GetDiskIo` | Disco I/O |
| `ajax/GetNetWorkIo` | Rede I/O |

## 2. Websites (`site`, `data`)

Gerenciamento completo de sites.

| Endpoint | Descricao |
|----------|-----------|
| `data/getData&table=sites` | Listar sites |
| `site/AddSite` | Criar site |
| `site/DeleteSite` | Deletar site |
| `site/SiteStop` / `SiteStart` | Parar/iniciar site |
| `site/SetEdate` | Definir expiracao |
| `site/GetPHPVersion` | Versoes PHP |
| `site/SetPHPVersion` | Definir versao PHP |
| `site/GetDefaultSite` | Site padrao |
| `site/SetPath` | Diretorio raiz |
| `site/SetHasPwd` | Protecao por senha |
| `site/GetLimitNet` / `SetLimitNet` | Limite de trafego |
| `site/GetIndex` / `SetIndex` | Documentos padrao |
| `site/GetRewriteList` | Regras rewrite |
| `site/GetSiteLogs` | Logs do site |

## 3. Dominios (`site`, `data`)

| Endpoint | Descricao |
|----------|-----------|
| `data/getData&table=domain` | Listar dominios |
| `site/AddDomain` | Adicionar dominio |
| `site/DelDomain` | Remover dominio |

## 4. Arquivos (`files`)

| Endpoint | Descricao |
|----------|-----------|
| `files/GetDir` | Listar diretorio |
| `files/CreateFile` | Criar arquivo |
| `files/CreateDir` | Criar diretorio |
| `files/DeleteFile` / `DeleteDir` | Deletar |
| `files/CopyFile` | Copiar |
| `files/MvFile` | Mover/renomear |
| `files/GetFileBody` | Ler conteudo |
| `files/SaveFileBody` | Salvar conteudo |
| `files/Zip` / `UnZip` | Compactar/extrair |
| `files/SetFileAccess` | Permissoes |
| `files/DownloadFile` | Download de URL |
| `files/upload` | Upload de arquivo |
| `files/GetDirSize` | Tamanho do diretorio |

## 5. Banco de Dados MySQL (`database`, `data`)

| Endpoint | Descricao |
|----------|-----------|
| `data/getData&table=databases` | Listar bancos |
| `database/AddDatabase` | Criar banco |
| `database/DeleteDatabase` | Deletar banco |
| `database/GetInfo` | Info do banco |
| `database/SetupPassword` | Senha root |
| `database/ResDatabasePassword` | Resetar senha |
| `database/GetDatabaseAccess` | Ver acesso |
| `database/SetDatabaseAccess` | Configurar acesso |
| `database/InputSql` | Importar SQL |
| `database/ToBackup` | Backup |
| `database/ReTable` | Reparar |
| `database/OpTable` | Otimizar |
| `database/GetMySQLInfo` | Info MySQL |
| `database/GetDbStatus` | Status |
| `database/BinLog` | Binary log |
| `database/GetErrorLog` | Log de erros |
| `database/GetSlowLogs` | Slow queries |

## 6. FTP (`ftp`, `data`)

| Endpoint | Descricao |
|----------|-----------|
| `data/getData&table=ftps` | Listar contas |
| `ftp/AddUser` | Criar conta |
| `ftp/DeleteUser` | Deletar conta |
| `ftp/SetUserPassword` | Alterar senha |
| `ftp/SetStatus` | Habilitar/desabilitar |

## 7. Firewall (`firewall`, `safe`)

| Endpoint | Descricao |
|----------|-----------|
| `firewall/GetList` | Listar regras |
| `firewall/AddAcceptPort` | Abrir porta |
| `firewall/DelAcceptPort` | Fechar porta |
| `firewall/AddDropAddress` | Bloquear IP |
| `firewall/DelDropAddress` | Desbloquear IP |
| `firewall/SetFirewallStatus` | Toggle firewall |
| `firewall/SetSshStatus` | Toggle SSH |
| `firewall/SetPing` | Toggle ping |
| `safe/firewall/get_rules_list` | Regras v2 |
| `safe/firewall/create_rules` | Criar regra v2 |
| `safe/firewall/get_forward_list` | Port forwarding |
| `safe/firewall/create_forward` | Criar forward |
| `safe/firewall/get_ip_rules_list` | Regras de IP |
| `safe/firewall/get_country_list` | Geo-blocking |
| `safe/firewall/get_firewall_info` | Info firewall |

## 8. Cron Jobs (`crontab`)

| Endpoint | Descricao |
|----------|-----------|
| `crontab/GetCrontab` | Listar tarefas |
| `crontab/AddCrontab` | Criar tarefa |
| `crontab/DelCrontab` | Deletar tarefa |
| `crontab/StartTask` | Executar agora |
| `crontab/set_cron_status` | Habilitar/desabilitar |
| `crontab/modify_crond` | Modificar |
| `crontab/GetLogs` | Logs |

## 9. SSL/HTTPS (`site`, `acme`)

| Endpoint | Descricao |
|----------|-----------|
| `site/GetSSL` | Ver SSL do site |
| `site/SetSSL` | Deploy certificado |
| `site/CloseSSLConf` | Desabilitar SSL |
| `acme/apply_cert_api` | Let's Encrypt |
| `acme/renew_cert` | Renovar certificado |

## 10. Software/Plugins (`plugin`)

| Endpoint | Descricao |
|----------|-----------|
| `plugin/get_soft_list` | Listar software |
| `plugin/install_plugin` | Instalar |
| `plugin/uninstall_plugin` | Desinstalar |

## 11. Node.js (`nodejs`)

| Endpoint | Descricao |
|----------|-----------|
| `nodejs/get_project_list` | Listar projetos |
| `nodejs/create_project` | Criar projeto |
| `nodejs/modify_project` | Modificar |
| `nodejs/remove_project` | Deletar |
| `nodejs/start_project` | Iniciar |
| `nodejs/stop_project` | Parar |
| `nodejs/restart_project` | Reiniciar |
| `nodejs/install_packages` | npm install |
| `nodejs/install_module` | Instalar modulo |
| `nodejs/bind_extranet` | Proxy reverso |
| `nodejs/project_add_domain` | Adicionar dominio |
| `nodejs/get_project_log` | Logs |
| `nodejs/get_nodejs_version` | Versoes disponiveis |

## 12. Python (`python`)

| Endpoint | Descricao |
|----------|-----------|
| `python/get_project_list` | Listar projetos |
| `python/create_project` | Criar |
| `python/start_project` / `stop_project` | Controle |
| `python/install_packages` | pip install |
| `python/project_add_domain` | Dominio |
| `python/bind_extranet` | Proxy |

## 13. Proxy Reverso (`proxy`)

| Endpoint | Descricao |
|----------|-----------|
| `proxy/get_project_list` | Listar |
| `proxy/create_project` | Criar |
| `proxy/add_proxy` | Regra de proxy |
| `proxy/set_proxy_header` | Headers |
| `proxy/set_proxy_cache` | Cache |
| `proxy/set_ip_blacklist` | IP blacklist |

## 14-18. Backup, Logs, Config, DNS, Docker

Veja detalhes completos em [api-catalog.md](../references/api-catalog.md).
