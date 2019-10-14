
Util = local({
  ns <- new.env()

  ns$packArguments = function(..., pack = list()) append(pack, list(...))
  ns$toTitleCase <- tools::toTitleCase

  ns$interleave <- function(items, value) {
    reducer <- function(result, item) append(result, list(item, value))
    Reduce(reducer, items, list())
  }

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

  ns$makeTabPanel = function(id, label, ui, ...) {
    ui <- ifelse(is.function(ui), ui, ui$ui)
    tabPanel(label, value = id, ui(id, ...))
  }

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

  return(ns)
})

AsyncQuery <- R6Class(
  "AsyncQuery",
  public = list(
    initialize = function(query) {
      private$.query <- ifelse(is.function(query), query, query$query)
    },
    execute = function(...) {
      future({ self$executeSync(...) }, packages = c("odbc", "DBI"))
    },
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
    disconnect = function(conn) dbDisconnect(conn)
  )
)

Filter <- R6Class(
  "Filter",
  public = list(
    ui = NULL,
    server = NULL,

    initialize = function(fun) {
      self$ui <- function(id, ...) fun(NS(id), ...)
      self$server <- function(input, output, session, ...) input
    }
  )
)

Plot <- R6Class(
  "Plot",
  public = list(
    initialize = function(query, renderer, plotOptions = list(), renderOptions = list()) {
      private$.asyncQuery <- AsyncQuery$new(query)
      private$.renderer <- renderer
      private$.plotOptions <- plotOptions
      private$.renderOptions <- renderOptions
    },

    ui = function(id, ...) {
      options <- private$getPlotOptions(NS(id))
      do.call(plotOutput, options)
    },
    server = function(input, output, session, ...) {
      data <- reactiveVal(future({ NULL }))
      expr <- quote({
        data() %...>% { ifelse(is.null(.), list(), self$renderer(.)) }
      })
      options <- private$getRenderOptions(expr)
      output$plot <- do.call(renderPlot, options)

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
    plotOptions = function() private$.plotOptions,
    renderOptions = function() private$.renderOptions
  ),
  private = list(
    .asyncQuery = NULL,
    .renderer = NULL,
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

Dashboard <- R6Class(
  "Dashboard",
  public = list(
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
      plots <- private$invokeServer(private$.plotNamesPrefixed, private$.plots, ...)
      updaters <- Map(function(plot) plot$update, plots)
      plots <- Map(function(plot) plot$input, plots)

      currentFilters <- isolate(private$snapshotFilters(filters))
      valid <- rep(FALSE, length(private$.plots))

      names(updaters) <- private$.plotNames
      names(valid) <- private$.plotNames

      # Observe filter and tab changes
      observeEvent(input$visualize, {
        newFilters <- private$snapshotFilters(filters)
        if (!identical(newFilters, currentFilters)) {
          currentFilters <- newFilters
          valid[] <- FALSE # Invalidate all data
          updaters[[input$plots]](currentFilters)
        }
      })
      observeEvent(input$plots, {
        updaters[[input$plots]](currentFilters)
      })
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

    invokeUI = function(names, items, ...) {
      Map(function(name, item) item$ui(name, ...), names, items)
    },
    invokeServer = function(names, items, ...) {
      Map(function(name, item) callModule(item$server, name, ...), names, items)
    },
    makeDisplayNames = function(names, prefix) {
      Map(function(name, index) {
        ifelse(name != index, Util$toTitleCase(name), paste(prefix, index))
      }, names, 1:length(names))
    },
    snapshotFilters = function(filters) {
      result <- Map(reactiveValuesToList, filters)
      names(result) <- private$.filterNames
      return(result)
    },

    createSidebar = function(ns, ...) {
      tags <- private$invokeUI(ns(private$.filterNamesPrefixed), private$.filters, ...)
      interleavedTags <- Util$interleave(tags, hr())

      do.call(sidebarPanel, Util$packArguments(
        width = 3,
        pack = interleavedTags,
        actionButton(ns("visualize"), "Visualize!")
      ))
    },
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
