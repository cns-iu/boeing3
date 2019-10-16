-- https://edx.readthedocs.io/projects/devdata/en/latest/internal_data_formats/sql_schema.html

-- dv_courses
CREATE OR REPLACE VIEW dv_courses AS
  SELECT DISTINCT
    resource_id as course_id,
    metadata.display_name as course_title,
    metadata.start as course_start,
    metadata
  FROM edx_course_structure_prod_analytics
  WHERE category = 'course'
  ORDER BY metadata.start DESC;

-- dv_students
CREATE OR REPLACE VIEW dv_students AS
  SELECT DISTINCT
    P.user_id,
    U.username,
    U.date_joined,
    nullif(gender, 'NULL'),
    CASE level_of_education
      WHEN 'p_oth' THEN 'p'
      WHEN 'p_se' THEN 'p'
      WHEN 'NULL' THEN NULL
      ELSE level_of_education
    END AS level_of_education,
    year_of_birth
  FROM
    edx_profiles AS P
    INNER JOIN edx_users AS U ON (P.user_id = U.id)
  ORDER BY P.user_id;

-- dv_enrollments
CREATE OR REPLACE VIEW dv_enrollments AS
  SELECT DISTINCT
    E.course_id,
    E.user_id,
    E.is_active,
    E.created AS enrollment_created,
    S.username,
    S.date_joined,
    S.gender,
    S.level_of_education,
    S.year_of_birth,
    C.status AS cert_status,
    C.created_date AS cert_created_date,
    C.modified_date AS cert_modified_date,
    C.grade
  FROM
    edx_enrollment AS E
    INNER JOIN dv_students AS S ON (E.user_id = S.user_id)
    INNER JOIN edx_certificates AS C ON (E.user_id = C.user_id AND E.course_id = C.course_id)
  ORDER BY E.course_id, E.user_id;

-- dv_logs
CREATE OR REPLACE VIEW dv_logs AS
  SELECT DISTINCT
    S.user_id,
    L.context.course_id,
    L.module_id,
    COALESCE(
      TRY(SPLIT(SPLIT(SPLIT(L.page, '?')[1],'#')[1], '/')[7]),
      TRY(element_at(SPLIT(L.module_id, '/'), -1))
    ) AS module_hex,
    TRY(SPLIT(SPLIT(SPLIT(L.page, '?')[1],'#')[1], '/')[8]) AS sequential_hex,
    'TODO' AS vertical_hex,
    L.time,
    L.event_type,
    L.page
  FROM
    edx_log AS L
    INNER JOIN dv_students AS S ON (L.username = S.username);

-- TODO
-- dv_modules
-- dv_transitions
