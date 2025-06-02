class SensorData {
  final double ph;
  final double kelembapan;
  final double suhu;
  final double curahHujan;
  final double levelAir;
  final double angin;
  final DateTime timestamp;
  final List<double> phHistory;
  final List<double> kelembapanHistory;
  final List<double> suhuHistory;
  final List<double> curahHujanHistory;
  final List<double> levelAirHistory;
  final List<double> anginHistory;

  SensorData({
    required this.ph,
    required this.kelembapan,
    required this.suhu,
    required this.curahHujan,
    required this.levelAir,
    required this.angin,
    DateTime? timestamp,
    List<double>? phHistory,
    List<double>? kelembapanHistory,
    List<double>? suhuHistory,
    List<double>? curahHujanHistory,
    List<double>? levelAirHistory,
    List<double>? anginHistory,
  }) : this.timestamp = timestamp ?? DateTime.now(),
       this.phHistory = phHistory ?? [],
       this.kelembapanHistory = kelembapanHistory ?? [],
       this.suhuHistory = suhuHistory ?? [],
       this.curahHujanHistory = curahHujanHistory ?? [],
       this.levelAirHistory = levelAirHistory ?? [],
       this.anginHistory = anginHistory ?? [];

  Map<String, dynamic> toJson() {
    return {
      "phTanah": ph,
      "kelembapanTanah": kelembapan,
      "suhuTanah": suhu,
      "curahHujan": curahHujan,
      "levelAir": levelAir,
      "kecepatanAngin": angin,
      "timestamp": timestamp.toIso8601String(),
      "phTanahHistory": phHistory,
      "kelembapanTanahHistory": kelembapanHistory,
      "suhuTanahHistory": suhuHistory,
      "curahHujanHistory": curahHujanHistory,
      "levelAirHistory": levelAirHistory,
      "kecepatanAnginHistory": anginHistory,
    };
  }

  factory SensorData.fromJson(Map<String, dynamic> json) {
    List<double> safeList(dynamic rawList) {
      if (rawList is List) {
        try {
          return rawList
              .map((e) => (e == null) ? 0.0 : (e as num).toDouble())
              .toList();
        } catch (e) {
          print('Warning: Error converting list: $e');
          return [];
        }
      }
      return [];
    }

    double safeDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        try {
          return double.parse(value);
        } catch (e) {
          print('Warning: Error converting string to double: $e');
          return 0.0;
        }
      }
      return 0.0;
    }

    return SensorData(
      ph: safeDouble(json['phTanah'] ?? json['ph'] ?? 0),
      kelembapan: safeDouble(
        json['kelembapanTanah'] ?? json['kelembapan'] ?? 0,
      ),
      suhu: safeDouble(json['suhuTanah'] ?? json['suhu'] ?? 0),
      curahHujan: safeDouble(json['curahHujan'] ?? 0),
      levelAir: safeDouble(json['levelAir'] ?? 0),
      angin: safeDouble(json['kecepatanAngin'] ?? json['angin'] ?? 0),
      timestamp:
          json.containsKey('timestamp')
              ? DateTime.parse(json['timestamp'] as String)
              : DateTime.now(),
      phHistory: safeList(json['phTanahHistory'] ?? json['phHistory'] ?? []),
      kelembapanHistory: safeList(
        json['kelembapanTanahHistory'] ?? json['kelembapanHistory'] ?? [],
      ),
      suhuHistory: safeList(
        json['suhuTanahHistory'] ?? json['suhuHistory'] ?? [],
      ),
      curahHujanHistory: safeList(json['curahHujanHistory'] ?? []),
      levelAirHistory: safeList(json['levelAirHistory'] ?? []),
      anginHistory: safeList(
        json['kecepatanAnginHistory'] ?? json['anginHistory'] ?? [],
      ),
    );
  }
}
