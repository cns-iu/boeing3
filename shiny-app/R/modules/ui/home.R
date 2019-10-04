
homeUI <- function(id, ...) {
  ns <- shiny::NS(id)

  shiny::tagList(
    shiny::h2("This is the home page!"),
    ...
  )
}
