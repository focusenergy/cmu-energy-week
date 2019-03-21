library(futile.logger)
library(lubridate)
library(dplyr)
library(magrittr)
devtools::load_all('TestHarness')


# An example prediction function - replace with a function that calls your trained model
persistence <- function(runtime, load, horizon = 24) {

  validtime <- runtime + as.difftime(0:(horizon-1), units = 'hours')

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
run <- function(predict.fun) {

  test_data_gen <- TestDataGenerator$new()
  results <- data.frame()

  while(TRUE) {
    d <- test_data_gen$next_runtime(lag=5)

    if (is.null(d)) {
      return(arrange(results, runtime, validtime))
    }

    runtime <- d$runtime
    flog.info('Runtime: %s ', as.character(runtime))

    load_1 <- d$data$load_1$load
    forecast <- predict.fun(runtime, load_1)

    results %<>%
      bind_rows(forecast)
  }
}

results <- run(persistence)
write.csv(results, 'results.csv')
