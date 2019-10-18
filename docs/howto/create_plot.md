# Creating a new dashboard plot
A new plot is created using `Plot$new(query, process, [method = "plot"], [plotOptions], [renderOptions])`. Plots can be placed in associated their dashboard *R* file or their own file.

## query - `function(connection, filters) -> data`
A function performing all database queries to fetch the data for the plot.

- `connection` is a DBI database connection on which queries can be performed using `dbGetQuery`.
- `filters` is a named list of the current values for each filter attached to the dashboard.

## process - `function(data) -> plot`
A function that should format the data appropriately for use with the specified plot method.

## method [optional] [default="plot"]
The shiny rendering method to use. Available values are `"plot"`, `"table"`, `"datatable"`, `"text"`, `"print"`, `"image"`, or `"ui"`.

## plotOptions [optional]
Additional named arguments to use during plotting. See the corresponding shiny function for available values.

## renderOptions [optional]
Additional named arguments to use during rendering. See the corresponding shiny function for available values.
