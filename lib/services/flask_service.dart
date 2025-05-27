import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sensor_data.dart';
import '../models/prediction_result.dart';

class FlaskService {
  final String baseUrl =
      "http://127.0.0.1:5000"; // Ganti IP sesuai Flask server

  Future<PredictionResult> predict(SensorData data) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/predict"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data.toJson()),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return PredictionResult.fromJson(json);
      } else {
        throw Exception("Gagal prediksi: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error koneksi ke server: $e");
    }
  }
}
