import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sensor_data.dart';
import '../models/prediction_result.dart';

class FlaskService {
  static const String baseUrl =
      'https://41ce-180-241-46-158.ngrok-free.app'; // Ganti dengan URL Flask server

  Future<PredictionResult> predict(SensorData data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/predict'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'data': [
            data.kelembapan, // kelembapan_tanah
            data.suhu, // suhu_tanah
            data.ph, // ph_tanah
            data.curahHujan, // curah_hujan
            data.angin, // kecepatan_angin
            data.levelAir, // level_air
          ],
        }),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return PredictionResult(
          efisiensi: result['efisiensi'],
          durasiIrigasi: result['durasi_irigasi'],
          timestamp: DateTime.parse(result['timestamp'].replaceAll(' ', 'T')),
        );
      } else {
        throw Exception('Gagal mendapatkan prediksi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error saat melakukan prediksi: $e');
    }
  }
}
