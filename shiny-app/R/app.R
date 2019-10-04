library("shiny")
source("./modules/ui/home.R")
source("./modules/input/course_filter.R")
source("./modules/input/student_filter.R")


courses <- list(
  `Advance Manufacturing` = list("NY", "NJ", "CT"),
  `Leadership at all Levels` = list("WA", "OR", "CA"),
  `Aerospace` = list("Aeropace")
)

educationLevels <- c(
  "High School", "Associates", "Bachelors",
  "Masters", "Doctoral", "Not Specified"
)


ui <- navbarPage(
  id = "activeTab",
  title = "EdX Learning Analytics and Visualization - Interactive Prototypes",
  collapsible = TRUE,

  tabPanel(
    "Home", value = "home",
    homeUI("home")
  ),

  tabPanel(
    "Dashboard 1", value = "dashboard1",
    sidebarLayout(
      sidebarPanel(
        width = 3,
        courseFilterInput("courseFilter", c(2008, 2019), c("Spring", "Summer", "Fall"), courses),
        hr(),
        studentFilterInput("studentFilter", c(0, 1), c(18, 90), educationLevels)
      ),
      mainPanel(
        # TODO
      )
    )
  )
)

server <- function(input, output, session) {
  course_filters = callModule(courseFilter, "courseFilter")
}

shinyApp(ui, server)
