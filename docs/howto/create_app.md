# Create a shiny app with one or more dashboards
## Libraries
For dashboard to work properly the following *R* libraries must be loaded:
- shiny
- DT (if datatable output is used)
- R6
- magrittr
- tools
- future
- promises
- DBI
- odbc

Dashboards are currently using Amazon Athena as a backend and you must therefore have the Athena odbc driver installed.

## Usage
Before dashboard classes can be used the *util.R* file must be sourced.  
Refer to individual class documentation for usage:
- [Dashboard creation](create_dashboard.md)  
- [Dashboard filter creation](create_filter.md)  
- [Dashboard plot creation](create_plot.md)  
