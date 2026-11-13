-- RL v9.8 / ПРОВЕРКА миграций PostgreSQL 16.
-- Read-only; запускать ПОСЛЕ применения Prisma/Better Auth миграций.
-- Схемы предполагаются public и auth; изменить, если реальная миграция их называет иначе.
-- Этот SQL НЕ выполняет DELETE и НЕ доказывает прохождение интеграционных тестов PG-01..44.

-- 1) Все фактически созданные FK и их способы удаления.
SELECT c.conrelid::regclass AS child_table,
       pg_get_constraintdef(c.oid, true) AS fk_definition,
       c.confrelid::regclass AS parent_table,
       c.conname AS fk_name,
       c.convalidated,
       c.condeferrable,
       CASE c.confdeltype WHEN 'a' THEN 'NO ACTION' WHEN 'r' THEN 'RESTRICT'
            WHEN 'c' THEN 'CASCADE' WHEN 'n' THEN 'SET NULL'
            WHEN 'd' THEN 'SET DEFAULT' END AS on_delete
FROM pg_constraint c
JOIN pg_namespace n ON n.oid = c.connamespace
WHERE c.contype = 'f' AND n.nspname IN ('public','auth')
ORDER BY c.conrelid::regclass::text, c.conname;

-- 2) Сравнить ожидаемые FK утверждённой ER-модели текущего комплекта RL
--    с фактическими ограничениями PostgreSQL.
-- Сравнение рассчитано на простые (одностолбцовые) FK исходной ER-таблицы.
WITH expected(child_table, child_col, parent_schema, parent_table, delete_code) AS (
  VALUES
    ('user_profile','auth_user_id','auth','user','n'),
    ('user_profile','updated_by','public','user_profile','r'),
    ('user_profile','deleted_by','public','user_profile','r'),
    ('role','created_by','public','user_profile','r'),
    ('role','updated_by','public','user_profile','r'),
    ('role_user_profile','user_profile_id','public','user_profile','r'),
    ('role_user_profile','role_id','public','role','r'),
    ('role_user_profile','created_by','public','user_profile','r'),
    ('rule','parent_id','public','rule','r'),
    ('rule','created_by','public','user_profile','r'),
    ('rule','updated_by','public','user_profile','r'),
    ('rule','deleted_by','public','user_profile','r'),
    ('dictation_record','created_by','public','user_profile','r'),
    ('dictation_record','updated_by','public','user_profile','r'),
    ('dictation_record','deleted_by','public','user_profile','r'),
    ('dictation_version','dictation_record_id','public','dictation_record','r'),
    ('dictation_version','created_by','public','user_profile','r'),
    ('dictation_version','updated_by','public','user_profile','r'),
    ('dictation_version_rule','dictation_version_id','public','dictation_version','c'),
    ('dictation_version_rule','rule_id','public','rule','r'),
    ('dictation_version_rule','created_by','public','user_profile','r'),
    ('dictation_version_word_placeholder','dictation_version_id','public','dictation_version','c'),
    ('dictation_version_word_placeholder','word_placeholder_id','public','word_placeholder','r'),
    ('dictation_version_word_placeholder','created_by','public','user_profile','r'),
    ('dictation_done','user_id','public','user_profile','r'),
    ('dictation_done','dictation_version_id','public','dictation_version','r'),
    ('placeholder_done','dictation_done_id','public','dictation_done','r'),
    ('placeholder_done','rule_id','public','rule','r'),
    ('rule_progress','user_id','public','user_profile','r'),
    ('rule_progress','rule_id','public','rule','r'),
    ('rule_progress','calculated_by','public','user_profile','n'),
    ('word','created_by','public','user_profile','r'),
    ('word','updated_by','public','user_profile','r'),
    ('word','deleted_by','public','user_profile','r'),
    ('word_placeholder','word_id','public','word','r'),
    ('word_placeholder','rule_id','public','rule','r'),
    ('word_placeholder','created_by','public','user_profile','r'),
    ('word_placeholder','updated_by','public','user_profile','r'),
    ('word_placeholder','deleted_by','public','user_profile','r'),
    ('deck','owner_id','public','user_profile','r'),
    ('deck','created_by','public','user_profile','r'),
    ('deck','updated_by','public','user_profile','r'),
    ('deck','deleted_by','public','user_profile','r'),
    ('deck_word','deck_id','public','deck','c'),
    ('deck_word','word_id','public','word','r'),
    ('deck_word','created_by','public','user_profile','r'),
    ('word_done','user_id','public','user_profile','r'),
    ('word_done','word_placeholder_id','public','word_placeholder','r'),
    ('word_done','dictation_done_id','public','dictation_done','r'),
    ('word_done','training_session_id','public','deck_training_session','n'),
    ('deck_training_session','user_id','public','user_profile','c'),
    ('deck_training_session','deck_id','public','deck','r'),
    ('deck_training_session','current_word_id','public','word','r'),
    ('user_profile','locked_by','public','user_profile','r'),
    ('user_signin_log','user_id','public','user_profile','c'),
    ('secret_link','user_id','public','user_profile','r'),
    ('secret_link','created_by','public','user_profile','r'),
    ('secret_link','updated_by','public','user_profile','r'),
    ('secret_link','deleted_by','public','user_profile','r'),
    ('user_rule_preference','user_id','public','user_profile','c'),
    ('user_rule_preference','rule_id','public','rule','c'),
    ('user_rule_preference','created_by','public','user_profile','r'),
    ('user_rule_preference','updated_by','public','user_profile','r'),
    ('user_rule_preference','deleted_by','public','user_profile','r'),
    ('admin_audit_log','admin_id','public','user_profile','n'),
    ('admin_audit_log','user_id','public','user_profile','n'),
    ('admin_audit_log','rule_id','public','rule','r'),
    ('service_setting','updated_by','public','user_profile','r')
), actual AS (
  SELECT child.relname::text AS child_table,
         att.attname::text AS child_col,
         parent_ns.nspname::text AS parent_schema,
         parent.relname::text AS parent_table,
         c.confdeltype::text AS delete_code,
         c.conname::text AS fk_name,
         c.convalidated
  FROM pg_constraint c
  JOIN pg_class child ON child.oid=c.conrelid
  JOIN pg_namespace child_ns ON child_ns.oid=child.relnamespace
  JOIN pg_class parent ON parent.oid=c.confrelid
  JOIN pg_namespace parent_ns ON parent_ns.oid=parent.relnamespace
  JOIN pg_attribute att ON att.attrelid=c.conrelid AND att.attnum=c.conkey[1]
  WHERE c.contype='f' AND child_ns.nspname='public'
    AND cardinality(c.conkey)=1
)
SELECT CASE
   WHEN e.child_table IS NULL THEN 'UNEXPECTED_FK'
   WHEN a.child_table IS NULL THEN 'MISSING_FK'
   WHEN e.parent_schema IS DISTINCT FROM a.parent_schema OR
        e.parent_table IS DISTINCT FROM a.parent_table THEN 'WRONG_PARENT'
   WHEN e.delete_code IS DISTINCT FROM a.delete_code THEN 'WRONG_ON_DELETE'
   WHEN NOT a.convalidated THEN 'NOT_VALIDATED'
   ELSE 'OK' END AS result,
   COALESCE(e.child_table,a.child_table) AS child_table,
   COALESCE(e.child_col,a.child_col) AS column_name,
   (e.parent_schema||'.'||e.parent_table) AS expected_parent,
   (a.parent_schema||'.'||a.parent_table) AS actual_parent,
   e.delete_code AS expected_action_code,
   a.delete_code AS actual_action_code,
   a.fk_name
FROM expected e
FULL OUTER JOIN actual a
  ON e.child_table=a.child_table AND e.child_col=a.child_col
ORDER BY result, child_table, column_name;

-- 3) Nullable, необходимые для обезличивания и завершения задач.
WITH expected(t,c,nullable) AS (
 VALUES
 ('user_profile','nickname','YES'),
 ('user_profile','email','YES'),
 ('user_profile','auth_user_id','YES'),
 ('user_profile','last_signin_at','YES'),
 ('user_profile','last_learn_at','YES'),
 ('user_profile','locked_at','YES'),
 ('user_profile','locked_by','YES'),
 ('user_profile','restored_at','YES'),
 ('user_profile','lock_reason','YES'),
 ('user_profile','updated_by','YES'),
 ('user_profile','deleted_by','YES'),
 ('user_deletion_jobs','auth_user_id','YES'),
 ('role','created_by','YES'),
 ('rule','created_by','YES'),
 ('service_setting','updated_by','YES')
)
SELECT e.t AS table_name, e.c AS column_name,
       e.nullable AS expected_nullable, cols.is_nullable AS actual_nullable,
       CASE WHEN cols.column_name IS NULL THEN 'MISSING_COLUMN'
            WHEN cols.is_nullable<>e.nullable THEN 'WRONG_NULLABILITY'
            ELSE 'OK' END AS result
FROM expected e
LEFT JOIN information_schema.columns cols
 ON cols.table_schema='public' AND cols.table_name=e.t AND cols.column_name=e.c
ORDER BY e.t,e.c;

-- 4) Защита founder и иных правил: показать фактически установленные триггеры.
SELECT t.tgrelid::regclass AS table_name, t.tgname AS trigger_name,
       pg_get_triggerdef(t.oid) AS trigger_definition
FROM pg_trigger t
WHERE NOT t.tgisinternal
  AND t.tgrelid IN ('public.user_profile'::regclass,
                    'public.role_user_profile'::regclass)
ORDER BY t.tgrelid::regclass::text, t.tgname;

-- 5) Частичные индексы founder и других таблиц: проверить наличие вручную.
SELECT tablename, indexname, indexdef
FROM pg_indexes
WHERE schemaname='public'
  AND tablename IN ('user_profile','dictation_done','placeholder_done','word_done',
                    'secret_link','deck_training_session','user_deletion_jobs')
ORDER BY tablename,indexname;

-- 6) Все CHECK/UNIQUE, важные при обезличивании и удалении.
SELECT c.conrelid::regclass AS table_name, c.contype,
       c.conname, pg_get_constraintdef(c.oid,true) AS definition,
       c.convalidated
FROM pg_constraint c
WHERE c.conrelid IN ('public.user_profile'::regclass,
                     'public.role_user_profile'::regclass,
                     'public.user_deletion_jobs'::regclass)
  AND c.contype IN ('c','u','p')
ORDER BY c.conrelid::regclass::text,c.contype,c.conname;

-- Тесты PG-01..44 должны быть отдельными E2E/SQL-интеграционными тестами,
-- использующими реальные server-side операции и откат фикстур.

-- 7) Проверка BIGINT у полиморфной ссылки и её двух возможных целей.
WITH expected(t,c) AS (
 VALUES ('secret_link','resource_id'),('rule','id'),('dictation_done','id'),('user_profile','id')
)
SELECT e.t AS table_name,e.c AS column_name,
       cols.data_type AS actual_type,
       CASE WHEN cols.column_name IS NULL THEN 'MISSING_COLUMN'
            WHEN cols.data_type <> 'bigint' THEN 'WRONG_TYPE'
            ELSE 'OK' END AS result
FROM expected e
LEFT JOIN information_schema.columns cols
  ON cols.table_schema='public' AND cols.table_name=e.t AND cols.column_name=e.c
ORDER BY e.t,e.c;

-- 8) Фактическая Unicode-коллация, индекс nickname и CHECK состояния.
SELECT collname,collprovider,collisdeterministic
FROM pg_collation WHERE collname IN ('und-x-icu','C') ORDER BY collname;
SELECT indexname,indexdef FROM pg_indexes
WHERE schemaname='public' AND tablename='user_profile'
  AND (indexdef ILIKE '%nickname%' OR indexdef ILIKE '%founder%');
SELECT conname, pg_get_constraintdef(oid,true) AS definition, convalidated
FROM pg_constraint WHERE conrelid='public.user_profile'::regclass
  AND conname IN ('ck_user_profile_state','ck_user_profile_founder_state','ck_user_profile_nickname');

-- 9) Служебные аудиты предназначены для проверки метаданных, НЕ для запуска PG-01..44.
-- Проверить реальные отрицательные/положительные фикстуры отдельно.

-- 10) dictation_record.created_by — NOT NULL, FK RESTRICT и проверка защитного триггера.
-- Ожидаемая колонка: BIGINT NOT NULL; FK входит в секцию 2 (DELETE RESTRICT).
SELECT cols.table_name, cols.column_name, cols.data_type, cols.is_nullable,
       CASE WHEN cols.column_name IS NULL THEN 'MISSING_COLUMN'
            WHEN cols.data_type <> 'bigint' THEN 'WRONG_TYPE'
            WHEN cols.is_nullable <> 'NO' THEN 'WRONG_NULLABILITY'
            ELSE 'OK' END AS result
FROM (VALUES ('dictation_record','created_by')) AS expected(table_name,column_name)
LEFT JOIN information_schema.columns cols
  ON cols.table_schema='public' AND cols.table_name=expected.table_name
 AND cols.column_name=expected.column_name;

SELECT t.tgrelid::regclass AS table_name, t.tgname AS trigger_name,
       pg_get_triggerdef(t.oid) AS trigger_definition,
       t.tgenabled AS enabled_mode,
       CASE WHEN t.oid IS NULL THEN 'MISSING_TRIGGER'
            WHEN t.tgenabled <> 'O' THEN 'NOT_ENABLED_FOR_NORMAL_OPERATIONS'
            ELSE 'REVIEW_TRIGGER_BODY' END AS result
FROM (SELECT 'public.dictation_record'::regclass AS relid) r
LEFT JOIN pg_trigger t ON t.tgrelid=r.relid
  AND t.tgname='trg_dictation_record_created_by_immutable'
  AND NOT t.tgisinternal;

-- Секция 10 проверяет метаданные. Семантический запрет UPDATE проверяется PG-43;
-- сохранение авторства после обезличивания — PG-44. Эти тесты SQL не исполняет.
