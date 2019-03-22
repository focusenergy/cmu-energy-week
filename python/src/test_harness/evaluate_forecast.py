import numpy as np


def evaluate_forecast(forecast_load, actual_load):
    """
    Computes forecast error metrics

    :param forecast_load: The forecasted load; has columns ['runtime', 'validtime','prediction']
    :param actual_load: The actual load; has columns ['validtime', 'target_load']
    :return: A dictionary with keys ['errors', 'mae', 'rmse', 'hourly_metrics']
    """
    errors = forecast_load.merge(actual_load, how='left', on='validtime')
    errors.dropna(inplace=True)
    errors = errors.assign(error=errors['prediction'] - errors['target_load'])
    errors = errors.assign(absolute_error=errors['error'].apply(lambda x: np.abs(x)))
    errors = errors.assign(square_error=errors['error'].apply(lambda x: np.power(x, 2)))

    # Overall metrics
    mae = np.mean(errors['absolute_error'].values)
    rmse = np.sqrt(np.mean(errors['square_error'].values))

    # Hourly metrics
    hourly_metrics = errors.copy()
    hourly_metrics = hourly_metrics.assign(hour=hourly_metrics['validtime'].apply(lambda x: x.hour))
    hourly_metrics = hourly_metrics.loc[:, ['hour', 'absolute_error', 'square_error']]
    hourly_metrics = hourly_metrics.groupby(['hour'], as_index=False).mean().reset_index()
    hourly_metrics = hourly_metrics.assign(mae=hourly_metrics['absolute_error'])
    hourly_metrics = hourly_metrics.assign(rmse=hourly_metrics['absolute_error'].apply(lambda x: np.sqrt(x)))
    hourly_metrics = hourly_metrics.loc[:, ['hour', 'mae', 'rmse']]
    return {'errors': errors, 'mae': mae, 'rmse': rmse, 'hourly_metrics': hourly_metrics}
