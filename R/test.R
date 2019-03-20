library(TestHarness)
library(futile.logger)
library(lubridate)
library(dplyr)
library(magrittr)

run <- function(model=NULL) {

  test_data_gen <- TestDataGenerator$new()
  done <- FALSE
  results <- NULL

  while(!done) {

    d <- test_data_gen$next_runtime(lag=5)

    if (!is.null(d)) {

      ##---------The code below is an example: replace the prediction code to use your trained model(s)-------------##
      runtime <- d$runtime
      flog.info('Runtime: %s ', as.character(runtime))

      load_1 <- d$data$load_1$load
      forecast <- persistence(runtime, load_1)

      if(is.null(results)) {

        results <- forecast
      } else {

        results %<>%
          bind_rows(forecast) %>%
          arrange(runtime, validtime)
      }
      #################################################################################################################
    } else {
      done <- TRUE
      return(results)
    }
  }
  results
}

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

