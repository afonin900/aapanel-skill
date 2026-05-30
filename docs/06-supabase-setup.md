# Настройка Supabase

Два варианта использования Supabase с React/TypeScript приложением.

## Вариант 1: Supabase Cloud (Рекомендуется)

Самый простой и надёжный вариант — Supabase берёт инфраструктуру на себя.

### Шаг 1: Создать проект

1. Откройте https://supabase.com/dashboard
2. Создайте новый проект
3. Запишите credentials:
   - `SUPABASE_URL` (например: `https://xxxx.supabase.co`)
   - `SUPABASE_ANON_KEY` (например: `eyJhbGciOi...`)

### Шаг 2: Настроить в приложении

```typescript
// src/lib/supabase.ts
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY

export const supabase = createClient(supabaseUrl, supabaseKey)
```

### Шаг 3: Деплой с переменными окружения

```bash
# Создать .env на сервере
aapanel files SaveFileBody '{
  "path": "/www/wwwroot/my-app/.env",
  "data": "VITE_SUPABASE_URL=https://xxxx.supabase.co\nVITE_SUPABASE_ANON_KEY=eyJhbGciOi...",
  "encoding": "utf-8"
}'
```

### Преимущества Cloud

- Нулевое обслуживание инфраструктуры
- Автоматические резервные копии
- Глобальный CDN
- Auth, Storage, Realtime включены
- Щедрый бесплатный tier

---

## Вариант 2: Supabase Self-hosted (Docker)

Для полного контроля над данными на своём сервере.

### Требования

- Минимум **2GB RAM** и **2 CPU cores**
- Docker установлен
- Свободные порты: 5432, 8000, 3000

### Шаг 1: Установить Docker

```bash
aapanel plugin install_plugin '{"sName":"docker","version":"latest"}'
```

### Шаг 2: Подготовить директории

```bash
aapanel files CreateDir '{"path":"/opt/supabase"}'
```

### Шаг 3: Скачать файлы Supabase

```bash
# docker-compose.yml
aapanel files DownloadFile '{
  "url": "https://raw.githubusercontent.com/supabase/supabase/master/docker/docker-compose.yml",
  "path": "/opt/supabase",
  "filename": "docker-compose.yml"
}'

# .env.example
aapanel files DownloadFile '{
  "url": "https://raw.githubusercontent.com/supabase/supabase/master/docker/.env.example",
  "path": "/opt/supabase",
  "filename": ".env"
}'
```

### Шаг 4: Настроить переменные

```bash
aapanel files SaveFileBody '{
  "path": "/opt/supabase/.env",
  "data": "POSTGRES_PASSWORD=your-secure-password\nJWT_SECRET=your-jwt-secret-at-least-32-chars\nANON_KEY=your-anon-key\nSERVICE_ROLE_KEY=your-service-role-key\nSITE_URL=https://mysite.com\nAPI_EXTERNAL_URL=https://api.mysite.com\nSTUDIO_DEFAULT_ORGANIZATION=My Org\nSTUDIO_DEFAULT_PROJECT=My Project",
  "encoding": "utf-8"
}'
```

### Шаг 5: Открыть порты

```bash
# PostgreSQL
aapanel firewall AddAcceptPort '{"port":"5432","type":"tcp","ps":"PostgreSQL - Supabase"}'

# API Gateway (Kong)
aapanel firewall AddAcceptPort '{"port":"8000","type":"tcp","ps":"Supabase API"}'

# Studio (Dashboard)
aapanel firewall AddAcceptPort '{"port":"3000","type":"tcp","ps":"Supabase Studio"}'
```

### Шаг 6: Запустить Supabase

Создать cron job для автозапуска при старте сервера:

```bash
aapanel crontab AddCrontab '{
  "name": "Start Supabase",
  "type": "startUp",
  "sBody": "cd /opt/supabase && docker compose up -d",
  "sType": "toShell"
}'
```

Запустить немедленно:

```bash
aapanel crontab StartTask '{"id":TASK_ID}'
```

### Шаг 7: Подключить из приложения

```typescript
// src/lib/supabase.ts
import { createClient } from '@supabase/supabase-js'

// Для self-hosted — используйте IP вашего сервера
const supabaseUrl = 'https://YOUR_SERVER_IP:8000'
const supabaseKey = 'your-anon-key'

export const supabase = createClient(supabaseUrl, supabaseKey)
```

### Управление

```bash
# Статус контейнеров (через cron)
aapanel crontab AddCrontab '{
  "name": "Supabase Status",
  "type": "minute",
  "minute": "0",
  "hour": "",
  "sBody": "cd /opt/supabase && docker compose ps > /tmp/supabase-status.txt",
  "sType": "toShell"
}'

# Прочитать статус
aapanel files GetFileBody '{"path":"/tmp/supabase-status.txt"}'
```

---

## Сравнение

| Аспект | Cloud | Self-hosted |
|--------|-------|-------------|
| Настройка | 5 минут | 30+ минут |
| Обслуживание | Нулевое | Вы управляете |
| Стоимость | Free tier + планы | Только сервер |
| Производительность | Глобальный CDN | Зависит от сервера |
| Данные | На серверах Supabase | На вашем сервере |
| Бэкапы | Автоматические | Ручные |
| Рекомендуется для | Большинства случаев | Compliance, sensitive data |
