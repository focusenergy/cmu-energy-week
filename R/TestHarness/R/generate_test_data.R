#' Test Data Generator
#'
#' This class generates runtimes, and test load and weather data available for the runtimes
#'
#' @section Usage:
#' \preformatted{gen <- TestDataGenerator$new()
#' result <- gen$next_runtime(lag=20)
#' runtime <- result$runtime
#' data <- result$data
#' }
#'
#' @importFrom R6 R6Class
#' @importFrom futile.logger flog.warn
#' @importFrom dplyr filter arrange
#' @importFrom magrittr %>%
#' @importFrom lubridate ymd_hms days
#'
#' @name TestDataGenerator
#' @export
NULL
TestDataGenerator <- R6Class(
  'TestDataGenerator',
  portable = FALSE,

  public = list(
    start_time = ymd_hms('2018-08-20 08:00:00'),
    end_time = ymd_hms('2019-02-10 08:00:00'),
    test_data = NULL,

    initialize=function(...) {
      args <- list(...)
      for (i in seq_along(args)) {
        name <- names(args[i])
        if (exists(name, self))
          self[[name]] <- args[[i]]
        else
          stop("Unknown attribute '", name, "'")
      }
      if (!is.null(self$test_data)) {
        private$resolution = as.difftime(1, units = 'days')
        private$runtimes = seq(from=self$start_time, to=self$end_time, by=private$resolution)
        private$steps = 1
      } else {
        stop("Test data is NULL.")
      }
    },

    next_runtime = function(lag=30) {

      if (private$steps > length(private$runtimes)) {
        flog.warn('No more data to fetch.')
        return(NULL)
      }

      t <- private$runtimes[private$steps]

      load <- self$test_data$load %>%
        filter(validtime <= t - days(3), validtime >= t - days(3 + lag)) %>%
        arrange(validtime)

      gfs <- self$test_data$gfs %>%
        filter(runtime <= t, runtime >= t - days(lag)) %>%
        arrange(runtime, validtime)

      nam <- self$test_data$nam %>%
        filter(runtime <= t, runtime >= t - days(lag)) %>%
        arrange(runtime, validtime)

      private$steps <- private$steps + 1

      return(list(runtime = t,
                  data = list(load = load,
                              gfs = gfs,
                              nam = nam)))
    }),

  private = list(
    resolution = NULL,
    runtimes = NULL,
    steps = 1
  )
)


