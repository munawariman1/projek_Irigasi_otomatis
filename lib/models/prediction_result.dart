class PredictionResult {
  final String prediction;
  final double? probabilitas;
  final int? durasiPenyiraman;
  final String? timestamp;
  final double? processingTime;

  PredictionResult({
    required this.prediction,
    this.probabilitas,
    this.durasiPenyiraman,
    this.timestamp,
    this.processingTime,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      prediction: json['prediction'],
      probabilitas: (json['probabilitas'] as num?)?.toDouble(),
      durasiPenyiraman: json['durasi_penyiraman'] as int?,
      timestamp: json['timestamp'] as String?,
      processingTime: (json['processing_time'] as num?)?.toDouble(),
    );
  }
}
