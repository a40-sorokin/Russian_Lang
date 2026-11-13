# Реестр решений DEC → ADR

Источник: «RL — Архитектурные решения и технический фундамент» v1.3, §12.1. Таблица ниже фиксирует **фактические статусы**, а не новые утверждения. `VERIFY` не становится `PASS` от наличия документа или workflow; `BLOCKED` закрывает заказчик, а не AI-агент.

| ID     | Связанный ADR | Статус                          | Предмет                                                                                             | Блокирует                       |
| ------ | ------------- | ------------------------------- | --------------------------------------------------------------------------------------------------- | ------------------------------- |
| DEC-01 | ADR-001       | `PROPOSED`                      | Web + отдельный worker в одном модульном монолите                                                   | Кодовую структуру и деплой      |
| DEC-02 | ADR-002       | `VERIFY`                        | pg-boss в `public`, без третьей схемы                                                               | Фоновые задачи                  |
| DEC-03 | ADR-003       | `VERIFY`                        | Better Auth 1.7.x + Prisma 7.8, multi-schema                                                        | Все F01                         |
| DEC-04 | ADR-003       | `VERIFY`                        | VK ID / Яндекс ID и OAuth onboarding                                                                | OAuth-вход                      |
| DEC-05 | ADR-004       | **`FIXED`** (доставка `VERIFY`) | Исходящая почта: Postfix Docker на VPS РФ, Mailpit локально; без Dovecot/IMAP/POP3 и входящей почты | Доставку подтверждений до W0-08 |
| DEC-06 | ADR-005       | **`BLOCKED`**                   | Пороговые значения rate limiting                                                                    | P0 защищённые auth endpoint     |
| DEC-07 | ADR-003       | `VERIFY`                        | Сохранение/компенсация identity без RL-профиля                                                      | Активную регистрацию            |
| DEC-08 | ADR-003       | `VERIFY`                        | Реальная очистка Better Auth, retries                                                               | Проектирование UC-36/37         |
| DEC-09 | ADR-001       | `PROPOSED`                      | Route Handlers `/api/v1`, общие доменные сервисы                                                    | Контракты API                   |
| DEC-10 | ADR-006       | `PROPOSED`                      | Один VPS/Compose + Caddy, отдельный worker                                                          | Production deployment           |
| DEC-11 | ADR-006       | **`BLOCKED`** для production    | Backup/deletion retention и юридический риск founder                                                | Production с реальными данными  |
| DEC-12 | ADR-006       | `VERIFY`                        | Размещение GlitchTip без Redis и РФ-хранилище                                                       | Мониторинг production           |

Примечания:

- `MAIL_DELIVERY_VERIFICATION=VERIFY`: реальная доставка писем через Postfix на VPS РФ не проверялась; W0-08 обязателен.
- В репозитории присутствует только фактически существующий `ADR-004-email-provider.md`. Остальные ADR на 13.11.2026 не созданы; эта таблица не заменяет их.
- Настройка GitHub/CI (W0-11) не закрывает ни один DEC.
