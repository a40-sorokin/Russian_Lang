# W0-01 — отчёт исполнения

**Статус:** W0-01_READY (каркас), не `WAVE0_ACCEPTED`
**Дата / ОС:** 13.11.2026 / Ubuntu 26.04.1 LTS
**Ветка / SHA:** `feature/w0-01-bootstrap`; W0-01: `94e91c9196515e92afff499ae1e3f0704b33b8b5`, lockfile-fix: `5200691a4d6ef63536f857cc45b777b2b1eeb2e6`
**Git remote:** `https://github.com/a40-sorokin/Russian_Lang.git` (private); remote существовал до задачи
**Node / npm:** 24.9.0 / 11.6.0
**Next / React / TypeScript / Tailwind / Vitest / Playwright:** 16.4.6 / 19.3.1 / 5.9.3 / 4.3.3 / 5.0.5 / 1.64.1

## Реализовано

- Один npm-проект Next.js App Router (`src/`), TypeScript strict, Tailwind CSS v4, системные шрифты.
- Русская адаптивная главная: один H1, блоки «Диктанты» и «Дерево правил» с пометкой «В разработке», без фиктивных действий.
- `GET /api/health` → `200 {"status":"ok","service":"rl"}`, `Cache-Control: no-store`, без БД и внешних вызовов.
- Unit-тест Vitest, E2E smoke Playwright (заголовок, H1, блоки, health, отсутствие overflow при 320 px).
- Скрипты `dev`, `build`, `start`, `lint`, `typecheck`, `format`, `format:check`, `test:unit`, `test:e2e`, `check`.
- Нормативный пакет r6, `AGENTS.md`, архитектура v1.3, регламент Git/CI/CD, ADR-004 и реестр DEC → ADR.
- Корневой `.gitignore`, `.env.example`, `.npmrc`, `.nvmrc`, `.editorconfig`, `.gitattributes`, Prettier/ESLint.
- Инфраструктура W0-11 (CI и PR template) добавлена в этой же ветке; её фактическая проверка на GitHub ограничена правами токена (см. `W0-11-report.md`).

## Изменённые и созданные файлы

Основные: `package.json`, `package-lock.json`, `tsconfig.json`, `next.config.ts`, `eslint.config.mjs`, `vitest.config.ts`, `playwright.config.ts`, `src/app/{layout,page,not-found,globals.css}`, `src/app/api/health/route.ts`, `src/lib/app-info.ts`, `tests/unit/app-info.test.ts`, `tests/e2e/home.spec.ts`, `.github/workflows/ci.yml`, `.github/pull_request_template.md`, `docs/**`, `README.md`.

## Нормативный пакет

Источник: `RL_Docs_v9.8-r6.zip`, SHA-256 ZIP `9d291ab7…` (файл вложения). Проверены все **17** файлов `files[]` манифеста `MANIFEST_v9.8-DEC05-r6.json`: размеры и SHA-256 совпали до копирования. Скопированы побайтово:

- `docs/requirements/`: 9 RL-документов + `RL_FK_audit_PostgreSQL_v9.8.sql` + сам манифест.
- `docs/architecture/`: архитектура v1.3, регламент Git/CI/CD v1.1.
- `docs/release/`: README релиза, W0-01 v1.2, W0-11 v1.1, карта изменений r6.
- `docs/decisions/`: `ADR-004-email-provider.md` и реестр DEC → ADR.
- Корневой `AGENTS.md`.

Содержимое документов не редактировалось; Prettier их игнорирует.

## Результаты проверок

| Команда                         | Статус | Фактический вывод                                                               |
| ------------------------------- | ------ | ------------------------------------------------------------------------------- |
| `npm ci` (чистая копия коммита) | PASS   | установка из `package-lock.json` успешна после фикса optional rolldown bindings |
| `npm run lint`                  | PASS   | ESLint без ошибок                                                               |
| `npm run typecheck`             | PASS   | `tsc --noEmit` без ошибок                                                       |
| `npm run format:check`          | PASS   | All matched files use Prettier code style                                       |
| `npm run test:unit`             | PASS   | 1 файл / 1 тест                                                                 |
| `npm run build`                 | PASS   | Next 16.4.6, маршруты `/`, `/_not-found`, `/api/health`                         |
| `npm run start` + HTTP smoke    | PASS   | E2E обращается к `next start`; `/api/health` 200, `no-store`                    |
| `npm run test:e2e`              | PASS   | Chromium 1.64.1, 3 теста                                                        |
| `npm audit --omit=dev`          | PASS   | 0 vulnerabilities                                                               |
| `npm audit` (полный)            | INFO   | 7 moderate, только dev-зависимости; `--force` не применялся                     |

## Критерии DOD-01…DOD-17

| ID     | Статус | Свидетельство                                                               |
| ------ | ------ | --------------------------------------------------------------------------- |
| DOD-01 | PASS   | существующий `.git` и история `main` сохранены; remote существовал          |
| DOD-02 | PASS   | один `package.json`/`package-lock.json`; `npm ci` в чистой копии            |
| DOD-03 | PASS   | Node 24.9.0, TS 5.9.3 strict, Next 16.4.6, React 19.3.1                     |
| DOD-04 | PASS   | главная без БД/логина/секретов; E2E                                         |
| DOD-05 | PASS   | E2E 320 px, `scrollWidth <= clientWidth`; мнимых действий нет               |
| DOD-06 | PASS   | E2E: 200, JSON, `Cache-Control: no-store`                                   |
| DOD-07 | PASS   | lint/typecheck/format:check                                                 |
| DOD-08 | PASS   | Vitest 5.0.5, 1 осмысленный тест                                            |
| DOD-09 | PASS   | Playwright 1.64.1 Chromium, 3 теста                                         |
| DOD-10 | PASS   | build + `next start` в E2E                                                  |
| DOD-11 | PASS   | `npm ci`, lint, typecheck, unit, build в чистой копии                       |
| DOD-12 | PASS   | 17/17 файлов манифеста, размеры и SHA-256 совпали                           |
| DOD-13 | PASS   | README: Bash/PowerShell, URL, проверки, структура, ошибки                   |
| DOD-14 | PASS   | `.env`/`node_modules`/`.next`/отчёты исключены; `.env.example` без секретов |
| DOD-15 | PASS   | нет prisma/better-auth/pg-boss/Redis/PWA                                    |
| DOD-16 | PASS   | этот отчёт                                                                  |
| DOD-17 | PASS   | коммиты `94e91c9`, `5200691`                                                |

## Предусмотренные, но не выполненные части

- PostgreSQL/Docker Compose — W0-02.
- Prisma 7.8, схемы `auth`/`public`, SQL-миграции — W0-03.
- Better Auth, OAuth, email, rate limiting, worker, Caddy/GlitchTip — W0-04…W0-10.
- Реальный GitHub PR/CI-run и branch protection — W0-11, ограничено правами токена (см. отчёт W0-11).

## Риски, разногласия, новые зависимости

- `npm audit` показывает 7 moderate в dev-зависимостях; исправление с `--force` запрещено, требуется отдельная оценка.
- W0-11 не может быть принят без PR/CI и защиты веток; это внешний блокер прав, а не дефект кода.
- `DEC-06=BLOCKED`, `DEC-11=BLOCKED`, `MAIL_DELIVERY_VERIFICATION=VERIFY` — без изменений.
- Новых продуктовых зависимостей нет; добавлены только разрешённые W0-01 инструменты.

## Передача W0-02

Каркас работает и воспроизводится. W0-02 может добавлять `infra/compose.yaml`, PostgreSQL 16 и локальные переменные, не меняя контракт `/api/health`. Не добавлять Prisma/Better Auth до W0-03/W0-04.
