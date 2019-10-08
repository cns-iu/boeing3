
dashboard1UI <- function(id) {
  courses <- list(
    `Advance Manufacturing` = list("NY", "NJ", "CT"),
    `Leadership at all Levels` = list("WA", "OR", "CA"),
    `Aerospace` = list("Aeropace")
  )
  educationLevels <- c(
    "High School", "Associates", "Bachelors",
    "Masters", "Doctoral", "Not Specified"
  )
  ns <- NS(id)

  sidebarLayout(
    sidebarPanel(
      width = 3,
      courseFilterInput(ns("courseFilter"), c(2008, 2019), c("Spring", "Summer", "Fall"), courses),
      hr(),
      studentFilterInput(ns("studentFilter"), c(0, 1), c(18, 90), educationLevels),
      hr(),
      actionButton(ns("visualize"), "Visualize!")
    ),
    mainPanel(
      width = 9,
      tabsetPanel(
        id = ns("visTabs"),
        tabPanel(
          "Vis 1", value = "vis1",
          plotOutput(ns("vis1"))
        ),
        tabPanel(
          "Vis 2", value = "vis2",
          plotOutput(ns("vis2"))
        )
      )
    )
  )
}

dashboard1 <- function(input, output, session) {
  nullQuery <- function(...) {}
  queries <- list(vis1 = dashboard1Vis1Query, vis2 = nullQuery) # FIXME replace queries with real ones
  data <- lapply(queries, function(...) { list(data = reactiveVal(), valid = FALSE) })
  updateData <- function(id, filters) {
    entry <- data[[id]]
    if (!is.null(entry) && !entry$valid) {
      entry$data(queries[[id]](filters))
      entry$valid <- TRUE
      data[[id]] <<- entry
    }
  }

  courseFilters <- callModule(courseFilter, "courseFilter")
  studentFilters <- callModule(studentFilter, "studentFilter")
  currentFilters <- isolate(c(courseFilters(), studentFilters()))

  # Update filter when the button is pressed
  observeEvent(input$visualize, {
    newFilters <- c(courseFilters(), studentFilters())
    if (!identical(currentFilters, newFilters)) {
      currentFilters <- newFilters

      # Invalidate data
      for (id in names(data)) {
        data[[id]]$valid <- FALSE
      }

      # Update data for the current tab
      updateData(input$visTabs, currentFilters)
    }
  })

  # Update data for the selected tab
  observeEvent(input$visTabs, {
    updateData(input$visTabs, currentFilters)
  })

  # Create plots
  output$vis1 <- renderPlot({
    data$vis1$data() %...>% {
      x <- .[, 1]
      bins <- seq(min(x), max(x), length.out = 11)

      hist(x, breaks = bins, col = 'darkgray', border = 'white')
    } %...!% print
  })

  # Add additional plots here!
}
