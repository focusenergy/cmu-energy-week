import pandas as pd
from datetime import timedelta
import logging
from pkg_resources import resource_filename
import gzip
import pickle

TEST_DATA_FILE = resource_filename('test_harness', 'test_data.pklz')


class TestDataGenerator(object):

    def __init__(self):
        self._start_time = '2018-08-20 08:00:00'
        self._end_time = '2019-02-10 08:00:00'
        self._runtimes = pd.date_range(start=self._start_time,
                                       end=self._end_time,
                                       freq='D', tz='UTC')
        self._steps = 0
        file_handle = gzip.open(TEST_DATA_FILE, 'rb')
        self._test_data = pickle.load(file_handle)
        file_handle.close()

    def _filter_data(self, t, k='load_1', n_days=3, lag=30):
        load = self._test_data[k]['load']
        gfs = self._test_data[k]['gfs']
        nam = self._test_data[k]['nam']
        load = load[(load['validtime'] <= t - timedelta(days=n_days)) &
                    (load['validtime'] >= t - timedelta(days=n_days+lag))]
        gfs = gfs[(gfs['runtime'] <= t) & (gfs['runtime'] >= t - timedelta(days=lag))]
        nam = nam[(nam['runtime'] <= t) & (nam['runtime'] >= t - timedelta(days=lag))]
        return load, gfs, nam

    def next_runtime(self, lag=30):
        """
        :param lag: History length in days for which to fetch data
        :return: Dictionary with runtime, load, and weather data going back lag days
        """
        if self._steps >= len(self._runtimes):
            logging.warning('No more data to fetch.')
            return None

        t = self._runtimes[self._steps]
        load_1_load, load_1_gfs, load_1_nam = self._filter_data(t, k='load_1', n_days=3, lag=lag)
        load_12_load, load_12_gfs, load_12_nam = self._filter_data(t, k='load_12', n_days=3, lag=lag)
        load_51_load, load_51_gfs, load_51_nam = self._filter_data(t, k='load_51', n_days=3, lag=lag)

        self._steps += 1
        return {'runtime': t,
                'data': {'load_1': {'load': load_1_load, 'gfs': load_1_gfs, 'nam': load_1_nam},
                         'load_12': {'load': load_12_load, 'gfs': load_12_gfs, 'nam': load_12_nam},
                         'load_51': {'load': load_51_load, 'gfs': load_51_gfs, 'nam': load_51_nam}}}
