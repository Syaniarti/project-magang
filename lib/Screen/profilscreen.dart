import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'homescreen.dart';
import 'qrscanscreen.dart';
import 'editprofilescreen.dart';
import 'loginscreen.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  int _selectedIndex = 2;

  // Informasi user
  String nama = '';
  String nip = '';
  String jabatan = '';
  String email = '';
  String noTelp = '';
  String role = '';

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return;

    final response = await http.get(
      Uri.parse(
        'http://127.0.0.1:8000/api/profile',
      ), // GANTI IP SESUAI JARINGAN
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      print('JSON Data: $jsonData');

      final user = jsonData['user'];
      print('User: $user');

      setState(() {
        nama = user['nama'] ?? '';
        nip = user['nip'] ?? '';
        jabatan = user['jabatan'] ?? '';
        email = user['email'] ?? '';
        noTelp = user['no_telp'] ?? '';
        role = user['role'] ?? '';
      });
    } else {
      print('Gagal mengambil data profil: ${response.body}');
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text("Konfirmasi Logout"),
            content: const Text("Apakah Anda yakin ingin logout?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                },
                child: const Text("Logout"),
              ),
            ],
          ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value.isNotEmpty ? value : '-'),
      ),
    );
  }

  Widget _navItem(String label, IconData icon, int index) {
    bool isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Homescreen()),
          );
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Qrscanscreen()),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? Colors.blueAccent : Colors.grey),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.blueAccent : Colors.grey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 160,
                decoration: const BoxDecoration(
                  color: Color(0xFF5A8ECF),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
              ),
              Positioned(
                top: 100,
                left: 24,
                right: 24,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Stack(
                            children: [
                              const CircleAvatar(
                                radius: 35,
                                backgroundImage: AssetImage(
                                  'assets/perempuan.jpeg',
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF5A8ECF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nama,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(jabatan),
                                Text(role),
                                const SizedBox(height: 4),
                                Text(
                                  nip,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 90),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                const Text(
                  "Data Pribadi",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(nama.isNotEmpty ? nama : "-"),
                  ),
                ),

                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.badge),
                    title: Text(nip.isNotEmpty ? nip : "-"),
                  ),
                ),

                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.work),
                    title: Text(jabatan.isNotEmpty ? jabatan : "-"),
                  ),
                ),

                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.admin_panel_settings),
                    title: Text(role.isNotEmpty ? role : "-"),
                  ),
                ),

                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.email),
                    title: Text(email.isNotEmpty ? email : "-"),
                  ),
                ),

                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.phone),
                    title: Text(noTelp.isNotEmpty ? noTelp : "-"),
                    trailing: TextButton(
                      onPressed: () {
                        showEditPhoneDialog();
                      },
                      child: const Text("Ubah", style: TextStyle(color: Colors.blueAccent)),
                      ),
                    ),
                  ),
                
                const SizedBox(height: 16),

                Card(
                  child: ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      "Logout",
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () => _showLogoutDialog(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(35),
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem("Beranda", Icons.home, 0),
                _navItem("Profil", Icons.person, 2),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedIndex = 1);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Qrscanscreen()),
                );
              },
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6CA9D4),
                  border: Border.all(color: Colors.black, width: 3),
                ),
                child: const Icon(Icons.qr_code, size: 34, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
  void showEditPhoneDialog() {
  final TextEditingController phoneController = TextEditingController(text: noTelp);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Ubah Nomor Telepon"),
        content: TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: "Nomor Telepon",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Batal
            },
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                noTelp = phoneController.text; // Simpan perubahan
              });
              Navigator.of(context).pop(); // Tutup dialog
            },
            child: const Text("Simpan"),
          ),
        ],
      );
    },
  );
}
}
