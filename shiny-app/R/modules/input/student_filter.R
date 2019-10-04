
studentFilterInput <- function(id, gradeRange, ageRange, levelOfEducation) {
  genders <- c("Male", "Female", "Not Specified")
  ns <- shiny::NS(id)

  shiny::tagList(
    shiny::sliderInput(
      ns("grade"), "Filter by Student Grade",
      min = gradeRange[1], max = gradeRange[2], value = gradeRange,
      dragRange = TRUE
    ),
    shiny::sliderInput(
      ns("age"), "Filter by Student Age",
      min = ageRange[1], max = ageRange[2], value = ageRange,
      step = 1, ticks = FALSE, dragRange = TRUE
    ),
    shiny::checkboxGroupInput(
      ns("gender"), "Select Student Genders",
      choices = genders, selected = genders
    ),
    shiny::checkboxGroupInput(
      ns("levelOfEducation"), "Select Student Level of Education",
      choices = levelOfEducation, selected = levelOfEducation
    )
  )
}

studentFilter <- function(input, output, session) {
  shiny::reactive({
    list(
      grade = input$grade,
      age = input$age,
      gender = input$gender,
      levelOfEducation = input$levelOfEducation
    )
  })
}
