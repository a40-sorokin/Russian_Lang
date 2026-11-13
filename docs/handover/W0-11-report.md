# W0-11 — отчёт фактической настройки GitHub/CI

**Статус:** `W0-11_PARTIAL` (не `W0-11_READY`)
**Дата / исполнитель:** 13.11.2026 / AI-агент
**Repository URL / visibility / plan:** `https://github.com/a40-sorokin/Russian_Lang` / private / GitHub Free
**Initial main SHA:** `a64f1480a4608abb393118ee87768a71a814a8af`
**Develop создан от:** `a64f148`
**Bootstrap merge в develop:** `ac98bb15eadc8d2c58dedbfe442fcc8d9ed0d95d`
**Feature tip W0-01/W0-11:** `a0476783cd5ccb9caaf9d9d814f5d00b05e1ed37`
**Текущий develop (до финализационного PR):** `f3891e069d3a57bffbb0676352ece9335499d9df`
**Финальный PR:** [#2](https://github.com/a40-sorokin/Russian_Lang/pull/2) (`feature/w0-11-finalize` → `develop`)

## Фактическое состояние

- `main` не переписан и не изменялся: `a64f148`. `develop` создана от него.
- Каркас W0-01 и инфраструктура W0-11 опубликованы в `develop` (bootstrap merge `ac98bb1`).
- Ветка `feature/w0-11-finalize` содержит этот отчёт с фактическими CI-ссылками.
- GitHub Actions работает; запуски `quality`, `e2e`, `postgres-integration` завершаются.
- Защита веток **не настроена**: GitHub Free + private. API отвечает `Upgrade to GitHub Pro or make this repository public to enable this feature` для и branch protection, и для rulesets. Это ограничение тарифа, а не прав токена.
- Независимый второй ревьюер отсутствует; фиктивное «AI approval» не создавалось.

## Фактические CI-прогоны

| Назначение                                        | SHA           | Run                                                                                 | Результат                                            |
| ------------------------------------------------- | ------------- | ----------------------------------------------------------------------------------- | ---------------------------------------------------- |
| Push в `develop`                                  | `f3891e0`     | [43479293491](https://github.com/a40-sorokin/Russian_Lang/actions/runs/43479293491) | **success**: quality, e2e, postgres-integration      |
| Негативный PR #1 (намеренно падающий тест)        | `fe54c52`     | [43490732014](https://github.com/a40-sorokin/Russian_Lang/actions/runs/43490732014) | **failure**: `quality` красный; e2e/postgres зелёные |
| Тот же PR после удаления падающего теста          | `4ca8a05`     | [43490957457](https://github.com/a40-sorokin/Russian_Lang/actions/runs/43490957457) | **success**: все три job                             |
| Финальный PR `feature/w0-11-finalize` → `develop` | см. checks PR | будет добавлено после создания PR                                                   | ожидается success                                    |

PR #1: <https://github.com/a40-sorokin/Russian_Lang/pull/1> — закрыт без merge, ветка `test/ci-negative` сохранена как свидетельство fail/pass.

## W11-01 … W11-10

| ID     | Статус              | Факт / ограничение                                                                                                                                                             |
| ------ | ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| W11-01 | PASS                | `develop` создана от `main` `a64f148`; история не переписана, force-push не применялся                                                                                         |
| W11-02 | **BLOCKED (тариф)** | защита `main`/`develop` недоступна на GitHub Free для private: API требует GitHub Pro; rulesets и classic protection возвращают Upgrade                                        |
| W11-03 | PASS                | `.github/pull_request_template.md`: UC/Fxx/ER, миграции, проверки, риски, непройденное, security-чеклист                                                                       |
| W11-04 | PASS                | `ci.yml`: PR → `develop,main`, push → `develop`, минимальные `permissions: contents: read`, `concurrency`; реальный PR-запуск получен                                          |
| W11-05 | PASS                | отдельные шаги `npm ci`, lint, typecheck, format:check, unit, build; все зелёные в CI                                                                                          |
| W11-06 | **PARTIAL**         | job реально поднимает `postgres:16`, создаёт чистую БД и проверяет `select version()`. Миграций/интеграционных тестов нет: W0-03 не реализован → `NOT_APPLICABLE_YET`, не PASS |
| W11-07 | PASS                | Playwright 1.64.1 Chromium против `next start` в CI; 3 теста, включая `/api/health`                                                                                            |
| W11-08 | PASS                | сохранены fail-run `43490732014` и pass-run `43490957457` на ветке `test/ci-negative`                                                                                          |
| W11-09 | PASS                | `contents: read`, нет `pull_request_target`, actions закреплены полными SHA, нет deployment secrets, `persist-credentials: false`                                              |
| W11-10 | PASS                | этот отчёт + `W0-01-report.md`                                                                                                                                                 |

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

1. **Тариф GitHub Free + private.** Branch protection/rulesets недоступны. Нужен GitHub Pro/Team либо ручной контроль владельца без нативного enforcement. Это нельзя обойти YAML-файлом; фиктивная защита не создавалась.
2. **W0-02…W0-10 не выполнены.** Нет Prisma-миграций, auth, worker и продуктовых тестов; integration job фиксирует `NOT_APPLICABLE_YET`. W0-11 не может быть `READY` без них и без защиты веток.
3. **Второй ревьюер отсутствует.** Требуется ручное решение владельца; AI не одобряет собственный PR.
4. **Owner acceptance не предоставлен.** `WAVE0_ACCEPTED` и PROD не объявляются.

## Что осталось владельцу

1. Подключить GitHub Pro/Team для private-репозитория (или письменно принять ручной контроль без нативной защиты).
2. В настройках веток `main` и `develop`: запретить force push и удаление, включить обязательный review владельца.
3. После первого стабильного запуска добавить обязательные checks `quality` и `e2e` (не добавлять несуществующее имя check).
4. Проверить и merge финальный PR; затем закрыть W0-02…W0-10 и включить реальные migration/integration tests.

## Результат

`W0-11_PARTIAL`: PR/CI/fail-pass/шаблон/минимальные permissions подтверждены фактически; защита веток заблокирована тарифом GitHub Free, интеграционные проверки БД ожидают W0-03. `WAVE0_ACCEPTED`, DEMO и PROD не объявляются.
