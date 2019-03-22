#' Simulates a dataset for a single load
#'
#' @importFrom dplyr bind_rows
#' @export
simulate_dataset <- function() {
  validtime <- seq(from=ymd_hms('2018-08-01 00:00:00', tz='UTC'),
                   to= ymd_hms('2018-08-25 00:00:00', tz='UTC'),
                   by=as.difftime(1, units='hours'))
  runtime <- seq(from=ymd_hms('2018-08-01 08:00:00', tz='UTC'),
                 to= ymd_hms('2018-08-25 08:00:00', tz='UTC'),
                 by=as.difftime(1, units='days'))

  target_load <- 50 + 20*cos(2*pi*hour(validtime)/24) + 10*runif(length(validtime))
  load <- data.frame(validtime=validtime,
                     target_load=target_load)

  gfs <- data.frame()
  nam <- gfs
  horizon <- 24

  for (t in runtime) {
    v <- t + as.difftime(seq_len(horizon)-1, units = 'hours')
    gfs_data <- data.frame(runtime = t, validtime = v)
    nam_data <- gfs_data

    gfs_data %<>% mutate(Temp.1 = 30 + 10*runif(horizon),
                         Temp.2 = Temp.1,
                         Relative_humidity.1 = 50 + runif(horizon),
                         Relative_humidity.2 = Relative_humidity.1)
    nam_data %<>% mutate(Temp.1 = 30 + 10*runif(horizon),
                         Temp.2 = Temp.1,
                         DewPoint.1 = 50 + runif(horizon),
                         DewPoint.2 = DewPoint.1)
    gfs %<>% bind_rows(gfs_data)
    nam %<>% bind_rows(nam_data)
  }

  list(load = load, gfs = gfs, nam = nam)
}
