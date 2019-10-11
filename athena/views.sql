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
  SELECT DISTINCT P.user_id, U.username, U.date_joined, gender, level_of_education, year_of_birth
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
    'TODO' AS sequential_id,
    'TODO' AS vertical_id,
    L.time,
    L.event_type,
    L.page
  FROM
    edx_log AS L
    INNER JOIN dv_students AS S ON (L.username = S.username);

-- TODO
-- dv_modules
-- dv_transitions
