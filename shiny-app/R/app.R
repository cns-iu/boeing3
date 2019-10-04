library("shiny")
source("./modules/ui/home.R")


ui <- navbarPage(
  id = "activeTab",
  title = "EdX Learning Analytics and Visualization - Interactive Prototypes",
  collapsible = TRUE,

  tabPanel("Home", homeUI("home"), value = "home")
)

server <- function(input, output, session) {
}

shinyApp(ui, server)
