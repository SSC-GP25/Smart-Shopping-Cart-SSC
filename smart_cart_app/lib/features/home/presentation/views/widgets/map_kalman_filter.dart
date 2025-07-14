class KalmanFilter {
  double _lastEstimate;
  double _errorEstimate;
  final double _errorMeasure;
  final double _q; // process noise

  KalmanFilter({
    required double initialValue,
    double errorEstimate = 1.0,
    double errorMeasure = 1.0,
    double q = 0.01,
  })  : _lastEstimate = initialValue,
        _errorEstimate = errorEstimate,
        _errorMeasure = errorMeasure,
        _q = q;

  double filter(double measurement) {
    // Prediction update
    _errorEstimate += _q;

    // Measurement update
    final kalmanGain = _errorEstimate / (_errorEstimate + _errorMeasure);
    _lastEstimate += kalmanGain * (measurement - _lastEstimate);
    _errorEstimate *= (1 - kalmanGain);

    return _lastEstimate;
  }

  void reset(double value) {
    _lastEstimate = value;
  }
}
