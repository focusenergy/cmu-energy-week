from test_harness import test_data_generator
from datetime import timedelta
import pandas as pd
import logging


def run(model=None):
    test_data_gen = test_data_generator.TestDataGenerator()
    done = False
    results = None

    while not done:
        d = test_data_gen.next_runtime(lag=5)

        if d is not None:
            runtime = d['runtime']
            logging.info('Runtime: {}'.format(runtime))

            load_1 = d['data']['load_1']['load']
            forecast = persistence(runtime, load_1)

            if results is None:
                results = forecast
            else:
                results = results.append(forecast, ignore_index=True)
        else:
            done = True
            return results
    return results


def persistence(runtime, load, horizon=24):
    validtime = [runtime + timedelta(hours=h) for h in range(horizon)]
    load = load.assign(hour=load['validtime'].apply(lambda x: x.hour).values)
    load = load.loc[load.groupby('hour')['validtime'].idxmax()]
    load = load.loc[:, ['hour', 'target_load']]

    forecast = pd.DataFrame({'runtime': runtime,
                             'validtime': validtime})
    forecast = forecast.assign(hour=forecast['validtime'].apply(lambda x: x.hour).values)
    forecast = forecast.merge(load, how='left', on='hour')
    forecast = forecast.assign(prediction=forecast['target_load'].values)
    return forecast.loc[:, ['runtime', 'validtime', 'prediction']]


if __name__ == '__main__':
    results = run()
    print(results.head(20))
