class SensorLog {
  final double ph;
  final double kelembapan;
  final double suhu;
  final double curahHujan;
  final double levelAir;
  final double angin;
  final DateTime timestamp;

  SensorLog({
    required this.ph,
    required this.kelembapan,
    required this.suhu,
    required this.curahHujan,
    required this.levelAir,
    required this.angin,
    required this.timestamp,
  });
  factory SensorLog.fromJson(Map<String, dynamic> json) {
    double safeDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        try {
          return double.parse(value);
        } catch (e) {
          print('Warning: Error converting to double: $e');
          return 0.0;
        }
      }
      return 0.0;
    }

    print('Converting JSON to HistorySensor: $json'); // Debug print

    // Handle both direct values and nested values
    var data = json;
    if (json.containsKey('sensor')) {
      data = json['sensor'] as Map<String, dynamic>;
    }

    return SensorLog(
      ph: safeDouble(data['ph'] ?? data['phTanah'] ?? data['ph_tanah']),
      kelembapan: safeDouble(
        data['kelembapan'] ??
            data['kelembapanTanah'] ??
            data['kelembapan_tanah'],
      ),
      suhu: safeDouble(data['suhu'] ?? data['suhuTanah'] ?? data['suhu_tanah']),
      curahHujan: safeDouble(data['curahHujan'] ?? data['curah_hujan']),
      levelAir: safeDouble(data['levelAir'] ?? data['level_air']),
      angin: safeDouble(
        data['angin'] ?? data['kecepatanAngin'] ?? data['kecepatan_angin'],
      ),
      timestamp:
          data['timestamp'] != null
              ? DateTime.parse(data['timestamp'].toString())
              : DateTime.now(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'ph': ph,
      'kelembapan': kelembapan,
      'suhu': suhu,
      'curahHujan': curahHujan,
      'levelAir': levelAir,
      'angin': angin,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
