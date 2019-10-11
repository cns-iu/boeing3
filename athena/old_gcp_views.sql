-- Course Modules
CREATE OR REPLACE TABLE learning_trajectories.course_modules
  ( 
    module_id STRING OPTIONS(description="Module ID"),
    course_id STRING OPTIONS(description="Course ID"),
    category STRING OPTIONS(description="Category (course, chapter, sequential, vertical, etc.)"),
    name STRING OPTIONS(description="Module Name"),
    chapter_id STRING OPTIONS(description="Module ID of the chapter this item falls in"),
    sequential_id STRING OPTIONS(description="Module ID of the sequential this item falls in"),
    vertical_id STRING OPTIONS(description="Module ID of the vertical this item falls in"),
    level INT64 OPTIONS(description="The level of the heirarchy this item falls in, 0 = course, 1 = chapter, 2 = sequential, 3 = vertical, 4 = all others"),
    index INT64 OPTIONS(description="The sequential index of the module"),
    first_leaf_index INT64 OPTIONS(description="The first leaf index of the module, ie the lowest level they'll be placed when going to this module"),
    chapter_name STRING OPTIONS(description="Associated Chapter Module Name"),
    sequential_name STRING OPTIONS(description="Associated Sequential Module Name")
  )
  OPTIONS (
   friendly_name="Course Modules",
   description="a list of course modules available in the database"
 )
AS
  WITH course_modules AS (
    SELECT 
      url_name AS module_id, course_id, category, name,
      IF(category NOT IN ('course', 'chapter'), SPLIT(path, '/')[SAFE_OFFSET(1)], NULL) AS chapter_id,
      IF(category NOT IN ('course', 'chapter', 'sequential'), IF(category='vertical', parent, SPLIT(path, '/')[SAFE_OFFSET(2)]), NULL) AS sequential_id,
      IF(category NOT IN ('course', 'chapter', 'sequential', 'vertical'), parent, NULL) AS vertical_id,
      CASE 
        WHEN category = 'course' THEN 0
        WHEN category = 'chapter' THEN 1
        WHEN category = 'sequential' THEN 2
        WHEN category = 'vertical' THEN 3
        ELSE 4
      END AS level,
      index
    FROM (
      SELECT * FROM MITProfessionalX__SysEngxB1__1T2017_latest.course_axis
      UNION ALL
      SELECT * FROM MITProfessionalX__SysEngxB1__3T2016_latest.course_axis
      UNION ALL
      SELECT * FROM MITxPRO__AMxB__1T2018_latest.course_axis
      UNION ALL
      SELECT * FROM MITxPRO__SysEngxB1__3T2017_latest.course_axis
    ) AS A
    ORDER BY course_id, index ASC
  ), leaf_indexes AS (
    SELECT
      module_id,
      MIN(first_leaf_index) AS first_leaf_index
    FROM (
      SELECT chapter_id AS module_id,
        FIRST_VALUE(index) OVER(PARTITION BY chapter_id ORDER BY level DESC, index ASC) AS first_leaf_index
      FROM course_modules WHERE chapter_id IS NOT NULL
      UNION ALL
      SELECT sequential_id AS module_id,
        FIRST_VALUE(index) OVER(PARTITION BY sequential_id ORDER BY level DESC, index ASC) AS first_leaf_index
      FROM course_modules WHERE sequential_id IS NOT NULL
      UNION ALL
      SELECT vertical_id AS module_id,
        FIRST_VALUE(index) OVER(PARTITION BY vertical_id ORDER BY level DESC, index ASC) AS first_leaf_index
      FROM course_modules WHERE vertical_id IS NOT NULL
    )
    GROUP BY module_id
  ), cm2 AS (
  SELECT CM.*, coalesce(L.first_leaf_index, index) AS first_leaf_index
  FROM
    course_modules AS CM 
    LEFT OUTER JOIN leaf_indexes AS L
      ON CM.module_id = L.module_id
  ), labels AS (
    SELECT module_id, name
    FROM cm2
  ), cm3 AS (
    SELECT 
      M.*,
      L1.name AS chapter_name,
      L2.name AS sequential_name
    FROM cm2 AS M
      LEFT OUTER JOIN labels AS L1 ON (M.chapter_id = L1.module_id)
      LEFT OUTER JOIN labels AS L2 ON (M.sequential_id = L2.module_id)
  )
  SELECT * FROM cm3
  ORDER BY level ASC, index ASC


-- Courses
CREATE OR REPLACE TABLE learning_trajectories.courses
  ( 
    course_id STRING OPTIONS(description="Course ID"),
    course_title STRING OPTIONS(description="Course Title")
  )
  OPTIONS (
   friendly_name="Courses",
   description="a list of courses available in the database"
 )
AS
  SELECT 'MITxPRO/AMxB/1T2018' AS course_id, 'Additive Manufacturing for Innovative Design and Production, Spring 2018' AS course_title
  UNION ALL
  SELECT 'MITxPRO/SysEngxB1/3T2017' AS course_id, 'Architecture of Complex Systems, Fall 2017' AS course_title
  UNION ALL
  SELECT 'MITProfessionalX/SysEngxB1/1T2017' AS course_id, 'Architecture of Complex Systems, Spring 2017' AS course_title
  UNION ALL
  SELECT 'MITProfessionalX/SysEngxB1/3T2016' AS course_id, 'Architecture of Complex Systems, Fall 2016' AS course_title


-- Logs
CREATE OR REPLACE TABLE learning_trajectories.logs AS
  SELECT user_id, course_id,
    NULLIF(SPLIT(SPLIT(SPLIT(page, "?")[OFFSET(0)], "#")[OFFSET(0)], "/")[SAFE_OFFSET(6)], '') AS module_id,
    (SPLIT(SPLIT(SPLIT(page, "?")[OFFSET(0)], "#")[OFFSET(0)], "/")[SAFE_OFFSET(7)]) AS sequential_id,
    time, event_type, page
  FROM (
    SELECT P.user_id, LOG.* FROM 
      `MITProfessionalX__SysEngxB1__1T2017_logs.tracklog_*` AS LOG,
      `MITProfessionalX__SysEngxB1__1T2017_latest.person_course` AS P
    WHERE LOG.username = P.username AND P.roles = 'Student'
    UNION ALL
    SELECT P.user_id, LOG.* FROM 
      `MITProfessionalX__SysEngxB1__3T2016_logs.tracklog_*` AS LOG,
      `MITProfessionalX__SysEngxB1__3T2016_latest.person_course` AS P
    WHERE LOG.username = P.username AND P.roles = 'Student'
    UNION ALL
    SELECT P.user_id, LOG.* FROM 
      `MITxPRO__AMxB__1T2018_logs.tracklog_*` AS LOG,
      `MITxPRO__AMxB__1T2018_latest.person_course` AS P
    WHERE LOG.username = P.username AND P.roles = 'Student'
    UNION ALL
    SELECT P.user_id, LOG.* FROM 
      `MITxPRO__SysEngxB1__3T2017_logs.tracklog_*` AS LOG,
      `MITxPRO__SysEngxB1__3T2017_latest.person_course` AS P
    WHERE LOG.username = P.username AND P.roles = 'Student'
  ) AS A


-- Students
CREATE OR REPLACE TABLE learning_trajectories.students AS
  SELECT user_id, course_id, grade, gender, LoE, YoB, cert_created_date, cert_modified_date, cert_status
  FROM (
    SELECT * FROM MITProfessionalX__SysEngxB1__1T2017_latest.person_course
    UNION ALL
    SELECT * FROM MITProfessionalX__SysEngxB1__3T2016_latest.person_course
    UNION ALL
    SELECT * FROM MITxPRO__AMxB__1T2018_latest.person_course
    UNION ALL
    SELECT * FROM MITxPRO__SysEngxB1__3T2017_latest.person_course
  ) AS A
  WHERE roles='Student' AND is_active=1 AND cert_created_date IS NOT NULL
  ORDER BY course_id, user_id ASC 


-- Transitions
CREATE OR REPLACE TABLE learning_trajectories.transitions AS
  WITH logs AS (
    SELECT *,
    LEAD(time) OVER(PARTITION BY course_id, user_id ORDER BY time ASC) AS next_time
    FROM learning_trajectories.logs
  ), logs2 AS (
    SELECT *, TIMESTAMP_DIFF(next_time, time, SECOND) / 60 AS duration FROM logs
  ), logs3 AS (
    SELECT LOG.*, CM.index, CM.first_leaf_index,
      LEAD(LOG.sequential_id) OVER(PARTITION BY LOG.course_id, user_id ORDER BY time ASC) AS next_module_id
    FROM logs2 AS LOG, learning_trajectories.course_modules AS CM
    WHERE CM.sequential_id = LOG.sequential_id AND CM.course_id = LOG.course_id
     AND event_type NOT IN 
        ('page_close', 'show_transcript', 'hide_transcript', 'speed_change_video', 
         'load_video', 'openassessment.upload_file', 'edx.video.closed_captions.shown', 
         'edx.video.closed_captions.hidden', 'edx.bookmark.accessed'
        )
  ), logs4 AS (
    SELECT *, 
      LEAD(index) OVER(PARTITION BY course_id, user_id ORDER BY time ASC) AS next_index,
      LEAD(first_leaf_index) OVER(PARTITION BY course_id, user_id ORDER BY time ASC) AS next_first_leaf_index
    FROM logs3
  ), logs5 AS (
    SELECT 
      user_id, course_id, sequential_id AS module_id, 
      IF(sequential_id = next_module_id, null, next_module_id) AS next_module_id,
      index,
      IF(sequential_id = next_module_id, null, next_index) AS next_index,
      first_leaf_index,
      IF(sequential_id = next_module_id, null, next_first_leaf_index) AS next_first_leaf_index,
      IF(sequential_id = next_module_id OR IFNULL(next_module_id, 'NULL') = 'NULL', 'sl', IF(next_index > index, 'p', 'n')) AS direction,
      IF(sequential_id = next_module_id, 0, next_index - index) AS distance,
      event_type, duration, time
    FROM logs4
  ), sequentialLabels AS (
    SELECT module_id, name
    FROM learning_trajectories.course_modules
    WHERE level = 2 -- 2 = sequential
  ), moduleLabels AS (
    SELECT M.module_id, coalesce(S.name, M.name) AS name
    FROM learning_trajectories.course_modules AS M
      LEFT OUTER JOIN sequentialLabels AS S ON (M.sequential_id = S.module_id)
  )
  SELECT logs5.*, M1.name AS module_label, M2.name AS next_module_label FROM logs5
    INNER JOIN moduleLabels AS M1 ON (logs5.module_id = M1.module_id)
    INNER JOIN moduleLabels AS M2 ON (logs5.next_module_id = M2.module_id)
  --ORDER BY course_id, user_id, time ASC
