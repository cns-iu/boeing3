library("shiny")
library("future")
library("promises")
library("DBI")
source("modules/queries/async_query.R")
source("modules/queries/dashboard1_vis1_query.R")
source("modules/input/course_filter.R")
source("modules/input/student_filter.R")
source("modules/ui/dashboard1.R")
source("modules/ui/home.R")

plan("multiprocess")


makeTabPanelForUI <- function(id, title, UI, ...) {
  tabPanel(title, value = id, UI(id, ...))
}

ui <- navbarPage(
  id = "pageTabs",
  title = "EdX Learning Analytics and Visualization - Interactive Prototypes",
  collapsible = TRUE,

  makeTabPanelForUI("home", "Home", homeUI),
  makeTabPanelForUI("dashboard1", "Dashboard 1", dashboard1UI)
)

server <- function(input, output, session) {
  # Load dashboard 1 on first switch to tab
  dashboard1Observer <- observeEvent(input$pageTabs, {
    if (input$pageTabs == "dashboard1") {
      callModule(dashboard1, "dashboard1")
      dashboard1Observer$destroy()
      dashboard1Observer <- NULL
    }
  })
}

shinyApp(ui, server)
