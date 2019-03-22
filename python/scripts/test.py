from test_harness import test_data_generator
from datetime import timedelta
import pandas as pd
import logging
from test_harness import utils, evaluate_forecast


def run(predict_fun, test_data):

    test_data_gen = test_data_generator.TestDataGenerator(test_data=test_data)
    results = pd.DataFrame()

    while True:
        d = test_data_gen.next_runtime(lag=5)

        if d is not None:
            runtime = d['runtime']
            logging.info('Runtime: {}'.format(runtime))

            load = d['data']['load']
            forecast = predict_fun(runtime, load)
            results = results.append(forecast, ignore_index=True)
        else:
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
    test_data = utils.simulate_dataset()
    results = run(persistence, test_data)
    evaluation_metrics = evaluate_forecast.evaluate_forecast(results, test_data['load'])
    results.to_csv('results.csv', index=False)
    evaluation_metrics['hourly_metrics'].to_csv('hourly_error_metrics.csv', index=False)

