-- dt_courses
DROP TABLE IF EXISTS dt_courses;
CREATE TABLE dt_courses WITH (format='PARQUET') AS
  SELECT * FROM dv_courses;

-- dt_students
DROP TABLE IF EXISTS dt_students;
CREATE TABLE dt_students WITH (format='PARQUET') AS
  SELECT * FROM dv_students;

-- dt_enrollments
DROP TABLE IF EXISTS dt_enrollments;
CREATE TABLE dt_enrollments WITH (format='PARQUET') AS
  SELECT * FROM dv_enrollments;

-- dt_logs
DROP TABLE IF EXISTS dt_logs;
CREATE TABLE dt_logs
  WITH (
    format='PARQUET',
    partitioned_by = ARRAY['course_id']
  ) AS
  SELECT * FROM dv_logs;
