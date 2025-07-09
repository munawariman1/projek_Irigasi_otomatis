// user_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'login_screen.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
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
        title: const Text('User Dashboard'),
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
            icon: const Icon(Icons.monitor),
            label: const Text("Monitoring Sensor"),
            onPressed: () {
              // TODO: navigasi ke halaman monitoring sensor
            },
          ),

          ElevatedButton.icon(
            icon: const Icon(Icons.water_drop),
            label: const Text("Kontrol Manual Irigasi"),
            onPressed: () {
              // TODO: navigasi ke halaman kontrol manual
            },
          ),

          ElevatedButton.icon(
            icon: const Icon(Icons.notifications_active),
            label: const Text("Notifikasi Kondisi Tanaman"),
            onPressed: () {
              // TODO: navigasi ke halaman notifikasi / alert
            },
          ),

          ElevatedButton.icon(
            icon: const Icon(Icons.bar_chart),
            label: const Text("Riwayat Prediksi"),
            onPressed: () {
              // TODO: navigasi ke halaman riwayat prediksi
            },
          ),
        ],
      ),
    );
  }
}
