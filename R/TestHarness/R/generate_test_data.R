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

    initialize=function() {
      private$start_time = ymd_hms('2018-08-20 08:00:00')
      private$end_time = ymd_hms('2019-02-10 08:00:00')
      private$resolution = as.difftime(1, units = 'days')
      private$runtimes = seq(from=start_time, to=end_time, by=resolution)
      private$steps = 1
      private$test_data = TestHarness:::test_data
    },

    next_runtime = function(lag=30) {

      if (private$steps > length(private$runtimes)) {
        flog.warn('No more data to fetch.')
        return(NULL)
      }

      t <- private$runtimes[private$steps]

      load_1_load <- private$test_data$load_1$load %>%
        filter(validtime <= t - days(3), validtime >= t - days(3 + lag)) %>%
        arrange(validtime)
      load_12_load <- private$test_data$load_12$load %>%
        filter(validtime <= t - days(3), validtime >= t - days(3 + lag)) %>%
        arrange(validtime)
      load_51_load <- private$test_data$load_51$load %>%
        filter(validtime <= t - days(3), validtime >= t - days(3 + lag)) %>%
        arrange(validtime)

      load_1_gfs <- private$test_data$load_1$gfs %>%
        filter(runtime <= t, runtime >= t - days(lag)) %>%
        arrange(runtime, validtime)
      load_12_gfs <- private$test_data$load_12$gfs %>%
        filter(runtime <= t, runtime >= t - days(lag)) %>%
        arrange(runtime, validtime)
      load_51_gfs <- private$test_data$load_51$gfs %>%
        filter(runtime <= t, runtime >= t - days(lag)) %>%
        arrange(runtime, validtime)

      load_1_nam <- private$test_data$load_1$nam %>%
        filter(runtime <= t, runtime >= t - days(lag)) %>%
        arrange(runtime, validtime)
      load_12_nam <- private$test_data$load_12$nam %>%
        filter(runtime <= t, runtime >= t - days(lag)) %>%
        arrange(runtime, validtime)
      load_51_nam <- private$test_data$load_51$nam %>%
        filter(runtime <= t, runtime >= t - days(lag)) %>%
        arrange(runtime, validtime)

      private$steps <- private$steps + 1

      return(list(runtime = t,
                  data = list(load_1 = list(load = load_1_load,
                                            gfs = load_1_gfs,
                                            nam = load_1_nam),
                              load_12 = list(load = load_12_load,
                                             gfs = load_12_gfs,
                                             nam = load_12_nam),
                              load_51 = list(load = load_51_load,
                                             gfs = load_51_gfs,
                                             nam = load_51_nam))))
    }),

  private = list(
    start_time = NULL,
    end_time = NULL,
    resolution = NULL,
    runtimes = NULL,
    steps = 1,
    test_data = NULL
  )
)


