#' Computes overall and hourly error metrics for a load forecast
#'
#' @param forecast_load dataframe of forecasts with at least the following columns:
#' \itemize{
#'   \item{"runtime"}{POSIXct, Time when the forecast was run}
#'   \item{"validtime"}{POSIXct, Time for which the `prediction` is valid}
#'   \item{"prediction"}{Predicted load in MW}
#' }
#' @param actual_load dataframe with actual ground-truth loads with columns:
#' \itemize{
#'   \item{"validtime"}{POSIXct, hour ending for which the average load was observed}
#'   \item{"target_load"}{Average load in MW for the hour ending at `validtime`}
#' }
#'
#' @return List comprising the following entries:
#' \itemize{
#'  \item{"errors"}{Dataframe with errors per prediction}
#'  \item{"mae"}{Numeric, overall mean absolute error}
#'  \item{"rmse"}{Numeric, overall root mean-square error}
#'  \item{"hourly_metrics"}{Dataframe with hourly MAE and RMSE}
#' }
#'
#' @importFrom dplyr left_join mutate group_by summarise ungroup
#' @importFrom magrittr %>% %<>%
#' @importFrom lubridate hour
#'
#' @export
#'
evaluate_forecast <- function(forecast_load, actual_load) {

  errors <- forecast_load %>%
    left_join(actual_load, by = 'validtime') %>%
    mutate(error = prediction - target_load,
           absolute_error = abs(error),
           square_error = error^2)

  mae <- mean(errors$absolute_error, na.rm = TRUE)
  rmse <- mean(errors$square_error, na.rm = TRUE)

  hourly_metrics <- errors %>%
    mutate(hour = hour(validtime)) %>%
    group_by(hour) %>%
    summarise(mae = mean(absolute_error, na.rm = TRUE), rmse = sqrt(mean(square_error, na.rm = TRUE))) %>%
    ungroup()

  list(errors = errors,
       mae = mae,
       rmse = rmse,
       hourly_metrics = hourly_metrics)
}
