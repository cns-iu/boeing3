exampleDashboardPlot1 <- Plot$new(
  # Database query function. 1st arg: database connection, 2nd arg: list of current filters
  function(conn, filters) {
    # filters contains one group of values for each filter passed to the dashboard
    # They can be accessed using the same names as given to the dashboard
    # I.e. Dashboard$new(list(foo = ..., bar = ...), ...) => filters$foo and filters$bar

    # Sample query
    dbGetQuery(conn, "SELECT CAST(percent_grade AS real) AS grade FROM edx_grades_persistentcoursegrade")
  },
  # Rendering function. Receives a single argument which is the data from the query
  function(data) {
    x <- data[, 1]
    bins <- seq(min(x), max(x), length.out = 11)

    hist(x, breaks = bins, col = 'darkgray', border = 'white')
  }
)

exampleDashboardPlot2 <- Plot$new(
  method = "datatable",
  function(conn, filters) {
    dbGetQuery(conn, sqlInterpolate(
      conn, paste(
        "SELECT * FROM dt_courses",
        "WHERE year(from_iso8601_timestamp(course_start)) = ?year"
      ),
      year = filters$course$year
    ))
  },
  function(data) { data },
  renderOptions = list(options = list(
    dom = "tp",
    pageLength = 5
  ))
)

exampleDashboardPlot3 <- Plot$new(
  method = "datatable",
  function(conn, filters) {
    dbGetQuery(conn, sqlInterpolate(
      conn, paste(
        "SELECT * FROM dt_students WHERE",
        "coalesce(gender, 'X') = ANY (VALUES ?gender)", "AND",
        "coalesce(level_of_education, 'X') = ANY (VALUES ?education)"
      ),
      gender = Util$sqlPasteStrings(conn, filters$student$gender),
      education = Util$sqlPasteStrings(conn, filters$student$levelOfEducation)
    ))
  },
  function(data) { data },
  renderOptions = list(options = list(
    dom = "tp",
    pageLength = 20
  ))
)

exampleDashboard <- Dashboard$new(
  # 1st arg: a list of filters
  list(course = courseFilter, student = studentFilter),
  # 2nd arg: a list of plots
  list(exampleDashboardPlot1, exampleDashboardPlot2, exampleDashboardPlot3)
)
