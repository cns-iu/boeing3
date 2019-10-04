
courseFilterInput <- function(id, yearRange, terms, courses) {
  ns <- shiny::NS(id)

  shiny::tagList(
    shiny::sliderInput(
      ns("year"), "Year",
      min = yearRange[1], max = yearRange[2], value = yearRange[2],
      step = 1, sep = "", ticks = FALSE
    ),
    shiny::selectInput(
      ns("term"), "Term",
      choices = terms
    ),
    shiny::selectInput(
      ns("course"), "Course",
      choices = courses
    )
  )
}

courseFilter <- function(input, output, session) {
  shiny::reactive({
    list(
      year = input$year,
      term = input$term,
      course = input$course
    )
  })
}
