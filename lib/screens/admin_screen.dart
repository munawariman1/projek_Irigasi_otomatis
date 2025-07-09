// admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:projek_irigasi_otomatis/screens/download_laporan.dart';
import 'package:projek_irigasi_otomatis/screens/edit_sensor_screen.dart';
import 'package:projek_irigasi_otomatis/screens/history_prediksi_screen.dart';
import 'package:projek_irigasi_otomatis/screens/login_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:projek_irigasi_otomatis/screens/manage_user_screen.dart';


class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String email = "-";

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        email = user.email ?? "-";
      });
    }
  }

 void _logout() async {
  await FirebaseAuth.instance.signOut();
  await GoogleSignIn().signOut(); // Hapus sesi Google
  if (mounted) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text("👤 Logged in as: $email",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          ElevatedButton.icon(
            icon: const Icon(Icons.supervisor_account),
            label: const Text("Kelola Pengguna"),
            onPressed: () {
               Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const ManageUsersScreen()),
  );
            },
          ),

          ElevatedButton.icon(
            icon: const Icon(Icons.analytics),
            label: const Text("Lihat Riwayat Sensor & Prediksi"),
            onPressed: () {
              Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const HistoryPrediksiScreen()),
  ); 
            },
          ),

          ElevatedButton.icon(
            icon: const Icon(Icons.download),
            label: const Text("Unduh Laporan"),
            onPressed: () {
              Navigator.push(
              context,
              MaterialPageRoute(builder: (_)=> const ExportLaporanScreen()), 
              );
            },
          ),

          ElevatedButton.icon(
            icon: const Icon(Icons.settings),
            label: const Text("Ubah Nilai Sensor (Simulasi)"),
            onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_)=> const EditSensorScreen()), 
              );  // TODO: navigasi ke halaman edit sensor
            },
          ),
        ],
      ),
    );
  }
}
