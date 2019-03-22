import pandas as pd
from datetime import timedelta
import logging


class TestDataGenerator(object):

    def __init__(self, start_time='2018-08-20 08:00:00', end_time='2019-02-10 08:00:00',
                 test_data=None):
        """
        Initializer

        :param start_time: Earliest time to generate test  data
        :param end_time: Latest time to generate test daya
        :param test_data: A dictionary with keys ['load', 'gfs', 'nam'] and corresponding datatsets as
                          dataframes
        """
        self._start_time = start_time
        self._end_time = end_time
        self._runtimes = pd.date_range(start=self._start_time,
                                       end=self._end_time,
                                       freq='D', tz='UTC')
        self._steps = 0
        if test_data is not None:
            self._test_data = test_data
        else:
            logging.error("No test data provided.")

    def _filter_data(self, t, n_days=3, lag=30):
        """
        Filters load, GFS, and NAM datasets

        :param t: Current runtime
        :param n_days: Recency of latest available data
        :param lag: How far back to fetch data
        :return: A tuple comprising the filtered load, GFS, and NAM data
        """
        load = self._test_data['load']
        gfs = self._test_data['gfs']
        nam = self._test_data['nam']
        load = load[(load['validtime'] <= t - timedelta(days=n_days)) &
                    (load['validtime'] >= t - timedelta(days=n_days+lag))]
        gfs = gfs[(gfs['runtime'] <= t) & (gfs['runtime'] >= t - timedelta(days=lag))]
        nam = nam[(nam['runtime'] <= t) & (nam['runtime'] >= t - timedelta(days=lag))]
        return load, gfs, nam

    def next_runtime(self, lag=30):
        """
        :param lag: How far back (in days) to fetch data
        :return: Dictionary with runtime, load, and weather data going back lag days
        """
        if self._steps >= len(self._runtimes):
            logging.warning('No more data to fetch.')
            return None

        t = self._runtimes[self._steps]
        load, gfs, nam = self._filter_data(t, n_days=3, lag=lag)

        self._steps += 1
        return {'runtime': t,
                'data': {'load': load,
                         'gfs': gfs,
                         'nam': nam}}
