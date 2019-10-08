
dashboard1Vis1Query <- asyncQuery(function(conn, filter) {
  # FIXME: This is a simple sample query
  dbGetQuery(conn, "SELECT CAST(percent_grade AS real) AS grade FROM edx_grades_persistentcoursegrade")
})
