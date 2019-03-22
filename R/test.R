library(futile.logger)
library(lubridate)
library(dplyr)
library(magrittr)
devtools::load_all('TestHarness')


# An example prediction function - replace with a function that calls your trained model.
persistence <- function(runtime, load, horizon = 24) {
  # This prediction simply carries the present value forward to future values.

  validtime <- runtime + as.difftime(seq_len(horizon)-1, units = 'hours')

  load %<>%
    mutate(hour = hour(validtime)) %>%
    group_by(hour) %>%
    slice(which.max(validtime)) %>%
    ungroup() %>%
    select(hour, target_load)

  forecast <- data.frame(runtime = runtime,
                         validtime = validtime) %>%
    mutate(hour = hour(validtime)) %>%
    left_join(load, by = 'hour') %>%
    select(runtime, validtime, prediction = target_load)

  forecast
}

#' Feeds data to a prediction function, one runtime at a time.
#'
#' Ensures that the `predict.fun` doesn't have access to data that wouldn't be available yet at each
#' runtime.
#'
#' @param predict.fun a function that takes arguments `runtime` (a `POSIXt` object), `load` (a
#'   data.frame), and `horizon` (number of forward timesteps to make predictions)
#'
#' @param test_data a list comprising the following dataframes:
#' \itemize{
#'  \item{"load"}{Load data with columns `c('validtime', 'target_load')`}
#'  \item{"gfs"}{GFS data with columns `c('runtime', 'validtime', 'Temp.*', 'Relative_humidity.*')`}
#'  \item{"nam"}{NAM data comprising columns `c('runtime', 'validtime', 'Temp.*', 'DewPoint.*')`}
#'  }
#'
run <- function(predict.fun, test_data) {

  test_data_gen <- TestDataGenerator$new(test_data = test_data)
  results <- data.frame()

  while(TRUE) {
    d <- test_data_gen$next_runtime(lag=5)

    if (is.null(d)) {
      return(arrange(results, runtime, validtime))
    }

    runtime <- d$runtime
    flog.info('Runtime: %s ', as.character(runtime))

    load<- d$data$load
    forecast <- predict.fun(runtime, load)

    results %<>%
      bind_rows(forecast)
  }
}

test_data <- simulate_dataset()
results <- run(persistence, test_data)
evaluation_metrics <- evaluate_forecast(results, test_data$load)
write.csv(results, 'results.csv')
write.csv(evaluation_metrics$hourly_metrics, 'hourly_error_metrics.csv')
