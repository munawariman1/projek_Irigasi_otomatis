import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sensor_data.dart';
import '../models/prediction_result.dart';

class FlaskService {
  static const String baseUrl =
      'YOUR_FLASK_SERVER_URL'; // Ganti dengan URL Flask server

  Future<PredictionResult> predict(SensorData data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/predict'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'ph': data.ph,
          'kelembapan': data.kelembapan,
          'suhu': data.suhu,
          'curahHujan': data.curahHujan,
          'levelAir': data.levelAir,
          'angin': data.angin,
        }),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return PredictionResult(
          efisiensi: result['efisiensi'],
          durasiIrigasi: result['durasi_irigasi'],
        );
      } else {
        throw Exception('Gagal mendapatkan prediksi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error saat melakukan prediksi: $e');
    }
  }
}
