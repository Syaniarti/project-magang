import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'homescreen.dart';
import '../api/auth.dart';

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
  String username = _usernameController.text;
  String nip = _nipController.text; // 
  String password = _passwordController.text;

  print("username: $username, NIP: $nip, Password: $password");

  if (username.isNotEmpty &&  password.isNotEmpty) {
    try {
      final url = Uri.parse('https://dummyjson.com/auth/login');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
          'expiresInMins': 30,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Login successful!');
        print(data);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login berhasil!")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Homescreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login gagal: ${response.reasonPhrase}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Harap isi semua kolom!")),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    // Mendapatkan ukuran layar
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFFAF9F6),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1), // 10% dari lebar layar
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Selamat datang Di',
                  style: TextStyle(
                    color: Color(0xFF76A9FA),
                    fontSize: 28, // Gunakan ukuran font yang lebih kecil agar tidak terlalu besar
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
                SizedBox(height: screenHeight * 0.02), // Jarak yang lebih fleksibel

                Image.asset(
                  "assets/gambar1.png",
                  width: screenWidth * 0.4, // 80% dari lebar layar
                  height: screenHeight * 0.3, // 30% dari tinggi layar
                  fit: BoxFit.cover,
                ),
                SizedBox(height: screenHeight * 0.03),

                // username Field
                SizedBox(
                width: screenWidth * 0.7, // Hanya 70% dari lebar layar
                child: TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: 'Username',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Perkecil padding dalam
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10), // Lebih kecil
                      borderSide: const BorderSide(width: 1),
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.015),

                // NIP Field
                SizedBox(
                  width: screenWidth * 0.7, // Lebar dikurangi menjadi 70% dari lebar layar
                  child: TextField(
                    controller: _nipController,
                    decoration: InputDecoration(
                      hintText: 'NIP',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Perkecil padding dalam
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10), // Lebih kecil
                        borderSide: const BorderSide(width: 1),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),

                // Password Field
                // Ubah bagian Password Field menjadi:
SizedBox(
  width: screenWidth * 0.7,
  child: TextField(
    controller: _passwordController,
    obscureText: _obscureText,
    decoration: InputDecoration(
      hintText: 'Kata Sandi',
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(width: 1),
      ),
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
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


                
SizedBox(height: screenHeight * 0.015),


                // Masuk Button
                SizedBox(
                  width: screenWidth * 0.3, // Lebar dikurangi menjadi 60% dari lebar layar
                  height: 45, // Tinggi tombol dikurangi
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A628A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // Lebih kecil agar tombol tidak terlalu melengkung
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12), // Kurangi padding dalam
                    ),
                    child: const Text(
                      'Masuk',
                      style: TextStyle(fontSize: 16, color: Colors.white), // Ukuran teks dikurangi
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
