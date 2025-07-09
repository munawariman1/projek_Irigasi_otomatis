// sensor_data.dart - model final SensorData
class SensorData {
  final double ph;
  final double kelembapan;
  final double suhu;
  final double curahHujan;
  final double levelAir;
  final double angin;
  final DateTime timestamp;
  final String? prediksi;

  SensorData({
    required this.ph,
    required this.kelembapan,
    required this.suhu,
    required this.curahHujan,
    required this.levelAir,
    required this.angin,
    DateTime? timestamp,
    this.prediksi,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      "phTanah": ph,
      "kelembapanTanah": kelembapan,
      "suhuTanah": suhu,
      "curahHujan": curahHujan,
      "levelAir": levelAir,
      "kecepatanAngin": angin,
      "timestamp": timestamp.toIso8601String(),
      "prediction": prediksi,
    };
  }

  factory SensorData.fromJson(Map<String, dynamic> json) {
    double safeDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        try {
          return double.parse(value);
        } catch (_) {
          return 0.0;
        }
      }
      return 0.0;
    }

    return SensorData(
      ph: safeDouble(json['phTanah'] ?? json['ph'] ?? 0),
      kelembapan: safeDouble(json['kelembapanTanah'] ?? json['kelembapan'] ?? 0),
      suhu: safeDouble(json['suhuTanah'] ?? json['suhu'] ?? 0),
      curahHujan: safeDouble(json['curahHujan'] ?? 0),
      levelAir: safeDouble(json['levelAir'] ?? 0),
      angin: safeDouble(json['kecepatanAngin'] ?? json['angin'] ?? 0),
      timestamp: json.containsKey('timestamp')
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      prediksi: json['prediction'] ?? json['prediksi'],
    );
  }
}
