// // DEPRECATED: File ini sudah tidak digunakan lagi
// // Fitur notifikasi sekarang menggunakan AlertDialog dan AlertBadge di home_screen.dart
// // Lihat: lib/widgets/alert_dialog.dart dan lib/widgets/alert_badge.dart untuk implementasi baru

// import 'package:flutter/material.dart';
// import '../services/firebase_service.dart';
// import '../models/sensor_data.dart';

// class NotificationScreen extends StatelessWidget {
//   const NotificationScreen({super.key});

//   List<String> _getAbnormalSensors(SensorData data) {
//     final List<String> abnormalSensors = [];

//     if (data.ph < 5.5 || data.ph > 7.5) {
//       abnormalSensors.add('pH Tanah (${data.ph})');
//     }
//     if (data.kelembapan < 30) {
//       abnormalSensors.add('Kelembapan (${data.kelembapan}%)');
//     }
//     if (data.suhu < 20 || data.suhu > 32) {
//       abnormalSensors.add('Suhu (${data.suhu}°C)');
//     }
//     if (data.levelAir < 10) {
//       abnormalSensors.add('Level Air (${data.levelAir}cm)');
//     }

//     return abnormalSensors;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Notifikasi Sensor',
//           style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         elevation: 0,
//         foregroundColor: Colors.black87,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () {
//               // Trigger refresh
//               FirebaseService().getSensorDataStream();
//             },
//           ),
//         ],
//       ),
//       body: StreamBuilder<SensorData?>(
//         stream: FirebaseService().getSensorDataStream(),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }

//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (!snapshot.hasData || snapshot.data == null) {
//             return const Center(child: Text('Tidak ada data sensor'));
//           }

//           final abnormalSensors = _getAbnormalSensors(snapshot.data!);

//           if (abnormalSensors.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(24),
//                     decoration: BoxDecoration(
//                       color: Colors.green.withOpacity(0.1),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       Icons.check_circle_outline,
//                       size: 64,
//                       color: Theme.of(context).colorScheme.primary,
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       vertical: 12,
//                       horizontal: 24,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.green.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: const Text(
//                       'Semua sensor dalam kondisi normal',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.green,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }
//           return ListView.builder(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             itemCount: abnormalSensors.length,
//             itemBuilder: (context, index) {
//               return Container(
//                 margin: const EdgeInsets.only(bottom: 12),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [
//                       Colors.red.withOpacity(0.05),
//                       Colors.red.withOpacity(0.1),
//                     ],
//                   ),
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(
//                     color: Colors.red.withOpacity(0.2),
//                     width: 1,
//                   ),
//                 ),
//                 child: Material(
//                   color: Colors.transparent,
//                   child: InkWell(
//                     borderRadius: BorderRadius.circular(16),
//                     onTap: () {
//                       // Show detailed info if needed
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(12),
//                             decoration: BoxDecoration(
//                               color: Colors.red.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: const Icon(
//                               Icons.warning_amber_rounded,
//                               color: Colors.red,
//                               size: 24,
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Peringatan!',
//                                   style: TextStyle(
//                                     color: Colors.red[700],
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   'Sensor ${abnormalSensors[index]} dalam kondisi tidak normal',
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     color: Colors.grey[800],
//                                     height: 1.4,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           Icon(
//                             Icons.arrow_forward_ios,
//                             size: 16,
//                             color: Colors.grey[400],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
