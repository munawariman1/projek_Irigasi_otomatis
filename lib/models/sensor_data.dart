class SensorData {
  final double ph;
  final double moisture;
  final double temperature;
  final double rainfall;
  final double waterLevel;
  final double windSpeed;

  final List<double> phHistory;
  final List<double> moistureHistory;
  final List<double> temperatureHistory;
  final List<double> rainfallHistory;
  final List<double> waterLevelHistory;
  final List<double> windSpeedHistory;

  SensorData({
    required this.ph,
    required this.moisture,
    required this.temperature,
    required this.rainfall,
    required this.waterLevel,
    required this.windSpeed,
    required this.phHistory,
    required this.moistureHistory,
    required this.temperatureHistory,
    required this.rainfallHistory,
    required this.waterLevelHistory,
    required this.windSpeedHistory,
  });

  // factory SensorData.fromJson(Map<String, dynamic> json) {
  //   return SensorData(
  //     ph: (json['ph'] ?? 0).toDouble(),
  //     moisture: (json['moisture'] ?? 0).toDouble(),
  //     temperature: (json['temperature'] ?? 0).toDouble(),
  //     rainfall: (json['rainfall'] ?? 0).toDouble(),
  //     waterLevel: (json['waterLevel'] ?? 0).toDouble(),
  //     windSpeed: (json['windSpeed'] ?? 0).toDouble(),
  //     phHistory: List<double>.from((json['phHistory'] ?? []).map((e) => (e as num).toDouble())),
  //     moistureHistory: List<double>.from((json['moistureHistory'] ?? []).map((e) => (e as num).toDouble())),
  //     temperatureHistory: List<double>.from((json['temperatureHistory'] ?? []).map((e) => (e as num).toDouble())),
  //     rainfallHistory: List<double>.from((json['rainfallHistory'] ?? []).map((e) => (e as num).toDouble())),
  //     waterLevelHistory: List<double>.from((json['waterLevelHistory'] ?? []).map((e) => (e as num).toDouble())),
  //     windSpeedHistory: List<double>.from((json['windSpeedHistory'] ?? []).map((e) => (e as num).toDouble())),
  //   );
  // }
  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      ph: (json['ph'] ?? 0).toDouble(),
      moisture: (json['moisture'] ?? 0).toDouble(),
      temperature: (json['temperature'] ?? 0).toDouble(),
      rainfall: (json['rainfall'] ?? 0).toDouble(),
      waterLevel: (json['waterLevel'] ?? 0).toDouble(),
      windSpeed: (json['windSpeed'] ?? 0).toDouble(),
      phHistory: List<double>.from(
        (json['phHistory'] ?? []).map((e) => e.toDouble()),
      ),
      moistureHistory: List<double>.from(
        (json['moistureHistory'] ?? []).map((e) => e.toDouble()),
      ),
      temperatureHistory: List<double>.from(
        (json['temperatureHistory'] ?? []).map((e) => e.toDouble()),
      ),
      rainfallHistory: List<double>.from(
        (json['rainfallHistory'] ?? []).map((e) => e.toDouble()),
      ),
      waterLevelHistory: List<double>.from(
        (json['waterLevelHistory'] ?? []).map((e) => e.toDouble()),
      ),
      windSpeedHistory: List<double>.from(
        (json['windSpeedHistory'] ?? []).map((e) => e.toDouble()),
      ),
    );
  }
}
