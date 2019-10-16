library("shiny")
library("DT")
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
    yearRange = c(2008, 2019), gender = c(
      "Male" = "m", "Female" = "f", "Other" = "o", "Not Specified" = "X"
    ), courses = list(
      `Advance Manufacturing` = list("NY", "NJ", "CT"),
      `Leadership at all Levels` = list("WA", "OR", "CA"),
      `Aerospace` = list("Aeropace")
    ),

    # Student filter arguments
    gradeRange = c(0, 1), ageRange = c(18, 90), levelOfEducation = c(
      "Doctorate" = "p", "Masters" = "m", "Bachelors" = "b",
      "Associates" = "a", "High School" = "hs", "Junior High / Middle School" = "jhs",
      "Elementary / Primary School" = "el", "No Formal Education" = "none",
      "Other" = "other", "Not Specified" = "X"
    )
  )
)

server <- function(input, output, session) {
  Util$loadOnFirstTabSwitch(input, "pageTabs", "example-dashboard-1", exampleDashboard)
}

shinyApp(ui, server)
