import 'package:flutter/material.dart';
import 'package:asetcare/Screen/pinjamasetscreen.dart';
import 'package:asetcare/Screen/kembalikanasetscreen.dart';
import 'package:asetcare/Screen/qrscanscreen.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HasilQrScreen(qrData: '123456'),
    ),
  );
}

class Aset {
  final String namaAset;
  final String serialNumber;
  final String kondisi;
  final String lokasiTerkini;
  final DateTime tanggalUpload;
  final String dokumentasiUrl; // URL atau path lokal

  Aset({
    required this.namaAset,
    required this.serialNumber,
    required this.kondisi,
    required this.lokasiTerkini,
    required this.tanggalUpload,
    required this.dokumentasiUrl,
  });
}

class HasilQrScreen extends StatelessWidget {
  final String qrData;

  const HasilQrScreen({super.key, required this.qrData});

  Aset? getAsetData(String qrData) {
    final dummyDatabase = {
      '123456': Aset(
        namaAset: 'Paku Baja',
        serialNumber: 'SN-00123',
        kondisi: 'Bagus',
        lokasiTerkini: 'Gudang Utama',
        tanggalUpload: DateTime(2024, 12, 25),
        dokumentasiUrl:
            'https://via.placeholder.com/150', // Ganti dengan asset lokal jika perlu
      ),
    };
    return dummyDatabase[qrData];
  }

  Widget buildInfoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.blueAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final aset = getAsetData(qrData);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Informasi Aset",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              buildInfoField("QR Data", qrData),
              if (aset != null) ...[
                buildInfoField("Nama Aset", aset.namaAset),
                buildInfoField("Serial Number", aset.serialNumber),
                buildInfoField("Kondisi", aset.kondisi),
                buildInfoField("Lokasi Terkini", aset.lokasiTerkini),
                buildInfoField("Tanggal Upload",
                    '${aset.tanggalUpload.day}-${aset.tanggalUpload.month}-${aset.tanggalUpload.year}'),
                const Text(
                  "Dokumentasi Barang",
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Image.network(
                  aset.dokumentasiUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ] else ...[
                const Text(
                  "Data aset tidak ditemukan.",
                  style: TextStyle(color: Colors.red),
                ),
              ],
              const SizedBox(height: 30),
              Center(
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PinjamAsetScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF82B1FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 30),
                      ),
                      child: const Text(
                        "Pinjam Aset",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const KembalikanAsetScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF82B1FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 30),
                      ),
                      child: const Text(
                        "Pengembalian",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Qrscanscreen(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.blueAccent),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 30),
                      ),
                      child: const Text(
                        "Kembali",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
