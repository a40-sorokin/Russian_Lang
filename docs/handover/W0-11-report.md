# W0-11 — отчёт фактической настройки GitHub/CI

**Статус:** `W0-11_PARTIAL` (не `W0-11_READY`)
**Дата / исполнитель:** 13.11.2026 / AI-агент
**Repository URL / visibility / plan:** `https://github.com/a40-sorokin/Russian_Lang` / private / GitHub Free (по ответу API о rulesets)
**Initial main SHA:** `a64f148` (`Update README.md`)
**Develop создан от:** `a64f148`
**Ветка W0-01/W0-11:** `feature/w0-01-bootstrap`
**W0-01 commit:** `94e91c9196515e92afff499ae1e3f0704b33b8b5`
**Lockfile fix:** `5200691a4d6ef63536f857cc45b777b2b1eeb2e6`
**Финальный SHA develop / merge:** указывается ниже после фактического merge (раздел «Фактическое состояние»)

## Фактическое состояние

- `develop` создана от актуального `main` (`a64f148`), история `main` не переписана.
- В ветке `feature/w0-01-bootstrap` находятся каркас W0-01, `.github/workflows/ci.yml`, `.github/pull_request_template.md`, нормативные документы и отчёты.
- PR создать **не удалось**: fine-grained token не имеет `pull_requests=write` (GitHub API: 403, `x-accepted-github-permissions: pull_requests=write`).
- Настроить branch protection/rulesets **не удалось**: token не имеет `administration=read`; API rulesets для private на Free отвечает «Upgrade to GitHub Pro».
- Прочитать Actions runs/check-runs **не удалось**: token не имеет Actions/Checks permissions (403).
- `git push` веток работает; workflow-файл принят remote без ошибки `workflow` scope.

## W11-01 … W11-10

| ID     | Статус                             | Факт / ограничение                                                                                                                                                                                |
| ------ | ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| W11-01 | PASS                               | `develop` создана от `main` `a64f148`; `main` не изменён, force-push не выполнялся                                                                                                                |
| W11-02 | **BLOCKED**                        | защита `main`/`develop` не настраивается доступным токеном; private Free не поддерживает rulesets. Требуется владелец с `administration:write` (или upgrade плана)                                |
| W11-03 | PASS (файл)                        | `.github/pull_request_template.md` содержит UC/Fxx/ER, миграции, проверки, риски, непройденное, security-чеклист                                                                                  |
| W11-04 | PASS (файл) / **BLOCKED** (run)    | `ci.yml`: `pull_request` → `develop,main`, `push` → `develop`, `workflow_dispatch`; `permissions: contents: read`; `concurrency`; workflow принят push'ем, факт запуска не подтверждён из-за прав |
| W11-05 | PASS (локально)                    | шаги `npm ci`, `lint`, `typecheck`, `format:check`, `test:unit`, `build` выделены отдельно; локально все PASS                                                                                     |
| W11-06 | **PARTIAL**                        | job `postgres-integration` реально поднимает `postgres:16`, создаёт чистую БД и проверяет версию. Миграций/интеграционных тестов нет: W0-03 не реализован → `NOT_APPLICABLE_YET`, не PASS         |
| W11-07 | PASS (локально) / **BLOCKED** (CI) | Playwright 1.64.1 Chromium против `next start`; 3 теста PASS, включая `/api/health`. CI-run не подтверждён                                                                                        |
| W11-08 | **BLOCKED**                        | нельзя создать PR и прочитать runs; fail/pass прогоны GitHub CI не сохранены. Локальные fail/pass не выдаются за CI                                                                               |
| W11-09 | PASS (конфигурация)                | `contents: read`, нет `pull_request_target`, actions закреплены полными SHA, нет deployment secrets, `persist-credentials: false`                                                                 |
| W11-10 | PASS                               | этот отчёт + `W0-01-report.md`                                                                                                                                                                    |

## Проверки, выполненные локально

| Проверка                   | Результат                                         |
| -------------------------- | ------------------------------------------------- |
| `npm ci` (чистая копия)    | PASS                                              |
| `npm run lint`             | PASS                                              |
| `npm run typecheck`        | PASS                                              |
| `npm run format:check`     | PASS                                              |
| `npm run test:unit`        | PASS (1/1)                                        |
| `npm run build`            | PASS                                              |
| `npm run test:e2e`         | PASS (3/3, Chromium, `next start`)                |
| `npm audit --omit=dev`     | PASS (0 vulnerabilities)                          |
| PostgreSQL 16 / migrations | NOT_RUN: W0-03 отсутствует; job в CI предусмотрен |

Точные версии: Node 24.9.0, npm 11.6.0, Next 16.4.6, TypeScript 5.9.3, Vitest 5.0.5, Playwright 1.64.1.

## Блокеры

1. **Права GitHub token (внешний блокер).** Для завершения нужны: `pull_requests: write`, `checks: read`/`actions: read`, `administration: write` (ветки/rulesets). Без них нельзя открыть PR, увидеть CI и включить защиту. Это не исправляется изменением кода.
2. **Тариф GitHub Free + private.** Rulesets недоступны; branch protection через API требует administration-права. Владельцу нужно настроить вручную либо изменить план/видимость.
3. **W0-02…W0-10 не выполнены.** Нет PostgreSQL/Prisma-миграций, auth, worker и т.д.; поэтому integration/E2E-проверки продукта ограничены каркасом. W0-11 не может быть `READY` без фактического PR/CI и защиты.
4. **Второй ревьюер отсутствует.** Фиктивное AI-одобрение не создавалось; требуется ручное решение владельца.

## Что должен сделать владелец

1. Выдать токену/приложению права `Pull requests: write`, `Actions: read`, `Administration: write` (или настроить через веб-интерфейс).
2. Создать PR `feature/w0-01-bootstrap` → `develop` (ссылка сравнения: `https://github.com/a40-sorokin/Russian_Lang/compare/develop...feature/w0-01-bootstrap`), дождаться первого зелёного `CI`.
3. Включить защиту `main` и `develop`: обязательный check `quality`/`e2e` (только после первого успешного run), запрет force push и удаления, review владельца.
4. После этого повторить негативный тест: PR с намеренно падающим тестом → красный; исправление → зелёный. Сохранить ссылки на runs.
5. Для полной приёмки W0-11 выполнить W0-02…W0-10 и включить реальные migration/integration tests (job уже предусмотрен).

## Результат

`W0-11_PARTIAL`. Настройка файлов CI/PR и ветки `develop` выполнена; фактические GitHub PR, CI-runs, fail/pass-доказательства и защита веток **не подтверждены** из-за отсутствующих прав токена/тарифа. `WAVE0_ACCEPTED` и PROD не объявляются.
