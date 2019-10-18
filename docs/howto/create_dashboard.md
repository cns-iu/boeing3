# Creating a new dashboard
A new dashboard is created using `dashboard <- Dashboard$new(filters, plots)`.
The dashboard can be placed in the top level *app.R* file or its own file and then sourced.

## filters
A list of `Filter` instances. May be named in which case they will be available under those names in the plots query functions.

## plots
A list of `Plot` instances. If named those names will be used as the label of corresponding plot tab.

# Usage
Each dashboard has an ui and server module functions that can be called just as regular shiny module functions.
```R
dashboard <- Dashboard$new([...])
myui <- shiny::fluidPage(
  dashboard$ui("mydashboard" [, filter1.arg1][, filter1.arg2] [, ...])
)
```

```R
dashboard <- Dashboard$new([...])
myserver <- function(input, output, session) {
  shiny::callModule(dashboard$server, "mydashboard")
}
```
