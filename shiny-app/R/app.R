library("shiny")
library("R6")
library("magrittr")
library("tools")
library("future")
library("promises")
library("DBI")
source("modules/util.R")
source("modules/filters/course.R")
source("modules/filters/student.R")
source("modules/ui/home.R")
source("modules/ui/example-dashboard.R")

plan("multiprocess")

ui <- navbarPage(
  id = "pageTabs",
  title = "EdX Learning Analytics and Visualization - Interactive Prototypes",
  collapsible = TRUE,

  Util$makeTabPanel("home", "Home", homeUI),
  Util$makeTabPanel(
    "example-dashboard-1", "Example Dashboard 1", exampleDashboard,
    # Additional arguments are forwarded to the ui calls in the dashboard
    # These argument should all be named to prevent confusing results

    # Course filter arguments
    yearRange = c(2008, 2019), courses = list(
      `Advance Manufacturing` = list("NY", "NJ", "CT"),
      `Leadership at all Levels` = list("WA", "OR", "CA"),
      `Aerospace` = list("Aeropace")
    ),

    # Student filter arguments
    gradeRange = c(0, 1), ageRange = c(18, 90), levelOfEducation = c(
      "High School", "Associates", "Bachelors",
      "Masters", "Doctoral", "Not Specified"
    )
  )
)

server <- function(input, output, session) {
  Util$loadOnFirstTabSwitch(input, "pageTabs", "example-dashboard-1", exampleDashboard)
}

shinyApp(ui, server)
