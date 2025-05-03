import 'package:flutter/material.dart';
import 'package:asetcare/Screen/loginscreen.dart';

class RequestUserScreen extends StatelessWidget {
  const RequestUserScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController nipController = TextEditingController();
    final TextEditingController emailController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: const Text('Permintaan Akses'),
        centerTitle: true,
        backgroundColor: const Color(0xFF4A628A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              const SizedBox(height: 32),
              const Text(
                'Form Permintaan Akses',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A628A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
                Center(
                child: Image.asset(
                  'assets/user.png', 
                  height: 200,
                ),
              ),

              // NIP Field
              _buildInputField(
                controller: nipController,
                label: 'NIP',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Email Field
              _buildInputField(
                controller: emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),

              // Kirim Permintaan Button
              ElevatedButton(
                onPressed: () {
                  final nip = nipController.text;
                  final email = emailController.text;

                  if (nip.isEmpty || email.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('NIP dan Email wajib diisi')),
                    );
                  } else {
                    RegExp emailRegExp = RegExp(
                      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
                    );

                    if (!emailRegExp.hasMatch(email)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Email tidak valid')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Permintaan akses berhasil dikirim. Silakan cek email setelah diverifikasi oleh admin.')),
                      );

                      Future.delayed(const Duration(seconds: 2), () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      });
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A628A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  shadowColor: Colors.grey.withOpacity(0.3),
                  elevation: 5,
                ),
                child: const Text(
                  '📩 Ajukan Permintaan Akses',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required TextInputType keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF4A628A)),
        filled: true,
        fillColor: Color(0xFFF1F4F7),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 1, color: Color(0xFF4A628A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 2, color: Color(0xFF4A628A)),
        ),
      ),
    );
  }
}
