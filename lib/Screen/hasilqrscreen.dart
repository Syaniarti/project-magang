import 'package:flutter/material.dart';
import 'package:asetcare/Screen/pinjamasetscreen.dart';
import 'package:asetcare/Screen/kembalikanasetscreen.dart';
import 'package:asetcare/Screen/qrscanscreen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
  final String dokumentasiUrl;

  Aset({
    required this.namaAset,
    required this.serialNumber,
    required this.kondisi,
    required this.lokasiTerkini,
    required this.tanggalUpload,
    required this.dokumentasiUrl,
  });
}

class HasilQrScreen extends StatefulWidget {
  final String qrData;

  const HasilQrScreen({super.key, required this.qrData});

  @override
  State<HasilQrScreen> createState() => _HasilQrScreenState();
}

class _HasilQrScreenState extends State<HasilQrScreen> {
  Map<String, dynamic>? asetData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchAsetData();
  }

  Future<void> fetchAsetData() async {
    final serial = widget.qrData;
    final url = Uri.parse(
      'http://127.0.0.1:8000/api/databarangtersedia/serial/$serial',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          asetData = data;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              json.decode(response.body)['message'] ?? 'Aset tidak ditemukan';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan: $e';
        isLoading = false;
      });
    }
  }

  Widget buildInfoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color.fromARGB(255, 27, 48, 83),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 16, color: Colors.black)),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Aset')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildInfoField(
                                "Nama Aset",
                                asetData!['Nama_Aset'],
                              ),
                              buildInfoField(
                                "Serial Number",
                                asetData!['Serial_Number'],
                              ),
                              buildInfoField("Kondisi", asetData!['Kondisi']),
                              buildInfoField(
                                "Lokasi Terkini",
                                asetData!['Lokasi_Terkini'],
                              ),
                              buildInfoField(
                                "Tanggal Upload",
                                asetData!['Tanggal_Upload'] ?? "Tidak tersedia",
                              ),
                              const SizedBox(height: 10),
                              if (asetData!['dokumentasi_barang'] != null) ...[
                                Text(
                                  "Dokumentasi Barang",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 27, 48, 83),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Image.network(
                                  asetData!['dokumentasi_barang'],
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ] else
                                const Text('Tidak ada dokumentasi'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const PinjamAsetScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(255, 27, 48, 83),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 30,
                                ),
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
                                    builder:
                                        (context) =>
                                            const KembalikanAsetScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(255, 27, 48, 83),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 30,
                                ),
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
                                side: const BorderSide(
                                  color: Color.fromARGB(255, 27, 48, 83),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 30,
                                ),
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
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
