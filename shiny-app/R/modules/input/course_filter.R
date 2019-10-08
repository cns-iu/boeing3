
courseFilterInput <- function(id, yearRange, terms, courses) {
  ns <- NS(id)

  tagList(
    sliderInput(
      ns("year"), "Year",
      min = yearRange[1], max = yearRange[2], value = yearRange[2],
      step = 1, sep = "", ticks = FALSE
    ),
    selectInput(
      ns("term"), "Term",
      choices = terms
    ),
    selectInput(
      ns("course"), "Course",
      choices = courses
    )
  )
}

courseFilter <- function(input, output, session) {
  reactive({
    list(
      year = input$year,
      term = input$term,
      course = input$course
    )
  })
}
