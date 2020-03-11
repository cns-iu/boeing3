library("shiny")
library("DBI")
library("DT")
library("dplyr")
library("magrittr")
library("R6")
library("tools")
library("future")
library("promises")

# library("showtext")

# library("igraph")
# library("ggplot2")
# library("ggraph")
# library("stringr")

source("modules/c.R")
#source("modules/util.R")
#source("modules/ui/palettes.R")

#Query plan
future::plan("sequential")

#UI
ui <- fluidPage(
  titlePanel(title = "EdX Learning Analytics and Visualization - Interactive Prototypes"),
  hr(),
  sidebarLayout(
    sidebarPanel(
      selectizeInput("crsInput", "Courses", choices=NULL, selected=NULL, multiple = FALSE, size=1),
      actionButton("goCrs", "Select course")),
    # conditionalPanel(condition = "input.goButton >= 0 ",
    #   selectInput("breaks", "Breaks",
    #               c("Sturges", "Scott", "Freedman-Diaconis", "[Custom]" = "custom"))
    #   ),
    mainPanel(
      h2(textOutput("crsName")),
      hr(),
      dataTableOutput("crsStr")
      )
    )
  )

#Server
server <- function(input, output, session) {
  #Data - Automatically loaded
  courses <- DBI::dbGetQuery(conn, DBI::sqlInterpolate(conn, "SELECT DISTINCT * FROM dt_courses")) %>% arrange(course_id)
  
  #Set Input - Values
  updateSelectizeInput(session, 'crsInput',
                       choices = courses$course_id,
                       server = TRUE
                       )
  
  
  #Data - Reactive
  #Course info - depends on input$crsInput
  crs_tmp <- 
    eventReactive(input$goCrs,
                  {isolate(courses[courses$course_id==input$crsInput,])}
                  )
    
  #Query Course Structure - depends on input$crsInput
  crs_str <-
    eventReactive(input$goCrs,
                  {crsStr <- isolate(DBI::dbGetQuery(conn,
                                                     DBI::sqlInterpolate(conn,
                                                            paste0("SELECT * FROM dt_course_str WHERE course_id = '",
                                                                   input$crsInput,"'"))))
                  names(crsStr) <- c("course_id","mod_id","mod_id_s","type","name","parent_id","child_o","order")
                  crsStr
                  })

  
   
  #Outputs
  #Course Name and Title
  output$crsName <- renderText({
    tmp <- crs_tmp() %>% as.data.frame()
    paste0(tmp$course_title," - \n(",tmp$course_id,")")
  })
  
  #Course Structure - Data Table
  output$crsStr <- renderDataTable({
      crs_str_tmp <- crs_str() %>% as.data.frame()
      crs_str_tmp[,c(8,3:6)]
      },
      options = list(
        pageLength = 10
        )
      )
  }



shinyApp(ui, server, onStart = function() {
  onStop(function() {
    # Close all background workers
    future::plan("sequential")
  })
})

