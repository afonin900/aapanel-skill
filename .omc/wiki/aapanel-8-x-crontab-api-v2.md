---
title: "AAPanel 8.x — Crontab API (v2)"
tags: ["crontab", "aapanel", "api", "v2", "breaking-change"]
created: 2026-05-30T09:07:17.139Z
updated: 2026-05-30T09:07:17.139Z
sources: []
links: []
category: reference
confidence: medium
schemaVersion: 1
---

# AAPanel 8.x — Crontab API (v2)

# AAPanel 8.x — Crontab API (v2)

## Суть изменения

В AAPanel 8.11.0+ все crontab-операции переехали на `/v2/crontab`.
Скрипт `aapanel` обрабатывает это автоматически — вызовы не меняются.

## Endpoint

```
POST /v2/crontab
```

`action` передаётся в **POST body**, не в URL.

## Обязательные поля для AddCrontab / EditCrontab

| Поле | Значение для shell-задачи |
|------|--------------------------|
| `name` | название задачи |
| `type` | `day` / `hour` / `minute-n` / `week` / `month` |
| `where1` | интервал в минутах (только для `minute-n`), иначе `""` |
| `hour` | час (int) |
| `minute` | минута (int) |
| `sType` | `toShell` / `toUrl` / `database` / `site` |
| `sBody` | shell-команда |
| `sName` | `""` для shell |
| `save` | `0` для shell |
| `backupTo` | `"localhost"` |
| `urladdress` | `""` |
| `save_local` | `0` |
| `notice` | `0` |
| `notice_channel` | `""` |

## Пример — каждый день в 4:00

```bash
aapanel crontab AddCrontab '{
  "name":"deploy","type":"day","where1":"","hour":4,"minute":0,
  "sType":"toShell","sBody":"/www/scripts/deploy.sh",
  "sName":"","save":0,"backupTo":"localhost",
  "urladdress":"","save_local":0,"notice":0,"notice_channel":""
}'
```

## Пример — каждые 100 минут

```bash
aapanel crontab AddCrontab '{
  "name":"health","type":"minute-n","where1":"100","hour":0,"minute":0,
  "sType":"toShell","sBody":"curl -sf http://localhost/health",
  "sName":"","save":0,"backupTo":"localhost",
  "urladdress":"","save_local":0,"notice":0,"notice_channel":""
}'
```

## Связанные файлы

- `scripts/aapanel_api.sh` — `is_v2_category()` + маршрутизация
- `references/api-catalog.md` — раздел 8, полная документация

