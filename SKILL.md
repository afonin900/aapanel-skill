---
name: aapanel
description: |
  Управление Linux Ubuntu сервером через aaPanel — создание сайтов, управление файлами,
  базами данных, Node.js/React приложениями, firewall, SSL, cron jobs, бэкапами и Docker.
  Используй когда упоминают 'aaPanel', 'панель сервера', 'управление сервером',
  'создать сайт', 'задеплоить приложение', 'деплой на сервер', 'настроить сервер',
  'установить на сервер', 'загрузить на сервер', 'управлять VPS', 'среда Linux',
  'настроить базу данных на сервере', 'Supabase на сервере', 'деплой React',
  'деплой TypeScript', 'деплой Node.js', 'управлять firewall', 'SSL сервера',
  'бэкап сервера', или любые вариации управления сервером через панель.
---

# aaPanel — Управление Linux Ubuntu сервером

Панель управления Linux Ubuntu сервером с поддержкой сайтов, Node.js/React приложений, баз данных, firewall, SSL и многого другого.

**Команда:** `aapanel` (после установки через `bash install.sh`)
**Аутентификация:** API Key с подписью по timestamp (см. раздел Auth)

## Аутентификация

Все запросы используют **POST** и требуют двух параметров подписи:

| Параметр | Значение |
|----------|----------|
| `request_time` | Текущий Unix timestamp |
| `request_token` | `md5(str(request_time) + md5(api_key))` |

API Key хранится в `~/.aapanel/servers.conf`. Используй скрипт `scripts/aapanel_api.sh` (или глобальную команду `aapanel`) для аутентифицированных вызовов.

**Важно:** IP вызывающей машины должен быть в whitelist панели.

## Управление серверами

```bash
# Добавить сервер (первый становится default)
aapanel servers add hetzner https://YOUR_IP:17198 YOUR_API_KEY default

# Список серверов (* = default)
aapanel servers list

# Сменить default
aapanel servers default hetzner

# Удалить сервер
aapanel servers remove old-server
```

## Основные workflows

### 1. Деплой React + TypeScript приложения

1. **Проверить систему:** `GetSystemTotal` — убедиться в наличии ресурсов
2. **Установить Node.js:** Через software management (`install_plugin` с `sName=nodejs`)
3. **Создать Node.js проект:** `/project/nodejs/create_project/1`
4. **Загрузить файлы:** Через `files?action=upload` или `DownloadFile` (из URL)
5. **Установить зависимости:** `/project/nodejs/install_packages/1`
6. **Настроить домен:** `/project/nodejs/project_add_domain/1`
7. **Включить reverse proxy:** `/project/nodejs/bind_extranet/1`
8. **Настроить SSL:** `acme?action=apply_cert_api`
9. **Запустить приложение:** `/project/nodejs/start_project/1`

### 2. Настройка Supabase (Self-hosted)

Supabase требует Docker. Workflow:

1. **Установить Docker:** Через software management
2. **Создать директорию:** `files?action=CreateDir` → `/opt/supabase`
3. **Скачать docker-compose:** `files?action=DownloadFile` с URL Supabase
4. **Создать .env файл:** `files?action=SaveFileBody` с настройками
5. **Открыть порты:** Firewall → открыть 5432 (PostgreSQL), 8000 (API), 3000 (Studio)
6. **Запустить:** Через cron `toShell`: `docker compose up -d`

Альтернатива — Supabase Cloud (managed) с подключением через переменные окружения.

### 3. Управление MySQL базами данных

1. **Создать базу:** `database?action=AddDatabase`
2. **Настроить удалённый доступ:** `database?action=SetDatabaseAccess`
3. **Бэкап:** `database?action=ToBackup`
4. **Импорт SQL:** `database?action=InputSql`

## Справочник API

Полный каталог 170+ endpoints: [references/api-catalog.md](references/api-catalog.md)

**Доступные категории:**

| Категория | Endpoints | Описание |
|-----------|-----------|----------|
| Система | 12 | CPU, память, диск, сеть, сервисы |
| Сайты | 30+ | Создание, удаление, настройка PHP сайтов |
| Домены | 3 | Добавление, список, удаление доменов |
| Файлы | 14 | Upload, download, создание, редактирование, архивирование |
| Базы данных | 25+ | MySQL: создание, бэкап, импорт, настройка |
| FTP | 6 | Создание, удаление, настройка FTP аккаунтов |
| Firewall | 20+ | Порты, IP, forwarding, geo-blocking |
| Cron Jobs | 8 | Планирование, выполнение, мониторинг задач |
| SSL/HTTPS | 4 | Let's Encrypt, деплой сертификатов |
| Программы | 3 | Установка, удаление плагинов |
| Node.js | 30+ | Проекты, модули, домены, логи |
| Python | 20+ | Проекты, пакеты, домены |
| Reverse Proxy | 15+ | Создание, настройка, кэш, заголовки |
| Логи | 6 | Панель, сайты, ошибки, cron |
| Бэкап | 4 | Сайты, базы данных |
| Конфигурация | 4 | Настройки панели |

## Утилита командной строки

Скрипт `scripts/aapanel_api.sh` (или глобальная команда `aapanel` после установки):

```bash
# Синтаксис
aapanel [--server <имя>] <категория> <действие> [params_json]
aapanel servers list|add|remove|default

# Статус системы
aapanel system GetSystemTotal
aapanel --server hetzner system GetSystemTotal

# Файлы
aapanel files GetDir '{"path":"/www/wwwroot"}'
aapanel files CreateDir '{"path":"/www/wwwroot/my-app"}'

# Скачать файл по URL
aapanel files DownloadFile '{"url":"https://example.com/file.zip","path":"/www/wwwroot","filename":"file.zip"}'

# Создать базу данных
aapanel database AddDatabase '{"name":"mydb","db_user":"myuser","password":"StrongPass123!","codeing":"utf8mb4","address":"127.0.0.1","dtype":"MySQL","ps":"App DB"}'

# Создать Node.js проект
aapanel nodejs create_project '{"project_name":"my-react","project_path":"/www/wwwroot/my-react","run_script":"npm start","node_version":"20","port":"3000"}'

# Открыть порт
aapanel firewall AddAcceptPort '{"port":"3000","type":"tcp","ps":"React app"}'

# SSL сертификат
aapanel ssl apply_cert_api '{"domains":["mysite.com"],"auth_type":"http"}'
```

Полный справочник endpoints: [references/api-catalog.md](references/api-catalog.md)

## Выполнение shell-команд через cron

Ключевая фича для деплоя и автоматизации — запуск shell-команд через crontab `toShell`:

```bash
# Разовое выполнение команды (создать задачу и сразу запустить)
aapanel crontab AddCrontab '{"name":"Deploy","type":"day","hour":"3","minute":"0","sBody":"cd /www/wwwroot/my-app && git pull && npm install && npm run build","sType":"toShell"}'

# Запустить задачу немедленно
aapanel crontab StartTask '{"id":TASK_ID}'

# Автозапуск при старте сервера
aapanel crontab AddCrontab '{"name":"Start App","type":"startUp","sBody":"cd /www/wwwroot/my-app && npm start","sType":"toShell"}'
```
