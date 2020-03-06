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
    CASE gender
       WHEN 'o' THEN NULL
       WHEN 'NULL' THEN NULL
       ELSE gender
    END AS gender,
    CASE level_of_education
      WHEN 'p_oth' THEN 'p'
      WHEN 'p_se' THEN 'p'
      WHEN 'NULL' THEN NULL
      ELSE level_of_education
    END AS level_of_education,
    year_of_birth
FROM edx_profiles AS P
INNER JOIN edx_users AS U ON (P.user_id = U.id)
WHERE (U.is_staff = '0')
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
FROM edx_enrollment AS E
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
FROM edx_log AS L
INNER JOIN dv_students AS S ON (L.username = S.username);

-- dv_parent_child
CREATE OR REPLACE VIEW dv_parent_child AS 
SELECT "resource_id" "parent_id" ,
         "child_id" ,
         "row_number"()
    OVER (PARTITION BY "resource_id") "child_order"
FROM (edx_course_structure_prod_analytics a
CROSS JOIN UNNEST("a"."children") t(child_id)) 

-- dv_course_str
CREATE OR REPLACE VIEW dv_course_str AS 
WITH ord AS 
	(WITH crs AS  
		  (WITH core AS  
				(WITH core AS  
					  (WITH core AS
						   (WITH core AS 
								 (WITH core AS 
									   (SELECT DISTINCT
											SPLIT_PART(SPLIT_PART(resource_id,'+type',1),':',2) AS course_id,
											resource_id AS module_id,
											SPLIT_PART(resource_id,'@',3) AS mod_hex_id,
											category AS module_type,
											metadata.display_name AS name,
											resource_id as parent_id,
											0 as child_order
										FROM edx_course_structure_prod_analytics
										WHERE category='course'
										UNION
										SELECT DISTINCT
											SPLIT_PART(SPLIT_PART(a.resource_id,'+type',1),':',2) AS course_id,
											a.resource_id AS module_id,
											SPLIT_PART(a.resource_id,'@',3) AS mod_hex_id,
											a.category AS module_type,
											a.metadata.display_name AS name,
											b.parent_id,
											b.child_order AS child_order
											FROM edx_course_structure_prod_analytics AS a
											INNER JOIN dv_parent_child AS b ON (a.resource_id = b.child_id))       
										SELECT core.course_id,
											core.module_id,
											core.mod_hex_id,
											core.module_type,
											core.name,
											core.parent_id,
											MIN(core.child_order) AS child_order
										FROM core
										GROUP BY core.course_id, core.mod_hex_id, core.module_id, core.module_type, core.name, core.parent_id),
								ver AS (SELECT a.module_id ,
											   a.parent_id AS v_mod_id,
											   a.child_order AS ct_child_order
										FROM core AS a
										WHERE NOT (module_type = 'vertical' 
												   OR module_type = 'sequential' 
												   OR module_type = 'chapter'
												   OR module_type = 'course')
										UNION
										SELECT a.module_id,
											   a.module_id AS v_mod_id,
											   0 AS ct_child_order
										FROM core AS a
										WHERE (module_type = 'vertical'))
								SELECT a.*,
									   b.v_mod_id,
									   b.ct_child_order
								FROM core AS a
								LEFT JOIN ver AS b ON (a.module_id = b.module_id)),
						seq AS (SELECT a.module_id,
									   b.parent_id AS s_mod_id,
									   b.child_order AS v_child_order
								FROM core AS a
								JOIN dv_parent_child AS b ON a.v_mod_id = b.child_id
								WHERE NOT (module_type = 'sequential' 
										  OR module_type = 'chapter'
										  OR module_type = 'course')
								UNION
								SELECT a.module_id,
									   a.module_id AS s_mod_id,
									   0 AS v_child_order
								FROM core AS a
								WHERE module_type = 'sequential')              
						SELECT DISTINCT a.*,
										b.s_mod_id,
										b.v_child_order
						FROM core AS a
						LEFT JOIN seq AS b ON (a.module_id = b.module_id)),
				chp AS (SELECT a.module_id,
							   b.parent_id AS c_mod_id,
							   b.child_order AS s_child_order
						FROM core AS a
						JOIN dv_parent_child AS b ON a.s_mod_id = b.child_id
						WHERE NOT (module_type = 'chapter' 
								   OR module_type = 'course')
						UNION
						SELECT a.module_id,
							   a.module_id AS c_mod_id,
							   0 AS s_child_order
						FROM core AS a
						WHERE (module_type = 'chapter'))
				SELECT DISTINCT a.*,
								b.c_mod_id,
								b.s_child_order
				FROM core AS a
				LEFT JOIN chp AS b ON (a.module_id = b.module_id)),
			crs AS (SELECT a.module_id,
						   b.parent_id AS cr_mod_id,
						   b.child_order AS ch_child_order
					FROM core AS a
					JOIN dv_parent_child AS b ON a.c_mod_id = b.child_id
					WHERE NOT (module_type = 'course')
					UNION
					SELECT a.module_id,
						   a.module_id AS c_mod_id,
						   0 AS ch_child_order
					FROM core AS a
					WHERE (module_type = 'course'))
			SELECT DISTINCT a.*,
							b.cr_mod_id,
							b.ch_child_order
			FROM core AS a
			LEFT JOIN crs AS b ON a.module_id = b.module_id)
	SELECT a.course_id,
		   a.module_id,
		   a.mod_hex_id,
		   a.module_type,
		   a.name,
		   SPLIT_PART(a.parent_id,'@',3) AS parent_id,
		   a.child_order
	FROM crs as a
	ORDER BY a.course_id ASC,
			 a.ch_child_order ASC,
			 a.s_child_order ASC,
			 a.v_child_order ASC,
			 a.ct_child_order ASC)
SELECT a.*,
	   ROW_NUMBER() OVER (PARTITION BY a.course_id) "order"
FROM ord AS a
     
-- TODO
-- dv_modules

-- dv_transitions
