import 'package:firebase_database/firebase_database.dart';
import '../models/sensor_data.dart';
import 'package:firebase_core/firebase_core.dart';

class PredictionResult {
  final String efisiensi;
  final int durasiIrigasi;

  PredictionResult({
    required this.efisiensi,
    required this.durasiIrigasi,
  });

  Map<String, dynamic> toJson() => {
        'efisiensi': efisiensi,
        'durasiIrigasi': durasiIrigasi,
      };
}

class FirebaseService {
  final DatabaseReference _sensorRef =
      FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL:
            'https://projek-irigasi-skripsi-default-rtdb.asia-southeast1.firebasedatabase.app',
      ).ref();

  Stream<SensorData?> getSensorDataStream() {
    print('🔎 Listening to path: /sensors');
    return _sensorRef.child('sensors').onValue.map((event) {
      print('📦 Raw Firebase data: ${event.snapshot.value}');

      if (event.snapshot.value is! Map) {
        print(
          '⚠️ Data format bukan Map, tapi ${event.snapshot.value.runtimeType}',
        );
        return null;
      }

      try {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        print('✅ Data parsed successfully');
        return SensorData.fromJson(data);
      } catch (e) {
        print('❌ Error parsing data: $e');
        return null;
      }
    });
  }

  Future<void> simpanHistorySensor(SensorData data) async {
    await FirebaseDatabase.instance
        .ref('history_sensor')
        .push()
        .set(data.toJson());
  }

  Future<void> simpanHistoryPrediksi(
    SensorData data,
    String efisiensi,
    int durasi,
  ) async {
    final now = DateTime.now().toIso8601String();
    await FirebaseDatabase.instance.ref('history_prediksi').push().set({
      ...data.toJson(),
      "efisiensi": efisiensi,
      "irigasiWaktu": durasi,
      "waktu": now,
    });
  }

  Future<void> togglePump(bool status) async {
    try {
      await FirebaseDatabase.instance
          .ref('sensor')
          .update({'pumpStatus': status});
    } catch (e) {
      throw Exception('Gagal mengubah status pompa: $e');
    }
  }
}
// class FirebaseService {
//   // final DatabaseReference _sensorRef = FirebaseDatabase.instance.ref().child(
//   //   'sensors',
//   // );
//   final DatabaseReference _sensorRef = FirebaseDatabase.instanceFor(
//     app: Firebase.app(),
//     databaseURL:
//         'https://projek-irigasi-skripsi-default-rtdb.asia-southeast1.firebasedatabase.app',
//   ).ref('sensors');

//   // Stream<SensorData?> getSensorStream() {
//   //   return _sensorRef.child('sensors').onValue.map((event) {
//   //     final data = event.snapshot.value;
//   //     if (data != null && data is Map) {
//   //       return SensorData.fromJson(Map<String, dynamic>.from(data));
//   //     }
//   //     return null;
//   //   });
//   // }


//   Stream<SensorData?> getSensorDataStream() {
//     print('🔎 Listening to path: /sensors');
//   return _sensorRef.onValue.map((event) {
//     print('📦 Raw Firebase data: ${event.snapshot.value}');

//     if (event.snapshot.value == null) {
//       print('⚠️ Data is NULL at path: /sensors');
//       return null;
//     }

//     try {
//       final data = Map<String, dynamic>.from(event.snapshot.value as Map);
//       print('✅ Data parsed successfully');
//       return SensorData.fromJson(data);
//     } catch (e) {
//       print('❌ Error parsing data: $e');
//       return null;
//     }
//   }).handleError((error) {
//     print('‼️ Stream ERROR: $error');
//     return null;
//   });
// }
  
//  Future<void> simpanHistorySensor(SensorData data) async {
//     await _sensorRef.child('history_sensor').push().set(data.toJson());
//   }

//   Future<void> simpanHistoryPrediksi(SensorData data, String efisiensi, int durasi) async {
//     final now = DateTime.now().toIso8601String();
//     await _sensorRef.child('history_prediksi').push().set({
//       ...data.toJson(),
//       "efisiensi": efisiensi,
//       "irigasiWaktu": durasi,
//       "waktu": now,
//     });
//   }
// }

