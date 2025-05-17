import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'homescreen.dart';
import '../api/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nipController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  void _login() async {
  String email = _usernameController.text.trim();
  String nip = _nipController.text.trim();
  String password = _passwordController.text;

  if (email.isNotEmpty && nip.isNotEmpty && password.isNotEmpty) {
    try {
      final url = Uri.parse('http://127.0.0.1:8000/api/login');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'email': email, 'nip': nip, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Login berhasil: $data');

        // Simpan data ke SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
  
        await prefs.setString('nama', data['user']['nama']); 
        await prefs.setString('nip', data['user']['nip']);

        // Tampilkan pesan sukses dan navigasi
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login berhasil!")),
        );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Homescreen()),
          );
        } else {
          final data = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Login gagal: ${data['message'] ?? 'Cek kembali data Anda'}",
              ),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Terjadi kesalahan: $e")));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Harap isi semua kolom!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFFAF9F6),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.1,
            ), 
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Selamat datang Di',
                  style: TextStyle(
                    color: Color(0xFF76A9FA),
                    fontSize:
                        28, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'AsetCare',
                  style: TextStyle(
                    color: Color(0xFF4A628A),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.02,
                ), 

                Image.asset(
                  "assets/gambar1.png",
                  width: screenWidth * 0.4, 
                  height: screenHeight * 0.3, 
                  fit: BoxFit.cover,
                ),
                SizedBox(height: screenHeight * 0.03),

                // email Field
                SizedBox(
                  width: screenWidth * 0.7,
                  child: TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(width: 1),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),

                // NIP Field
                SizedBox(
                  width:
                      screenWidth *
                      0.7, 
                  child: TextField(
                    controller: _nipController,
                    decoration: InputDecoration(
                      hintText: 'NIP',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ), 
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(width: 1),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),

                SizedBox(
                  width: screenWidth * 0.7,
                  child: TextField(
                    controller: _passwordController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      hintText: 'Kata Sandi',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(width: 1),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),

                // Masuk Button
                SizedBox(
                  width:
                      screenWidth *
                      0.3, 
                  height: 45, 
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A628A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          8,
                        ), 
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                      ), 
                    ),
                    child: const Text(
                      'Masuk',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ), 
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
