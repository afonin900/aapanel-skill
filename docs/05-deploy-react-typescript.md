# Деплой React + TypeScript приложения

Полное руководство по деплою React + TypeScript на сервер через aaPanel.

## Вариант A: Статический сайт (Vite Build)

Для React приложений, которые генерируют статические файлы (SPA).

### 1. Локальный build

```bash
# В вашем проекте
npm run build
# Генерирует папку dist/
```

### 2. Архивировать для загрузки

```bash
cd dist
zip -r ../dist.zip .
```

### 3. Разместить архив (временно)

Загрузите `dist.zip` в любое место с публичным URL (GitHub Releases, S3, etc.).

### 4. Деплой на сервер

```bash
# Создать директорию
aapanel files CreateDir '{"path":"/www/wwwroot/my-react-app"}'

# Скачать build
aapanel files DownloadFile '{"url":"https://URL_TO_ZIP/dist.zip","path":"/www/wwwroot/my-react-app","filename":"dist.zip"}'

# Распаковать
aapanel files UnZip '{"sfile":"/www/wwwroot/my-react-app/dist.zip","dfile":"/www/wwwroot/my-react-app","type":"zip"}'

# Удалить архив
aapanel files DeleteFile '{"path":"/www/wwwroot/my-react-app/dist.zip"}'

# Создать сайт в Nginx
aapanel site AddSite '{"webname":"{\"domain\":\"mysite.com\",\"domainlist\":[],\"count\":0}","path":"/www/wwwroot/my-react-app","type_id":0,"type":"PHP","version":"00","port":"80","ps":"React App"}'

# SSL (Let's Encrypt)
aapanel ssl apply_cert_api '{"domains":["mysite.com"],"auth_type":"http"}'
```

### 5. Настроить SPA routing

Чтобы React Router работал, настройте Nginx перенаправлять всё на `index.html`:

```bash
# Прочитать текущий конфиг Nginx
aapanel files GetFileBody '{"path":"/www/server/panel/vhost/nginx/mysite.com.conf"}'

# Добавить try_files в конфиг (через SaveFileBody)
# В секции location /: try_files $uri $uri/ /index.html;
```

---

## Вариант B: SSR/Node.js приложение (Next.js, Remix, etc.)

Для приложений, которым нужен Node.js сервер.

### 1. Подготовить на сервере

```bash
# Создать директорию
aapanel files CreateDir '{"path":"/www/wwwroot/my-nextjs"}'

# Проверить наличие Node.js
aapanel nodejs is_install_nodejs

# Установить Node.js если нужно
aapanel plugin install_plugin '{"sName":"nodejs","version":"20"}'
```

### 2. Загрузить проект

```bash
# Сжать проект (исключая node_modules)
# Локально: tar -czf project.tar.gz --exclude=node_modules --exclude=.git .

# Скачать на сервер
aapanel files DownloadFile '{"url":"URL_TO_FILE","path":"/www/wwwroot/my-nextjs","filename":"project.tar.gz"}'

# Распаковать
aapanel files UnZip '{"sfile":"/www/wwwroot/my-nextjs/project.tar.gz","dfile":"/www/wwwroot/my-nextjs","type":"tar.gz"}'
```

### 3. Создать Node.js проект

```bash
# Создать проект
aapanel nodejs create_project '{"project_name":"my-nextjs","project_path":"/www/wwwroot/my-nextjs","run_script":"npm start","node_version":"20","port":"3000"}'

# Установить зависимости
aapanel nodejs install_packages '{"project_name":"my-nextjs"}'
```

### 4. Настроить внешний доступ

```bash
# Открыть порт
aapanel firewall AddAcceptPort '{"port":"3000","type":"tcp","ps":"Next.js"}'

# Reverse proxy (Nginx → Node)
aapanel nodejs bind_extranet '{"project_name":"my-nextjs"}'

# Добавить домен
aapanel nodejs project_add_domain '{"project_name":"my-nextjs","domain":"mysite.com"}'
```

### 5. Запустить и мониторить

```bash
# Запустить
aapanel nodejs start_project '{"project_name":"my-nextjs"}'

# Проверить статус
aapanel nodejs get_project_run_state '{"project_name":"my-nextjs"}'

# Просмотреть логи
aapanel nodejs get_project_log '{"project_name":"my-nextjs"}'
```

---

## Переменные окружения

Создать `.env` файл на сервере:

```bash
aapanel files SaveFileBody '{"path":"/www/wwwroot/my-app/.env","data":"VITE_SUPABASE_URL=https://xxxx.supabase.co\nVITE_SUPABASE_ANON_KEY=eyJhbGciOi...\nNODE_ENV=production","encoding":"utf-8"}'
```

## CI/CD автоматизация

Cron job для автоматического pull и деплоя:

```bash
aapanel crontab AddCrontab '{"name":"Deploy React App","type":"minute","hour":"","minute":"30","sBody":"cd /www/wwwroot/my-app && git pull && npm install && npm run build","sType":"toShell"}'
```

Или используйте GitHub Actions, вызывая API aaPanel напрямую.

## На конкретном сервере

```bash
aapanel --server hetzner files CreateDir '{"path":"/www/wwwroot/my-react-app"}'
aapanel --server hetzner nodejs create_project '{"project_name":"my-react","project_path":"/www/wwwroot/my-react","run_script":"npm start","node_version":"20","port":"3000"}'
```
