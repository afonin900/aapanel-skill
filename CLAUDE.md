# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Что это за репо

Claude Code **skill** для управления Linux Ubuntu сервером через aaPanel (BT Panel). Skill определён в `SKILL.md` и устанавливается в `~/.claude/skills/aapanel/`. Все API вызовы идут через `scripts/aapanel_api.sh` (или глобальную команду `aapanel` после установки).

## Установка

```bash
bash install.sh   # устанавливает `aapanel` как глобальную команду
aapanel servers add hetzner https://YOUR_IP:17198 YOUR_API_KEY default
```

## Использование API скрипта

```bash
# Синтаксис: aapanel [--server <имя>] <категория> <действие> [params_json]
aapanel system GetSystemTotal
aapanel --server hetzner files GetDir '{"path":"/www/wwwroot"}'
aapanel nodejs get_project_list
aapanel firewall AddAcceptPort '{"port":"3000","type":"tcp","ps":"React"}'

# Управление серверами
aapanel servers list
aapanel servers add hetzner https://IP:17198 API_KEY default
aapanel servers remove old-server
aapanel servers default hetzner
```

Категории: `system`, `ajax`, `site`, `files`, `database`, `ftp`, `firewall`, `crontab`, `plugin`, `ssl`/`acme`, `config`, `data`, `nodejs`, `python`, `proxy`, `safe`, `safe_ssh`, `logs`, `server`

Категории `nodejs`/`python`/`proxy` формируют URL как `/project/<category>/<action>/1` (не `?action=`).

## Механизм аутентификации

Каждый POST запрос требует `request_time` (Unix timestamp) и `request_token` = `md5(timestamp + md5(api_key))`. Скрипт генерирует это автоматически. Credentials хранятся в `~/.aapanel/servers.conf` — никаких хардкоденных значений в коде.

## Конфиг серверов

Файл `~/.aapanel/servers.conf` (tab-разделённый):
```
# name  url  api_key  [default]
hetzner  https://159.69.216.152:17198  myapikey123  default
prod     https://10.0.0.1:17198        otherapikey
```

## Ключевые reference файлы

- `references/api-catalog.md` — полный каталог 170+ endpoints с параметрами
- `references/supabase-react-setup.md` — Supabase + React/TypeScript
- `docs/02-аутентификация.md` — детали аутентификации
- `docs/05-deploy-react-typescript.md` — полный workflow деплоя React+TS
- `docs/07-troubleshooting.md` — типичные проблемы

## Структура docs/

```
docs/
├── 01-установка.md
├── 02-аутентификация.md
├── 03-быстрый-старт.md
├── 04-категории-api.md
├── 05-deploy-react-typescript.md
├── 06-supabase-setup.md
├── 07-troubleshooting.md
└── 08-безопасность.md
```
