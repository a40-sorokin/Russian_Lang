# W0-11 — отчёт фактической настройки GitHub/CI

**Статус:** `W0-11_PARTIAL` (не `W0-11_READY`)
**Дата / исполнитель:** 13.11.2026 / AI-агент
**Repository URL / visibility / plan:** `https://github.com/a40-sorokin/Russian_Lang` / **public** / GitHub Free
**Initial main SHA:** `a64f1480a4608abb393118ee87768a71a814a8af`
**Develop создан от:** `a64f148`
**Bootstrap merge в develop:** `ac98bb15eadc8d2c58dedbfe442fcc8d9ed0d95d`
**Feature tip W0-01/W0-11:** `a0476783cd5ccb9caaf9d9d814f5d00b05e1ed37`
**Develop до финализационного PR:** `f3891e069d3a57bffbb0676352ece9335499d9df`
**Финальный PR:** [#2](https://github.com/a40-sorokin/Russian_Lang/pull/2) (`feature/w0-11-finalize` → `develop`)

## Фактическое состояние

- `main` не переписан и не изменялся: `a64f148`. `develop` создана от него.
- Каркас W0-01 и инфраструктура W0-11 опубликованы в `develop` (bootstrap merge `ac98bb1`).
- Репозиторий переведён владельцем в **public**, после чего GitHub разрешил branch protection на Free.
- GitHub Actions работает; запуски `quality`, `e2e`, `postgres-integration` завершаются.
- **Защита `main` и `develop` включена** (фактический экспорт API):
  - обязательный PR перед merge (`required_pull_request_reviews.required_approving_review_count = 0` — независимого второго ревьюера нет, review выполняет владелец вручную);
  - обязательные checks: `quality`, `e2e`, `postgres-integration`; `strict = true` (ветка должна быть актуальна);
  - `enforce_admins = true` (правила действуют и для администратора);
  - force push и удаление веток запрещены;
  - обязательно разрешение обсуждений (conversation resolution).
- Экспорт: `https://api.github.com/repos/a40-sorokin/Russian_Lang/branches/develop/protection` и `.../branches/main/protection`.
- Независимый второй ревьюер отсутствует; фиктивное «AI approval» не создавалось.

## Фактические CI-прогоны

| Назначение                                 | SHA       | Run                                                                                 | Результат                                            |
| ------------------------------------------ | --------- | ----------------------------------------------------------------------------------- | ---------------------------------------------------- |
| Push в `develop`                           | `f3891e0` | [43479293491](https://github.com/a40-sorokin/Russian_Lang/actions/runs/43479293491) | **success**: quality, e2e, postgres-integration      |
| Негативный PR #1 (намеренно падающий тест) | `fe54c52` | [43490732014](https://github.com/a40-sorokin/Russian_Lang/actions/runs/43490732014) | **failure**: `quality` красный; e2e/postgres зелёные |
| Тот же PR после удаления падающего теста   | `4ca8a05` | [43490957457](https://github.com/a40-sorokin/Russian_Lang/actions/runs/43490957457) | **success**: все три job                             |
| Финальный PR #2, первый head               | `1031150` | [43491302651](https://github.com/a40-sorokin/Russian_Lang/actions/runs/43491302651) | **success**: все три job                             |
| Финальный PR #2, head с ссылками           | `5ea4ebb` | [43491554379](https://github.com/a40-sorokin/Russian_Lang/actions/runs/43491554379) | **success**: все три job                             |

PR #1: <https://github.com/a40-sorokin/Russian_Lang/pull/1> — закрыт без merge, ветка `test/ci-negative` сохранена как свидетельство fail/pass.

## W11-01 … W11-10

| ID     | Статус      | Факт / ограничение                                                                                                                                                             |
| ------ | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| W11-01 | PASS        | `develop` создана от `main` `a64f148`; история не переписана, force-push не применялся                                                                                         |
| W11-02 | PASS        | защита `main`/`develop` включена: обязательный PR, 3 обязательных check, `strict`, запрет force push/удаления, `enforce_admins`; review — ручной (0 approvals, соло-владелец)  |
| W11-03 | PASS        | `.github/pull_request_template.md`: UC/Fxx/ER, миграции, проверки, риски, непройденное, security-чеклист                                                                       |
| W11-04 | PASS        | `ci.yml`: PR → `develop,main`, push → `develop`, минимальные `permissions: contents: read`, `concurrency`; реальные PR-запуски получены                                        |
| W11-05 | PASS        | отдельные шаги `npm ci`, lint, typecheck, format:check, unit, build; все зелёные в CI                                                                                          |
| W11-06 | **PARTIAL** | job реально поднимает `postgres:16`, создаёт чистую БД и проверяет `select version()`. Миграций/интеграционных тестов нет: W0-03 не реализован → `NOT_APPLICABLE_YET`, не PASS |
| W11-07 | PASS        | Playwright 1.64.1 Chromium против `next start` в CI; 3 теста, включая `/api/health`                                                                                            |
| W11-08 | PASS        | сохранены fail-run `43490732014` и pass-run `43490957457` на ветке `test/ci-negative`                                                                                          |
| W11-09 | PASS        | `contents: read`, нет `pull_request_target`, actions закреплены полными SHA, нет deployment secrets, `persist-credentials: false`                                              |
| W11-10 | PASS        | этот отчёт + `W0-01-report.md`                                                                                                                                                 |

## Проверки, выполненные локально

| Проверка                | Результат                                                            |
| ----------------------- | -------------------------------------------------------------------- |
| `npm ci` (чистая копия) | PASS                                                                 |
| `npm run lint`          | PASS                                                                 |
| `npm run typecheck`     | PASS                                                                 |
| `npm run format:check`  | PASS                                                                 |
| `npm run test:unit`     | PASS (1/1)                                                           |
| `npm run build`         | PASS                                                                 |
| `npm run test:e2e`      | PASS (3/3, Chromium, `next start`)                                   |
| `npm audit --omit=dev`  | PASS (0 vulnerabilities)                                             |
| PostgreSQL migrations   | NOT_APPLICABLE_YET: W0-03 отсутствует; provisioning проверяется в CI |

Версии: Node 24.9.0, npm 11.6.0, Next 16.4.6, TypeScript 5.9.3, Vitest 5.0.5, Playwright 1.64.1.

## Блокеры

1. **W0-02…W0-10 не выполнены.** Нет Prisma-миграций, auth, worker и продуктовых тестов; integration job фиксирует `NOT_APPLICABLE_YET`. W0-11 остаётся `PARTIAL` до появления предмета интеграционных проверок.
2. **Второй ревьюер отсутствует.** Нативная защита требует 0 approvals, иначе соло-владелец не сможет merge-ить; review остаётся ручным. Фиктивное AI-одобрение не создавалось.
3. **Owner acceptance не предоставлен.** `WAVE0_ACCEPTED`, DEMO и PROD не объявляются.

## Что осталось владельцу

1. Проверить и merge PR #2 (после этого `develop` получит финальный отчёт).
2. Выполнить W0-02…W0-10; после W0-03 integration job начнёт применять реальные миграции и тесты.
3. При появлении второго ревьюера поднять `required_approving_review_count` до 1.

## Результат

`W0-11_PARTIAL`: PR/CI/fail-pass/шаблон/минимальные permissions и **защита обеих веток** подтверждены фактически; остаются W0-02…W0-10 (integration) и явная приёмка владельца. `WAVE0_ACCEPTED`, DEMO и PROD не объявляются.
