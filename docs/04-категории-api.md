# Категории API — Сводка

Обзор всех 18 категорий API aaPanel с основными endpoints.

## 1. Система (`system`, `ajax`, `server`)

Мониторинг и управление сервером.

| Endpoint | Описание |
|----------|----------|
| `system/GetSystemTotal` | Общая статистика (ОС, CPU, RAM, uptime) |
| `system/GetDiskInfo` | Разделы диска |
| `system/GetNetWork` | Метрики в реальном времени |
| `system/ReMemory` | Освободить память |
| `system/ServiceAdmin` | Запустить/остановить/перезапустить сервисы |
| `ajax/GetTaskCount` | Запущенные задачи |
| `ajax/UpdatePanel` | Обновить панель |
| `ajax/get_load_average` | Load average |
| `ajax/GetCpuIo` | CPU и память |
| `ajax/GetDiskIo` | Диск I/O |
| `ajax/GetNetWorkIo` | Сеть I/O |

## 2. Сайты (`site`, `data`)

Полное управление сайтами.

| Endpoint | Описание |
|----------|----------|
| `data/getData&table=sites` | Список сайтов |
| `site/AddSite` | Создать сайт |
| `site/DeleteSite` | Удалить сайт |
| `site/SiteStop` / `SiteStart` | Остановить/запустить сайт |
| `site/SetEdate` | Установить срок действия |
| `site/GetPHPVersion` | Версии PHP |
| `site/SetPHPVersion` | Установить версию PHP |
| `site/GetDefaultSite` | Сайт по умолчанию |
| `site/SetPath` | Корневая директория |
| `site/SetHasPwd` | Защита паролем |
| `site/GetLimitNet` / `SetLimitNet` | Лимит трафика |
| `site/GetIndex` / `SetIndex` | Документы по умолчанию |
| `site/GetRewriteList` | Правила rewrite |
| `site/GetSiteLogs` | Логи сайта |

## 3. Домены (`site`, `data`)

| Endpoint | Описание |
|----------|----------|
| `data/getData&table=domain` | Список доменов |
| `site/AddDomain` | Добавить домен |
| `site/DelDomain` | Удалить домен |

## 4. Файлы (`files`)

| Endpoint | Описание |
|----------|----------|
| `files/GetDir` | Список файлов |
| `files/CreateFile` | Создать файл |
| `files/CreateDir` | Создать директорию |
| `files/DeleteFile` / `DeleteDir` | Удалить |
| `files/CopyFile` | Копировать |
| `files/MvFile` | Переместить/переименовать |
| `files/GetFileBody` | Прочитать содержимое |
| `files/SaveFileBody` | Сохранить содержимое |
| `files/Zip` / `UnZip` | Архивировать/разархивировать |
| `files/SetFileAccess` | Права доступа |
| `files/DownloadFile` | Скачать по URL |
| `files/upload` | Загрузить файл |
| `files/GetDirSize` | Размер директории |

## 5. Базы данных MySQL (`database`, `data`)

| Endpoint | Описание |
|----------|----------|
| `data/getData&table=databases` | Список баз данных |
| `database/AddDatabase` | Создать базу данных |
| `database/DeleteDatabase` | Удалить базу данных |
| `database/GetInfo` | Информация о базе |
| `database/SetupPassword` | Пароль root |
| `database/ResDatabasePassword` | Сбросить пароль |
| `database/GetDatabaseAccess` | Просмотреть доступ |
| `database/SetDatabaseAccess` | Настроить доступ |
| `database/InputSql` | Импорт SQL |
| `database/ToBackup` | Резервная копия |
| `database/ReTable` | Восстановить таблицы |
| `database/OpTable` | Оптимизировать |
| `database/GetMySQLInfo` | Информация MySQL |
| `database/GetDbStatus` | Статус |
| `database/BinLog` | Binary log |
| `database/GetErrorLog` | Лог ошибок |
| `database/GetSlowLogs` | Медленные запросы |

## 6. FTP (`ftp`, `data`)

| Endpoint | Описание |
|----------|----------|
| `data/getData&table=ftps` | Список аккаунтов |
| `ftp/AddUser` | Создать аккаунт |
| `ftp/DeleteUser` | Удалить аккаунт |
| `ftp/SetUserPassword` | Сменить пароль |
| `ftp/SetStatus` | Включить/отключить |

## 7. Firewall (`firewall`, `safe`)

| Endpoint | Описание |
|----------|----------|
| `firewall/GetList` | Список правил |
| `firewall/AddAcceptPort` | Открыть порт |
| `firewall/DelAcceptPort` | Закрыть порт |
| `firewall/AddDropAddress` | Заблокировать IP |
| `firewall/DelDropAddress` | Разблокировать IP |
| `firewall/SetFirewallStatus` | Вкл/выкл firewall |
| `firewall/SetSshStatus` | Вкл/выкл SSH |
| `firewall/SetPing` | Вкл/выкл ping |
| `safe/firewall/get_rules_list` | Правила v2 |
| `safe/firewall/create_rules` | Создать правило v2 |
| `safe/firewall/get_forward_list` | Port forwarding |
| `safe/firewall/create_forward` | Создать forward |
| `safe/firewall/get_ip_rules_list` | IP правила |
| `safe/firewall/get_country_list` | Geo-blocking |
| `safe/firewall/get_firewall_info` | Информация firewall |

## 8. Cron Jobs (`crontab`)

| Endpoint | Описание |
|----------|----------|
| `crontab/GetCrontab` | Список задач |
| `crontab/AddCrontab` | Создать задачу |
| `crontab/DelCrontab` | Удалить задачу |
| `crontab/StartTask` | Запустить немедленно |
| `crontab/set_cron_status` | Включить/отключить |
| `crontab/modify_crond` | Изменить |
| `crontab/GetLogs` | Логи |

## 9. SSL/HTTPS (`site`, `acme`)

| Endpoint | Описание |
|----------|----------|
| `site/GetSSL` | Просмотреть SSL сайта |
| `site/SetSSL` | Развернуть сертификат |
| `site/CloseSSLConf` | Отключить SSL |
| `acme/apply_cert_api` | Let's Encrypt |
| `acme/renew_cert` | Обновить сертификат |

## 10. Программы/Плагины (`plugin`)

| Endpoint | Описание |
|----------|----------|
| `plugin/get_soft_list` | Список ПО |
| `plugin/install_plugin` | Установить |
| `plugin/uninstall_plugin` | Удалить |

## 11. Node.js (`nodejs`)

| Endpoint | Описание |
|----------|----------|
| `nodejs/get_project_list` | Список проектов |
| `nodejs/create_project` | Создать проект |
| `nodejs/modify_project` | Изменить |
| `nodejs/remove_project` | Удалить |
| `nodejs/start_project` | Запустить |
| `nodejs/stop_project` | Остановить |
| `nodejs/restart_project` | Перезапустить |
| `nodejs/install_packages` | npm install |
| `nodejs/install_module` | Установить модуль |
| `nodejs/bind_extranet` | Reverse proxy |
| `nodejs/project_add_domain` | Добавить домен |
| `nodejs/get_project_log` | Логи |
| `nodejs/get_nodejs_version` | Доступные версии |

## 12. Python (`python`)

| Endpoint | Описание |
|----------|----------|
| `python/get_project_list` | Список проектов |
| `python/create_project` | Создать |
| `python/start_project` / `stop_project` | Управление |
| `python/install_packages` | pip install |
| `python/project_add_domain` | Домен |
| `python/bind_extranet` | Proxy |

## 13. Reverse Proxy (`proxy`)

| Endpoint | Описание |
|----------|----------|
| `proxy/get_project_list` | Список |
| `proxy/create_project` | Создать |
| `proxy/add_proxy` | Правило proxy |
| `proxy/set_proxy_header` | Заголовки |
| `proxy/set_proxy_cache` | Кэш |
| `proxy/set_ip_blacklist` | IP blacklist |

## 14–18. Бэкап, Логи, Конфигурация, DNS, Docker

Полные детали в [api-catalog.md](../references/api-catalog.md).
