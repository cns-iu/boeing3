
# Commonly used functions
Util = local({
  ns <- new.env()

  # Packs arguments into a list for use in `do.call`
  ns$packArguments = function(..., pack = list()) append(pack, list(...))

  # Converts the first letter of each word into uppercase
  ns$toTitleCase <- tools::toTitleCase

  # Creates a list where each element is interleaved with a value
  ns$interleave <- function(items, value) {
    reducer <- function(result, item) append(result, list(item, value))
    Reduce(reducer, items, list())
  }

  # Similar to builtin `names` but always returns a list of equal length as the data
  # Also replaces unnamed positions with their index value
  # Optionally adds a prefix to each name
  ns$names <- function(items, prefix = "") {
    initial <- names(items)
    indexes <- 1:length(items)
    fullNames <- indexes
    if (!is.null(initial)) {
      selector <- function(name, index) ifelse(name != "", name, index)
      fullNames <- Map(selector, initial, indexes)
    }

    paste0(prefix, fullNames)
  }

  # Wraps the result of an ui function in a `tabPanel`
  ns$makeTabPanel = function(id, label, ui, ...) {
    ui <- ifelse(is.function(ui), ui, ui$ui)
    tabPanel(label, value = id, ui(id, ...))
  }

  # Loads a server module (using `callModule`) the first time the containing tab is activated
  ns$loadOnFirstTabSwitch = function(input, selector, tab, server, ...) {
    server <- ifelse(is.function(server), server, server$server)
    observer <- observeEvent(input[[selector]], {
      if (input[[selector]] == tab) {
        callModule(server, tab, ...)
        observer$destroy()
        observer <- NULL
      }
    })
  }

  # Safely pastes together multiple strings for use in sql statements
  ns$sqlPasteStrings <- function(conn, ..., sep = ", ", .dots = list()) {
    strings <- as.character(unlist(c(list(...), .dots)))
    quoted <- dbQuoteString(conn, strings)
    SQL(paste(quoted, collapse = sep))
  }

  return(ns)
})

# Turns a synchronous database query into an asynchronous query
AsyncQuery <- R6Class(
  "AsyncQuery",
  public = list(
    # query: A function taking a connection as its 1st argument
    initialize = function(query) {
      private$.query <- ifelse(is.function(query), query, query$query)
    },

    # Executes the query asynchronously
    execute = function(...) {
      future({
        Util; # Ensures Util is loaded and usable in the future session/process
        self$executeSync(...)
      }, packages = c("odbc", "DBI"))
    },

    # Executes the query synchronously
    executeSync = function(...) {
      conn <- private$connect()
      result <- private$.query(conn, ...)
      private$disconnect(conn)
      return(result)
    }
  ),
  active = list(
    query = function() private$.query
  ),
  private = list(
    .query = NULL,

    # Connects to a database using setting provided in .Renviron
    connect = function() {
      dbConnect(
        odbc::odbc(),
        Driver = Sys.getenv("ATHENA_ODBC_DRIVER"),
        AwsRegion = Sys.getenv("AWS_REGION"),
        AuthenticationType = "IAM Credentials",
        S3OutputLocation = Sys.getenv("ATHENA_RESULTS_BUCKET"),
        schema = Sys.getenv("ATHENA_DATABASE_ID"),
        UID = Sys.getenv("AWS_ACCESS_KEY_ID"),
        PWD = Sys.getenv("AWS_SECRET_ACCESS_KEY"),
        sessionToken = Sys.getenv("AWS_SESSION_TOKEN")
      )
    },

    # Releases a connection
    disconnect = function(conn) dbDisconnect(conn)
  )
)

# Creates a simple filter ui and server
Filter <- R6Class(
  "Filter",
  public = list(
    # fun: A function taking a namespace function as its 1st argument and produces the filter ui
    initialize = function(renderer, subquery = NULL) {
      private$.renderer <- renderer
      private$.subquery <- subquery
    },
    ui = function(id, ...) private$.renderer(NS(id), ...),
    server = function(input, output, session, ...) {
      list(
        input = input,
        subquery = private$makeSubQuery
      )
    }
  ),
  active = list(
    renderer = function() private$.renderer,
    subquery = function() private$.subquery
  ),
  private = list(
    .renderer = NULL,
    .subquery = NULL,

    makeSubQuery = function(values) (function(conn) {
      if (is.null(private$.subquery)) return(NULL)

      indexes <- sqlParseVariables(conn, private$.subquery)
      if (length(indexes$start) == 0) return(NULL)
      if (any(indexes$start == indexes$end)) return(NULL)

      variables <- substring(private$.subquery, indexes$start + 1, indexes$end)
      normValues <- Map(function(value) {
        if (is.null(value)) return("")
        if (length(value) == 1) return(value)
        Util$sqlPasteStrings(conn, .dots = value)
      }, values[variables])

      sqlInterpolate(conn, private$.subquery, .dots = normValues)
    })
  )
)

# Creates a plot ui and server
Plot <- R6Class(
  "Plot",
  public = list(
    # query: A function performing database queries for the plot data
    # renderer: A function producing the plots for `renderPlot`
    # method: Shiny render method to use
    # plotOptions: Additional arguments for `plotOutput`
    # renderOptions: Additional arguments for `renderOutput`
    initialize = function(
      query, renderer, method = "plot",
      plotOptions = list(), renderOptions = list()
    ) {
      private$.asyncQuery <- AsyncQuery$new(query)
      private$.renderer <- renderer
      private$.method <- method
      private$.plotOptions <- plotOptions
      private$.renderOptions <- renderOptions

      methods <- switch(
        method,
        "plot" = c(plotOutput, renderPlot),
        "table" = c(tableOutput, renderTable),
        "datatable" = c(DTOutput, renderDT),
        "text" = c(textOutput, renderText),
        "print" = c(verbatimTextOutput, renderPrint),
        "image" = c(imageOutput, renderImage),
        "ui" = c(uiOutput, renderUI)
      )
      private$.outputMethod <- methods[[1]]
      private$.renderMethod <- methods[[2]]
    },

    ui = function(id, ...) {
      options <- private$getPlotOptions(NS(id))
      do.call(private$.outputMethod, options)
    },
    server = function(input, output, session, ...) {
      data <- reactiveVal(future({ NULL }))
      expr <- quote({
        data()  %...>% { if (is.null(.)) { list() } else { private$.renderer(.) } }
      })
      options <- private$getRenderOptions(expr)
      output$plot <- do.call(private$.renderMethod, options)

      list(
        input = input,
        update = function(...) data(self$asyncQuery$execute(...))
      )
    }
  ),
  active = list(
    query = function() self$asyncQuery$query,
    asyncQuery = function() private$.asyncQuery,
    renderer = function() private$.renderer,
    method = function() private$.method,
    plotOptions = function() private$.plotOptions,
    renderOptions = function() private$.renderOptions
  ),
  private = list(
    .asyncQuery = NULL,
    .renderer = NULL,
    .method = NULL,
    .outputMethod = NULL,
    .renderMethod = NULL,
    .plotOptions = NULL,
    .renderOptions = NULL,

    getPlotOptions = function(ns) {
      options <- self$plotOptions
      options$outputId <- ns("plot")
      options$click %<>% private$adjustId(ns)
      options$dblclick %<>% private$adjustId(ns)
      options$hover %<>% private$adjustId(ns)
      options$brush %<>% private$adjustId(ns)
      options$clickId %<>% private$adjustId(ns)
      options$hoverId %<>% private$adjustId(ns)
      return(options)
    },
    getRenderOptions = function(expr) {
      options <- self$renderOptions
      options$expr <- expr
      return(options)
    },
    adjustId = function(opt, ns) {
      if (is.character(opt)) {
        ns(opt)
      } else if (is.list(opt) && is.character(opt$id)) {
        replace(opt, "id", ns(opt$id))
      } else {
        opt
      }
    }
  )
)

# Creates a dashboard consisting of filters and plots
Dashboard <- R6Class(
  "Dashboard",
  public = list(
    # filters: A list of `Filter` instances
    # plots: A list of `Plot` instances
    initialize = function(filters, plots) {
      private$.filters <- filters
      private$.filterNames <- Util$names(filters)
      private$.filterNamesPrefixed <- paste0("filter-", private$.filterNames)
      private$.plots <- plots
      private$.plotNames <- Util$names(plots)
      private$.plotNamesPrefixed <- paste0("plot-", private$.plotNames)
    },

    ui = function(id, ...) {
      ns <- NS(id)
      sidebarLayout(
        private$createSidebar(ns, ...),
        private$createVisualizations(ns, ...)
      )
    },
    server = function(input, output, session, ...) {
      filters <- private$invokeServer(private$.filterNamesPrefixed, private$.filters, ...)
      subqueries <- Map(function(filter) filter$subquery, filters)
      filters <- Map(function(filter) filter$input, filters)
      plots <- private$invokeServer(private$.plotNamesPrefixed, private$.plots, ...)
      updaters <- Map(function(plot) plot$update, plots)
      plots <- Map(function(plot) plot$input, plots)

      currentFilters <- isolate(private$snapshotFilters(filters))
      valid <- rep(FALSE, length(private$.plots))

      names(updaters) <- private$.plotNames
      names(valid) <- private$.plotNames

      updateData <- function() {
        id <- input$plots
        if (!valid[[id]]) {
          valid[[id]] <<- TRUE
          updaters[[id]](Map(function(values, subquery) {
            c(values, subquery = subquery(values))
          }, currentFilters, subqueries))
        }
      }

      # Observe filter and tab changes
      observeEvent(input$visualize, {
        newFilters <- private$snapshotFilters(filters)
        if (!identical(newFilters, currentFilters)) {
          # NOTE: `<<-` is used as this expression is converted into a function by shiny!
          currentFilters <<- newFilters
          valid[] <<- FALSE # Invalidate all data
          updateData()
        }
      })
      observeEvent(input$plots, { updateData(); })
    }
  ),
  active = list(
    filters = function() private$.filters,
    plots = function() private$.plots
  ),
  private = list(
    .filters = NULL,
    .filterNames = NULL,
    .filterNamesPrefixed = NULL,
    .plots = NULL,
    .plotNames = NULL,
    .plotNamesPrefixed = NULL,

    # Calls the ui function on each item
    invokeUI = function(names, items, ...) {
      Map(function(name, item) item$ui(name, ...), names, items)
    },

    # Calls the server function (using `callModule`) on each item
    invokeServer = function(names, items, ...) {
      Map(function(name, item) callModule(item$server, name, ...), names, items)
    },

    # Title cases each name or `{prefix} {index}` if name is an index
    makeDisplayNames = function(names, prefix) {
      Map(function(name, index) {
        ifelse(name != index, Util$toTitleCase(name), paste(prefix, index))
      }, names, 1:length(names))
    },

    # Snapshots the current values for filters
    snapshotFilters = function(filters) {
      result <- Map(reactiveValuesToList, filters)
      names(result) <- private$.filterNames
      return(result)
    },

    # Creates a sidebar panel with each filter separated by a horizontal rule and a visualize button at the bottom
    createSidebar = function(ns, ...) {
      tags <- private$invokeUI(ns(private$.filterNamesPrefixed), private$.filters, ...)
      interleavedTags <- Util$interleave(tags, hr())

      do.call(sidebarPanel, Util$packArguments(
        width = 3,
        pack = interleavedTags,
        actionButton(ns("visualize"), "Visualize!")
      ))
    },

    # Creates a main panel with a tab for each visualization/plot
    createVisualizations = function(ns, ...) {
      tags <- private$invokeUI(ns(private$.plotNamesPrefixed), private$.plots, ...)
      tabs <- Map(
        tabPanel,
        unname(private$makeDisplayNames(private$.plotNames, "Plot")),
        unname(tags), value = private$.plotNames
      )

      mainPanel(
        width = 9,
        do.call(tabsetPanel, Util$packArguments(
          id = ns("plots"),
          pack = tabs
        ))
      )
    }
  )
)
