class PredictionResult {
  final String efisiensi;
  final int durasiIrigasi;

  PredictionResult({required this.efisiensi, required this.durasiIrigasi});

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      efisiensi: json['efisiensi']?.toString() ?? 'Unknown',
      durasiIrigasi: (json['durasi_irigasi'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'efisiensi': efisiensi, 'durasi_irigasi': durasiIrigasi};
  }
}
