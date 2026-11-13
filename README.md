# RL — русский язык

RL — веб-сервис для тренировки орфографии и пунктуации и подготовки к ЕГЭ. Первая очередь включает дерево правил и онлайн-диктанты; сейчас реализован **технический каркас W0-01**, а не учебные функции.

## Что уже работает

- Next.js App Router на Node.js 24, TypeScript 5.9 в strict-режиме, Tailwind CSS 4.
- Русская адаптивная стартовая страница с блоками «Диктанты» и «Дерево правил» (оба — «В разработке»).
- Liveness endpoint `GET /api/health` с ответом `{"status":"ok","service":"rl"}` и `Cache-Control: no-store`.
- Unit-тест Vitest и E2E smoke Playwright на реальном Chromium.
- GitHub CI (W0-11): lint, typecheck, format, unit, build, E2E и проверка PostgreSQL 16.

## Что ещё не работает

Нет базы данных, Prisma-схемы и миграций (W0-02/W0-03), авторизации и OAuth (W0-04+), диктантов, дерева правил, почты, фоновых задач и production-развёртывания. DEMO/PROD не созданы; `DEC-11` остаётся `BLOCKED`.

## Требования

- Node.js 24 LTS (`.nvmrc` содержит `24`), npm 11.6.0
- Git
- Docker пока **не нужен** для W0-01
- Для E2E: Chromium, устанавливаемый Playwright

## Запуск (Bash)

```bash
git clone https://github.com/a40-sorokin/Russian_Lang.git
cd Russian_Lang
npm ci
npm run dev
```

Откройте <http://localhost:3000> и <http://localhost:3000/api/health>.

### Windows PowerShell

```powershell
git clone https://github.com/a40-sorokin/Russian_Lang.git
Set-Location Russian_Lang
npm ci
npm run dev
```

Если репозиторий уже открыт локально, `git clone` не нужен: перейдите в каталог проекта.

## Проверки

```bash
npm run lint
npm run typecheck
npm run format:check
npm run test:unit
npm run build
npx playwright install chromium   # один раз; на Linux может потребоваться --with-deps
npm run test:e2e                  # локально Playwright сам поднимает dev server
npm run check                     # lint + typecheck + format + unit + build, без E2E
```

`npm run dev` — разработка; `npm run build` — production-сборка; `npm run start` — запуск собранной версии (сначала выполните `build`). В CI E2E запускается против `next start`, а не `next dev`.

## Структура

```text
src/app/                 App Router: layout, главная, 404, API
src/app/api/health/      liveness endpoint
src/lib/app-info.ts      небольшие чистые константы/функции
tests/unit/              Vitest
tests/e2e/               Playwright smoke
docs/requirements/       нормативный пакет RL v9.8 и манифест (побайтовые копии)
docs/architecture/       архитектура v1.3 и регламент Git/CI/CD v1.1
docs/decisions/          ADR-004 и реестр DEC → ADR
docs/release/            ТЗ W0-01/W0-11, README релиза, карта изменений
docs/handover/           фактические отчёты W0-01/W0-11
.github/workflows/ci.yml обязательный CI W0-11
```

Новый код размещайте в `src/` по модулям; тесты — в `tests/unit` или `tests/e2e`. Не добавляйте Prisma/Better Auth/pg-boss до соответствующих задач W0. Не коммитьте `.env`, секреты, дампы и ПД.

## Нормативные документы

- [AGENTS.md](AGENTS.md) — правила работы AI-агентов.
- [Полный пакет v9.8-DEC05-r6](docs/requirements/MANIFEST_v9.8-DEC05-r6.json) — манифест с SHA-256.
- [Архитектура v1.3](<docs/architecture/RL-Архитектурные решения и технический фундамент v1.3.md>).
- [Регламент Git/CI/CD v1.1](docs/architecture/RL_Git_CI-CD_и_окружения_v1.1.md).
- [Отчёт W0-01](docs/handover/W0-01-report.md), [отчёт W0-11](docs/handover/W0-11-report.md).

Проверка целостности документов:

```bash
cd docs/requirements
sha256sum -c <(python3 -c "import json;print(''.join(f\"{f['sha256']}  {f['filename']}\\n\" for f in json.load(open('MANIFEST_v9.8-DEC05-r6.json'))['files']))")
```

## Типовые проблемы

- `node --version` не 24 — переключите версию (nvm/fnm) или установите Node 24.
- `npm ci` падает — проверьте, что используется `package-lock.json`, и не смешивайте менеджеры пакетов.
- Порт 3000 занят — остановите другой процесс; документированный URL остаётся `http://localhost:3000`.
- E2E не находит браузер — выполните `npx playwright install chromium` (на Linux: `npx playwright install --with-deps chromium`).

## GitHub, CI и окружения

`main` — релизная линия, `develop` — интеграция. Изменения — через `feature/*`/`fix/*` и PR с зелёным CI. W0-11 настраивает GitHub/CI; release/deploy workflows, DEMO и PROD — отдельные этапы после approvals и закрытия блокирующих DEC. CI использует только синтетические данные и не получает production secrets.

## Следующие задачи

W0-02 — локальный Docker Compose и PostgreSQL 16. W0-03 — Prisma 7.8, схемы `auth`/`public`, SQL-миграции. W0-04 — Better Auth.
