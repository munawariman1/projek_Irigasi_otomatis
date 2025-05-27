class SensorData {
  final double kelembapan;
  final double suhu;
  final double ph;
  final double curahHujan;
  final double angin;
  final double levelAir;

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
    required this.phHistory,
    required this.kelembapanHistory,
    required this.suhuHistory,
    required this.curahHujanHistory,
    required this.levelAirHistory,
    required this.anginHistory,
  });

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
      ph: safeDouble(json['ph'] ?? json['phTanah'] ?? 0),
      kelembapan: safeDouble(
        json['kelembapan'] ?? json['kelembapanTanah'] ?? 0,
      ),
      suhu: safeDouble(json['suhu'] ?? json['suhuTanah'] ?? 0),
      curahHujan: safeDouble(json['curahHujan'] ?? 0),
      levelAir: safeDouble(json['levelAir'] ?? 0),
      angin: safeDouble(json['angin'] ?? json['kecepatanAngin'] ?? 0),
      phHistory: safeList(json['phHistory'] ?? json['phTanahHistory'] ?? []),
      kelembapanHistory: safeList(
        json['kelembapanHistory'] ?? json['kelembapanTanahHistory'] ?? [],
      ),
      suhuHistory: safeList(
        json['suhuHistory'] ?? json['suhuTanahHistory'] ?? [],
      ),
      curahHujanHistory: safeList(json['curahHujanHistory'] ?? []),
      levelAirHistory: safeList(json['levelAirHistory'] ?? []),
      anginHistory: safeList(
        json['anginHistory'] ?? json['kecepatanAnginHistory'] ?? [],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "phTanah": ph,
      "kelembapanTanah": kelembapan,
      "suhuTanah": suhu,
      "curahHujan": curahHujan,
      "levelAir": levelAir,
      "kecepatanAngin": angin,
      "phTanahHistory": phHistory,
      "kelembapanTanahHistory": kelembapanHistory,
      "suhuTanahHistory": suhuHistory,
      "curahHujanHistory": curahHujanHistory,
      "levelAirHistory": levelAirHistory,
      "kecepatanAnginHistory": anginHistory,
    };
  }
}
