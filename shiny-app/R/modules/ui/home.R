
homeUI <- function(id, ...) {
  ns <- NS(id)

  tagList(
    h2("This is the home page!"),
    ...
  )
}
