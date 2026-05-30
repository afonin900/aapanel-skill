# aaPanel Skill для Claude Code

Skill для управления Linux Ubuntu сервером через aaPanel прямо из Claude Code. Создавайте сайты, управляйте файлами, базами данных, Node.js/React приложениями, firewall, SSL, cron jobs, резервными копиями и Docker.

## Обзор

| Параметр | Значение |
|----------|----------|
| **ОС** | Linux Ubuntu |
| **Панель** | aaPanel (BT Panel) |
| **HTTP метод** | POST (все endpoints) |
| **Аутентификация** | API Key + HMAC (timestamp + md5) |

## Структура репозитория

```
aapanel-skill/
├── README.md                           # Этот файл
├── SKILL.md                            # Определение skill для Claude Code
├── install.sh                          # Установщик глобальной команды `aapanel`
├── scripts/
│   └── aapanel_api.sh                  # CLI скрипт для аутентифицированных вызовов
├── references/
│   ├── api-catalog.md                  # Каталог 170+ endpoints
│   └── supabase-react-setup.md         # Руководство: Supabase + React/TypeScript
├── docs/
│   ├── 01-установка.md                 # Как установить skill
│   ├── 02-аутентификация.md            # Как работает аутентификация
│   ├── 03-быстрый-старт.md             # Быстрый старт с примерами
│   ├── 04-категории-api.md             # Сводка всех категорий
│   ├── 05-deploy-react-typescript.md   # Полный деплой React+TS
│   ├── 06-supabase-setup.md            # Настройка Supabase
│   ├── 07-troubleshooting.md           # Решение типичных проблем
│   └── 08-безопасность.md              # Рекомендации по безопасности
└── examples/
    ├── deploy-react-app.sh             # Пример: деплой React
    ├── setup-supabase-docker.sh        # Пример: Supabase self-hosted
    ├── backup-automatico.sh            # Пример: автоматический бэкап
    └── setup-completo.sh               # Пример: полный стек
```

## Быстрая установка

### 1. Клонировать и установить

```bash
git clone https://github.com/professordyx/aapanel-skill.git
cd aapanel-skill
bash install.sh
```

После установки команда `aapanel` станет доступна глобально.

### 2. Добавить сервер

```bash
aapanel servers add hetzner https://YOUR_IP:17198 YOUR_API_KEY default
```

### 3. Добавить IP в whitelist

В панели aaPanel: **Settings > API Interface > IP Whitelist** — добавьте IP вашей машины.

```bash
curl -s https://api.ipify.org  # узнать свой IP
```

### 4. Проверить подключение

```bash
aapanel system GetSystemTotal
aapanel --server hetzner system GetSystemTotal
```

## Использование

После установки можно управлять сервером командами:

```bash
# Статус системы
aapanel system GetSystemTotal

# Файлы
aapanel files GetDir '{"path":"/www/wwwroot"}'

# Node.js проекты
aapanel nodejs get_project_list

# Открыть порт
aapanel firewall AddAcceptPort '{"port":"3000","type":"tcp","ps":"React"}'

# SSL
aapanel ssl apply_cert_api '{"domains":["mysite.com"],"auth_type":"http"}'
```

Или просто попросите Claude Code на естественном языке:

- *«Создай сайт на сервере для mysite.com»*
- *«Задеплой React приложение на сервер hetzner»*
- *«Открой порт 3000 в firewall»*
- *«Сделай backup базы данных»*

## Управление несколькими серверами

```bash
# Добавить серверы
aapanel servers add hetzner https://159.69.216.152:17198 API_KEY_1 default
aapanel servers add prod    https://10.0.0.1:17198       API_KEY_2

# Список серверов
aapanel servers list

# Вызов на конкретном сервере
aapanel --server prod system GetSystemTotal

# Сменить сервер по умолчанию
aapanel servers default prod
```

## Категории API

| # | Категория | Endpoints | Описание |
|---|-----------|-----------|----------|
| 1 | Система | 12 | CPU, память, диск, сеть, сервисы |
| 2 | Сайты | 30+ | Создание, удаление, настройка сайтов |
| 3 | Домены | 3 | Добавление, список, удаление доменов |
| 4 | Файлы | 14 | Upload, download, создание, редактирование |
| 5 | Базы данных | 25+ | MySQL: создание, бэкап, импорт |
| 6 | FTP | 6 | FTP аккаунты |
| 7 | Firewall | 20+ | Порты, IP, forwarding, geo-blocking |
| 8 | Cron Jobs | 8 | Планирование, выполнение, мониторинг |
| 9 | SSL/HTTPS | 4 | Let's Encrypt, сертификаты |
| 10 | Программы | 3 | Установка, удаление плагинов |
| 11 | Node.js | 30+ | Проекты, модули, домены, логи |
| 12 | Python | 20+ | Проекты, пакеты, домены |
| 13 | Reverse Proxy | 15+ | Создание, кэш, заголовки |
| 14 | Бэкап | 4 | Сайты и базы данных |
| 15 | Логи | 6 | Панель, сайты, ошибки, cron |
| 16 | Конфигурация | 4 | Настройки панели |
| 17 | DNS | 1+ | DNS записи (плагин) |
| 18 | Docker | 3+ | Контейнеры, образы |

> **Итого: 170+ задокументированных endpoints**

## Рекомендуемый стек

| Компонент | Технология | Где |
|-----------|-----------|-----|
| Frontend | React + TypeScript (Vite) | aaPanel Node.js или статический сайт |
| Backend API | Supabase (PostgREST) | Supabase Cloud или Docker |
| База данных | PostgreSQL (через Supabase) | Supabase Cloud или Docker |
| Auth | Supabase Auth | Supabase |
| Reverse Proxy | Nginx (через aaPanel) | Сервер |
| SSL | Let's Encrypt (через aaPanel) | Сервер |

## Лицензия

MIT
