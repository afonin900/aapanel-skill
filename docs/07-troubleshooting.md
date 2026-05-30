# Решение проблем

Типичные проблемы и способы их устранения.

## Ошибки аутентификации

### "Invalid token" или "Token expired"

**Причина**: Время на вашем компьютере не синхронизировано с сервером.

**Решение**:
```bash
# Проверить локальное время
date

# Синхронизировать часы
# macOS
sudo sntp -sS time.apple.com

# Linux
sudo ntpdate -u ntp.ubuntu.com
```

### "IP not in whitelist"

**Причина**: IP вашей машины не добавлен в whitelist aaPanel.

**Решение**:
1. Узнайте ваш IP: `curl -s https://api.ipify.org`
2. Откройте панель aaPanel в браузере
3. Перейдите в **Settings > API Interface > IP Whitelist**
4. Добавьте ваш IP

**Заметка**: Если IP меняется часто (динамический), используйте VPN с фиксированным IP.

### Сервер не найден в конфиге

```bash
# Проверить список серверов
aapanel servers list

# Добавить сервер
aapanel servers add hetzner https://YOUR_IP:17198 YOUR_API_KEY default
```

---

## Ошибки подключения

### "Connection refused" или timeout

**Возможные причины**:
1. Сервер выключен
2. Порт 17198 заблокирован в firewall сервера
3. Firewall провайдера блокирует порт

**Проверить доступность**:
```bash
# Проверить порт
nc -zv YOUR_SERVER_IP 17198

# Проверить через curl
curl -sk https://YOUR_SERVER_IP:17198/ -o /dev/null -w "%{http_code}"
```

### "SSL certificate problem"

**Причина**: aaPanel использует self-signed сертификат.

**Решение**: Скрипт `aapanel_api.sh` уже использует `-k` (insecure) в curl. При использовании других инструментов — отключите проверку SSL.

---

## Проблемы с Node.js

### Проект не запускается

```bash
# Посмотреть логи
aapanel nodejs get_project_log '{"project_name":"MY_PROJECT"}'

# Проверить занятость порта
aapanel nodejs check_port_is_used '{"port":"3000"}'

# Перезапустить
aapanel nodejs restart_project '{"project_name":"MY_PROJECT"}'
```

### "Module not found"

```bash
# Переустановить зависимости
aapanel nodejs reinstall_packages '{"project_name":"MY_PROJECT"}'

# Или пересобрать
aapanel nodejs rebuild_project '{"project_name":"MY_PROJECT"}'
```

### Несовместимая версия Node.js

```bash
# Посмотреть доступные версии
aapanel nodejs get_nodejs_version

# Сменить версию
aapanel nodejs set_project_nodejs_version '{"project_name":"MY_PROJECT","version":"20"}'
```

---

## Проблемы с базами данных

### MySQL не подключается удалённо

```bash
# Проверить доступ
aapanel database GetDatabaseAccess '{"name":"mydb"}'

# Разрешить доступ (% = любой IP)
aapanel database SetDatabaseAccess '{"name":"mydb","access":"%"}'

# Проверить порт в firewall
aapanel firewall GetList '{"p":1,"limit":50}'

# Открыть порт 3306
aapanel firewall AddAcceptPort '{"port":"3306","type":"tcp","ps":"MySQL"}'
```

### Забыли пароль от базы

```bash
aapanel database ResDatabasePassword '{"id":ID,"name":"mydb","password":"NewPassword123!"}'
```

---

## Проблемы с firewall

### Порт открыт, но недоступен

Возможный конфликт между классическим firewall и System Firewall v2.

```bash
# Проверить оба
aapanel firewall GetList '{"p":1,"limit":50}'
aapanel safe get_rules_list

# Информация о firewall
aapanel safe get_firewall_info
```

---

## Проблемы с SSL

### Сертификат не выдаётся

```bash
# Убедитесь: домен указывает на IP сервера?
# Сайт доступен на порту 80?

# Попробовать через DNS
aapanel ssl apply_cert_api '{"domains":["mysite.com"],"auth_type":"dns"}'
```

---

## Общие советы

1. **Всегда смотрите логи** — первый шаг при любой проблеме:
   ```bash
   aapanel nodejs get_project_log '{"project_name":"MY_PROJECT"}'
   ```

2. **Перезапустите Nginx** после изменений конфигурации:
   ```bash
   aapanel system ServiceAdmin '{"name":"nginx","type":"restart"}'
   ```

3. **Проверьте место на диске** если что-то перестало работать:
   ```bash
   aapanel system GetDiskInfo
   ```

4. **Освободите память** если сервер тормозит:
   ```bash
   aapanel system ReMemory
   ```
