import 'package:flutter/material.dart';

class PegawaiScreen extends StatelessWidget {
  const PegawaiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> pegawaiList = List.generate(8, (index) {
      return {
        "nama": "Pegawai ${index + 1}",
        "nip": "NIP000${index + 1}"
      };
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5A8ECF),
        elevation: 0,
        title: const Text(
          "Data Pegawai",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: const Color(0xFFF5F7FA),
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: pegawaiList.length,
          itemBuilder: (context, index) {
            final pegawai = pegawaiList[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFBFD7ED),
                  child: const Icon(Icons.person, color: Color(0xFF2B3A55)),
                ),
                title: Text(
                  pegawai['nama']!,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  pegawai['nip']!,
                  style: const TextStyle(color: Colors.grey),
                ),
                
              ),
            );
          },
        ),
      ),
    );
  }
}
