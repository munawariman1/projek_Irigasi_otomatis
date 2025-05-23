import 'package:firebase_database/firebase_database.dart';
import '../models/sensor_data.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  // final DatabaseReference _sensorRef = FirebaseDatabase.instance.ref().child(
  //   'sensors',
  // );
  final DatabaseReference _sensorRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://projek-irigasi-skripsi-default-rtdb.asia-southeast1.firebasedatabase.app',
  ).ref('sensors');

  Stream<SensorData?> getSensorDataStream() {
    print('🔎 Listening to path: /sensors');
    return _sensorRef.onValue
        .map((event) {
          print('📦 Raw Firebase data: ${event.snapshot.value}');

          if (event.snapshot.value == null) {
            print('⚠️ Data is NULL at path: /sensors');
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
        })
        .handleError((error) {
          print('‼️ Stream ERROR: $error');
          return null;
        });
  }
}
