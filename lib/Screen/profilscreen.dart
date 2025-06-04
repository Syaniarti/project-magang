import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'homescreen.dart';
import 'qrscanscreen.dart';
import 'loginscreen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  int _selectedIndex = 2;
  File? _imageFile;
  final picker = ImagePicker();
  
  String nama = '';
  String nip = '';
  String jabatan = '';
  String email = '';
  String notelp = '';
 

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
        print("Token tidak ditemukan");
        return;
      }

    final response = await http.get(
      Uri.parse(
        'http://127.0.0.1:8000/api/profile',
      ), 
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      print(jsonEncode(jsonData));

      final user = jsonData['user'];

      if (user != null) {
          setState(() {
            nama = user['nama'] ?? '';
            nip = user['nip'] ?? '';
            jabatan = user['jabatan'] ?? '';
            email = user['email'] ?? '';
            notelp = user['no_telp'] ?? '';
          });

      await prefs.setString('nama', nama);
      await prefs.setString('nip', nip);
      await prefs.setString('jabatan', jabatan);
      await prefs.setString('email', email);
      await prefs.setString('no_telp', notelp);
    } else {
      print("User null, load dari SharedPreferences");
      loadFromPrefs(prefs);
    }
  } else {
    print("Gagal ambil dari API, load dari SharedPreferences");
    loadFromPrefs(prefs);
  }
}
void loadFromPrefs(SharedPreferences prefs) {
  setState(() {
    nama = prefs.getString('nama') ?? '';
    nip = prefs.getString('nip') ?? '';
    jabatan = prefs.getString('jabatan') ?? '';
    email = prefs.getString('email') ?? '';
    notelp = prefs.getString('no_telp') ?? '';
  });
}

  Future<void> updatePhoneNumber(String newPhone) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      print("Token tidak ditemukan");
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('http://127.0.0.1:8000/api/updatephone'), 
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'no_telp': newPhone}),
      );

      if (response.statusCode == 200) {
        print("Nomor telepon berhasil diperbarui.");
        setState(() {
          notelp = newPhone;
        });
      } else {
        print("Gagal update nomor telepon: ${response.statusCode} | ${response.body}");
      }
    } catch (e) {
      print("Terjadi kesalahan saat update no telp: $e");
    }
  }

 Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
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
                      builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                },
                child: const Text("Logout"),
             ),
        ],
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

 void showEditPhoneDialog() {
    final TextEditingController phoneController = TextEditingController(text: notelp);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text("Ubah Nomor Telepon"),
          content: TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: "Nomor Telepon", border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Batal"),
            ),
            ElevatedButton(
            onPressed: () {
              final newPhone = phoneController.text;
              if (newPhone.isNotEmpty && newPhone != notelp) {
                updatePhoneNumber(newPhone);
              }
              Navigator.of(context).pop();
            },
            child: const Text("Simpan"),
          ),
          ],
        );
      },
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
              top: 20, // Ubah dari 100 ke 60 atau lebih kecil
              left: 60,
              right: 60,
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
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: 35,
                                backgroundImage: _imageFile != null
                                    ? FileImage(_imageFile!)
                                    : const AssetImage('assets/profile.png') as ImageProvider,
                              ),
                              GestureDetector(
                                onTap: _pickImage,
                                child: const CircleAvatar(
                                  radius: 10,
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.camera_alt, size: 16),
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
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ]
          ),
      
          const SizedBox(height: 20),
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
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(nama.isNotEmpty ? nama : "-"),
                  ),
                ),

                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.badge),
                    title: Text(nip.isNotEmpty ? nip : "-"),
                  ),
                ),

                Card(
                  color: Colors.white,
                  shape: 
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.work),
                    title: Text(jabatan.isNotEmpty ? jabatan : "-"),
                  ),
                ),

                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.email),
                    title: Text(email.isNotEmpty ? email : "-"),
                  ),
                ),

                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.phone),
                    title: Text(notelp.isNotEmpty ? notelp : "-"),
                    trailing: TextButton(
                      onPressed: () {
                        showEditPhoneDialog();
                      },
                      child: const Text("Ubah", style: TextStyle(color: Color(0xFF5A8ECF))),
                      ),
                    ),
                  ),
                
                 const SizedBox(height: 16),
                Card(
                  color: Colors.white,
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
}