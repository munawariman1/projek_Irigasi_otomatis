import 'package:firebase_database/firebase_database.dart';
import '../models/sensor_data.dart';
import '../models/prediction_result.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final DatabaseReference _rootRef = FirebaseDatabase.instance.ref();

  // Stream untuk data sensor realtime
  Stream<SensorData?> getSensorDataStream() {
    return _rootRef.child('sensors').onValue.map((event) {
      if (event.snapshot.value == null) return null;
      try {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        return SensorData.fromJson(data);
      } catch (e) {
        print('Error parsing sensor data: $e');
        return null;
      }
    });
  }

  // Menyimpan data sensor ke history
  Future<void> saveHistorySensor(SensorData data) async {
    final historyData = {
      'ph': data.ph,
      'kelembapan': data.kelembapan,
      'suhu': data.suhu,
      'curahHujan': data.curahHujan,
      'levelAir': data.levelAir,
      'angin': data.angin,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await _rootRef.child('history_sensor').push().set(historyData);
  }

  // Menyimpan hasil prediksi
  Future<void> saveHistoryPrediction(
    SensorData data,
    PredictionResult prediction,
  ) async {
    final prediksiData = {
      'sensor': data.toJson(),
      'hasil': prediction.toJson(),
      'timestamp': DateTime.now().toIso8601String(),
    };
    await _rootRef.child('history_prediksi').push().set(prediksiData);
  }

  // Stream untuk history sensor
  Stream<List<SensorData>> getHistorySensorStream() {
    return _rootRef.child('history_sensor').limitToLast(100).onValue.map((
      event,
    ) {
      if (event.snapshot.value == null) return [];
      try {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        return data.values
            .map((e) => SensorData.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } catch (e) {
        print('Error parsing history sensor: $e');
        return [];
      }
    });
  }

  // Stream untuk history prediksi
  Stream<List<PredictionResult>> getHistoryPredictionStream() {
    return _rootRef.child('history_prediksi').limitToLast(100).onValue.map((
      event,
    ) {
      if (event.snapshot.value == null) return [];
      try {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        return data.values
            .map((e) => PredictionResult.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } catch (e) {
        print('Error parsing history prediction: $e');
        return [];
      }
    });
  }
}
