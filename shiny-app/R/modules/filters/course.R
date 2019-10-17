
courseFilter <- Filter$new(
  # 1st arg: A function for namespacing ids, other args: any - should be set in calls to makeTabPanel
  # NOTE: This function MUST end with ...
  function(ns, yearRange, courses, terms = c("Spring", "Summer", "Fall"), ...) {
    tagList(
      sliderInput(
        ns("year"), "Year",
        yearRange[1], yearRange[2], yearRange[2], 1,
        ticks = FALSE, sep = ""
      ),
      selectInput(
        ns("term"), "Term", terms
      ),
      selectInput(
        ns("course"), "Course", courses
      )
    )
  },
  subquery = paste(
    "SELECT course_id FROM dt_courses WHERE",
    "year(from_iso8601_timestamp(course_start)) = ?year"
  )
)
