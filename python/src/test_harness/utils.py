import pandas as pd
import numpy as np
from datetime import timedelta


def simulate_dataset():
    np.random.seed(1)
    validtime = pd.date_range(start='2018-08-01 00:00:00',
                              end='2018-08-25 00:00:00',
                              freq='H', tz='UTC')
    runtime = pd.date_range(start='2018-08-01 08:00:00',
                              end='2018-08-25 08:00:00',
                              freq='D', tz='UTC')
    load = pd.DataFrame({'validtime': validtime,
                         'target_load': 50 + 10*np.random.rand(len(validtime))})
    load['target_load'] = load['validtime'].apply(lambda x: 20*np.cos(2*np.pi*x.hour/24)) + load['target_load']

    gfs = pd.DataFrame()
    nam = gfs
    horizon = 24

    for t in runtime:
        v = [t + timedelta(hours=h) for h in range(horizon)]
        gfs_data = pd.DataFrame({'runtime': t,
                                 'validtime': v,
                                 'Temp.1': 30 + 10*np.random.rand(horizon),
                                 'Temp.2': 30 + 10*np.random.rand(horizon),
                                 'Relative_humidity.1': 50 + np.random.rand(horizon),
                                 'Relative_humidity.2': 50 + np.random.rand(horizon)})
        nam_data = pd.DataFrame({'runtime': t,
                                 'validtime': v,
                                 'Temp.1': 30 + 10*np.random.rand(horizon),
                                 'Temp.2': 30 + 10*np.random.rand(horizon),
                                 'DewPoint.1': 50 + np.random.rand(horizon),
                                 'DewPoint.2': 50 + np.random.rand(horizon)})
        gfs = gfs.append(gfs_data, ignore_index=True)
        nam = nam.append(nam_data, ignore_index=True)

    return {'load': load, 'gfs': gfs, 'nam': nam}
