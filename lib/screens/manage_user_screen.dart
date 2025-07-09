// manage_users_screen.dart - Admin: kelola pengguna lengkap
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final DatabaseReference usersRef = FirebaseDatabase.instance.ref('users');
  final TextEditingController emailController = TextEditingController();
  String selectedRole = 'user';
  List<Map<String, dynamic>> userList = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() async {
    final snapshot = await usersRef.get();
    final data = snapshot.value as Map<dynamic, dynamic>?;
    if (data != null) {
      final loaded = data.entries.map((e) {
        final uid = e.key;
        final value = Map<String, dynamic>.from(e.value);
        return {"uid": uid, ...value};
      }).toList();
      setState(() {
        userList = loaded;
      });
    }
  }

  void _addUser() async {
    final email = emailController.text.trim();
    if (email.isEmpty) return;
    final newRef = usersRef.push();
    await newRef.set({
      "email": email,
      "role": selectedRole,
    });
    emailController.clear();
    setState(() => selectedRole = 'user');
    _loadUsers();
  }

  void _changeRole(String uid, String newRole) async {
    await usersRef.child(uid).update({"role": newRole});
    _loadUsers();
  }

  void _deleteUser(String uid) async {
    await usersRef.child(uid).remove();
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Pengguna')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email Pengguna Baru',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: selectedRole,
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    DropdownMenuItem(value: 'user', child: Text('User')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedRole = value);
                    }
                  },
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addUser,
                  child: const Text('Tambah'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: userList.isEmpty
                  ? const Center(child: Text('Belum ada pengguna'))
                  : ListView.builder(
                      itemCount: userList.length,
                      itemBuilder: (context, index) {
                        final user = userList[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(user['email'] ?? '-'),
                            subtitle: Text('Role: ${user['role'] ?? '-'}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                DropdownButton<String>(
                                  value: user['role'],
                                  items: const [
                                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                                    DropdownMenuItem(value: 'user', child: Text('User')),
                                  ],
                                  onChanged: (value) {
                                    if (value != null && value != user['role']) {
                                      _changeRole(user['uid'], value);
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteUser(user['uid']),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
