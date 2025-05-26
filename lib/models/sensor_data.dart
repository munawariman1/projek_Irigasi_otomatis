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
        return rawList.map((e) => (e as num).toDouble()).toList();
      }
      return [];
    }

    return SensorData(
      ph: (json['phTanah'] ?? 0).toDouble(),
      kelembapan: (json['kelembapanTanah'] ?? 0).toDouble(),
      suhu: (json['suhuTanah'] ?? 0).toDouble(),
      curahHujan: (json['curahHujan'] ?? 0).toDouble(),
      levelAir: (json['levelAir'] ?? 0).toDouble(),
      angin: (json['kecepatanAngin'] ?? json['KecepatanAngin'] ?? 0).toDouble(),

      phHistory: safeList(json['phTanahHistory']),
      kelembapanHistory: safeList(json['kelembapanTanahHistory']),
      suhuHistory: safeList(json['suhuTanahHistory']),
      curahHujanHistory: safeList(json['curahHujanHistory']),
      levelAirHistory: safeList(json['levelAirHistory']),
      anginHistory: safeList(json['kecepatanAnginHistory']),
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
