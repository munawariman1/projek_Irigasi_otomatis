import 'package:firebase_database/firebase_database.dart';
import '../models/sensor_data.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  final DatabaseReference _rootRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://projek-irigasi-skripsi-default-rtdb.asia-southeast1.firebasedatabase.app',
  ).ref();

  /// ✅ Ambil data dari /sensors
  Stream<SensorData?> getSensorDataStream() {
    print('🔎 Listening to path: /sensors');
    return _rootRef.child('sensors').onValue.map((event) {
      final raw = event.snapshot.value;

      print('📦 Raw Firebase data: $raw');

      if (raw == null) {
        print('⚠️ Data NULL');
        return null;
      }

      if (raw is! Map) {
        print('❌ Format data bukan Map: ${raw.runtimeType}');
        return null;
      }

      try {
        final data = Map<String, dynamic>.from(raw as Map);
        print('✅ Data parsed successfully');
        return SensorData.fromJson(data);
      } catch (e) {
        print('❌ Error parsing data: $e');
        return null;
      }
    }).handleError((error) {
      print('‼️ Stream ERROR: $error');
      return null;
    });
  }

  /// 💾 Simpan data ke /history_sensor dengan timestamp
  Future<void> simpanHistorySensor(SensorData data) async {
    final now = DateTime.now().toIso8601String();
    final historyData = {
      ...data.toJson(),
      "timestamp": now,
    };

    await _rootRef.child('history_sensor').push().set(historyData);
    print("✅ History sensor disimpan");
  }

  /// 💾 Simpan hasil prediksi ke /history_prediksi
  Future<void> simpanHistoryPrediksi(
    SensorData data,
    String efisiensi,
    int durasi,
  ) async {
    final now = DateTime.now().toIso8601String();
    final prediksiData = {
      ...data.toJson(),
      "efisiensi": efisiensi,
      "irigasiWaktu": durasi,
      "waktu": now,
    };

    await _rootRef.child('history_prediksi').push().set(prediksiData);
    print("✅ History prediksi disimpan");
  }
}
