// login_screen.dart - login Google dan deteksi email admin/user
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:projek_irigasi_otomatis/screens/admin_screen.dart';
import 'package:projek_irigasi_otomatis/screens/home_screen.dart';
import 'user_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;
  String? errorMessage;

  Future<void> loginWithGoogle() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        setState(() => isLoading = false);
        return; // Login dibatalkan
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;
      final uid = user!.uid;
      final email = user.email ?? "";

      String role;
      if (email == "munawariman21@gmail.com") {
        role = "admin";
      } else if (email == "uin210403@gmail.com") {
        role = "user";
      } else {
        // Email tidak dikenali
        await FirebaseAuth.instance.signOut();
        await GoogleSignIn().signOut();
        setState(() {
          errorMessage = "Akun tidak terdaftar dalam sistem.";
        });
        return;
      }

      // Simpan role & email ke Firebase Realtime Database
      await FirebaseDatabase.instance.ref("users/$uid").update({
        "email": email,
        "role": role,
      });

      if (!mounted) return;

      if (role == "admin") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Irigasi Kopi')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Masuk dengan Akun Google', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              if (errorMessage != null)
                Text(errorMessage!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: isLoading ? null : loginWithGoogle,
                icon: const Icon(Icons.login),
                label: isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Login dengan Google'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
