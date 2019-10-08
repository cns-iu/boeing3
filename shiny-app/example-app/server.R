#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(odbc)
library(DBI)

# Get a connection
DBI::dbConnect(
  odbc::odbc(), 
  Driver = Sys.getenv("ATHENA_ODBC_DRIVER"),
  AwsRegion = Sys.getenv("AWS_REGION"),
  AuthenticationType = "IAM Credentials",
  S3OutputLocation = Sys.getenv("ATHENA_RESULTS_BUCKET"),
  schema = Sys.getenv("ATHENA_DATABASE_ID"),
  UID = Sys.getenv("AWS_ACCESS_KEY_ID"),
  PWD = Sys.getenv("AWS_SECRET_ACCESS_KEY"),
  sessionToken = Sys.getenv("AWS_SESSION_TOKEN")
) -> con

df=dbGetQuery(con, "SELECT CAST(percent_grade AS real) AS grade FROM edx_grades_persistentcoursegrade")

dbDisconnect(con)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
  output$distPlot <- renderPlot({
    
    # generate bins based on input$bins from ui.R
    grades    <- df[, 1]
    bins <- seq(min(grades), max(grades), length.out = input$bins + 1)
    
    # draw the histogram with the specified number of bins
    hist(grades, breaks = bins, col = 'darkgray', border = 'white')
    
  })
  
})
