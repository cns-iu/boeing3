
asyncQuery <- function(fun) {
  function(...) {
    future({
      connection <- dbConnect(
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
      result <- fun(connection, ...)

      dbDisconnect(connection)
      result
    }, packages = c("odbc", "DBI"))
  }
}
