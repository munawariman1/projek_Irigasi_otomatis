class PredictionResult {
  final String efisiensi;
  final int durasiIrigasi;
  final DateTime timestamp;

  PredictionResult({
    required this.efisiensi,
    required this.durasiIrigasi,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'efisiensi': efisiensi,
    'durasi_irigasi': durasiIrigasi,
    'timestamp': timestamp.toIso8601String(),
  };

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      efisiensi: json['efisiensi']?.toString() ?? 'Unknown',
      durasiIrigasi: (json['durasi_irigasi'] as num?)?.toInt() ?? 0,
      timestamp:
          json.containsKey('timestamp')
              ? DateTime.parse(json['timestamp'] as String)
              : DateTime.now(),
    );
  }
}
