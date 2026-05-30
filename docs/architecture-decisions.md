# Architecture Decision Record (ADR)

Журнал архитектурных решений проекта aapanel-skill.

**Принципы ведения:**
- Одна запись — одно решение. Принятые записи не редактируются (immutability).
- Пересмотренное решение → старое получает статус `superseded by ADR-XXX`, новое ссылается на старое.

**Статусы:** `accepted` · `superseded by ADR-XXX`

---

## ADR-001: Миграция crontab на /v2/crontab для AAPanel 8.x

> В контексте поддержки AAPanel 8.x, столкнувшись с тем что `/crontab?action=AddCrontab` возвращает 404, мы перевели категорию `crontab` на endpoint `/v2/crontab` с action в POST body, чтобы восстановить работу cron-операций, принимая что старый endpoint `/crontab?action=X` больше не поддерживается для записи в 8.x.

**Date:** 2026-05-30
**Status:** accepted

**Context:** AAPanel 8.11.0 (beta) перенёс все write-операции crontab на новый v2 API. `AddCrontab`, `EditCrontab`, `DelCrontab` возвращали 404. `GetCrontab` продолжал работать на старом endpoint. `add_cron` возвращал "Specific parameters are invalid!" из-за изменившейся структуры параметров.

**Options considered:**

| Option | Pros | Cons |
|--------|------|------|
| A. Оставить старый endpoint | Нет изменений в коде | Не работает на 8.x |
| **B. Перейти на /v2/crontab ✅** | Работает на 8.x, verified | Нужно инжектировать action в POST body |
| C. Добавить версионный флаг --api-version | Гибко | Лишняя сложность для пользователя |

**Decision:** Категория `crontab` в `build_url()` теперь возвращает `${base_url}/v2/crontab`, а `is_v2_category()` обеспечивает инжект `action` в POST body. Пользователь не меняет вызовы.

**Consequences:** Crontab работает на AAPanel 8.x. Если AAPanel откатит v2 или сделает его опциональным — потребуется версионирование. Добавлены обязательные поля: `sType`, `sName`, `save`, `backupTo`, `urladdress`, `save_local`, `notice`, `notice_channel`. Тип интервала изменился: `minute` → `minute-n`.

**Revisit if:** AAPanel выпустит стабильную 8.x с другим API, или если v2 endpoint перестанет работать на старых версиях панели.
