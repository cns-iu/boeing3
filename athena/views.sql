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

-- dv_parent_child
WITH parent_child AS 
     (SELECT resource_id AS parent_id, 
      child_id    
      FROM edx_course_structure_prod_analytics AS a
      CROSS JOIN UNNEST(a.children) AS t(child_id))

SELECT parent_child.parent_id,
       parent_child.child_id,
       ROW_NUMBER() OVER (PARTITION BY parent_child.parent_id)
       AS child_order
  FROM parent_child;

-- dv_course_str
CREATE OR REPLACE VIEW dv_course_str AS 
WITH core AS ( 
  WITH core AS (
   SELECT
     a.resource_id AS module_id,
     a.category AS module_type,
     a.metadata.display_name AS name,
     b.parent_id AS parent_id,
     b.child_order AS child_order
   FROM edx_course_structure_prod_analytics AS a
   INNER JOIN dv_parent_child AS b ON (a.resource_id = b.child_id)
    ),
  
  vert AS (
    SELECT a.module_id,
           a.parent_id AS parent,
           b.parent_id AS v_mod_id,
           b.child_order AS v_child_order
    FROM core AS a 
    JOIN dv_parent_child AS b ON a.module_id = b.child_id
    WHERE NOT (module_type = 'vertical' 
               OR module_type = 'sequential' 
               OR module_type = 'chapter')
    )
  SELECT a.module_id,
         a.module_type,
         a.name,
         a.parent_id,
         b.v_mod_id,
         a.child_order,
         b.v_child_order
  FROM core AS a
  LEFT JOIN vert AS b ON a.module_id = b.module_id  
  ),
  vtemp AS (
    (SELECT a.module_id,
            a.v_mod_id AS parent_id
    FROM core AS a 
    WHERE NOT (a.module_type = 'vertical' 
               OR a.module_type = 'sequential' 
               OR a.module_type = 'chapter'))
    UNION          
    (SELECT a.module_id,
            a.module_id AS parent_id
    FROM core AS a 
    WHERE a.module_type = 'vertical')
    ),
  seq AS (
    SELECT a.module_id,
           b.parent_id AS s_mod_id,
           b.child_order AS s_child_order
    FROM vtemp AS a 
    JOIN dv_parent_child AS b ON a.parent_id = b.child_id
    )
    
SELECT a.module_id,
       a.module_type,
       a.name,
       a.parent_id,
       a.v_mod_id,
       b.s_mod_id,
       a.child_order,
       a.v_child_order,
       b.s_child_order
   
FROM core AS a 
LEFT JOIN seq AS b ON a.module_id = b.module_id
     
     
-- TODO
-- dv_modules
-- dv_transitions
