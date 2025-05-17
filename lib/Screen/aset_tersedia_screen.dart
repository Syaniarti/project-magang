import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:asetcare/Screen/pinjamasetscreen.dart';

class AsetTersediaScreen extends StatefulWidget {
  final Map<String, dynamic>? Aset;
  const AsetTersediaScreen({super.key, this.Aset});

  @override
  State<AsetTersediaScreen> createState() => _AsetTersediaScreenState();
}

class _AsetTersediaScreenState extends State<AsetTersediaScreen> {
  List<dynamic> daftarAset = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchAset();

    if (widget.Aset != null) {
      setState(() {});
    }
  }

  Future<void> fetchAset() async {
    setState(() {
      isLoading = true;
    });

    try {
      var request = http.Request(
        'GET',
        Uri.parse('http://127.0.0.1:8000/api/databarangtersedia'),
      );
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseData = await response.stream.bytesToString();
        final List<dynamic> data = json.decode(responseData);
        setState(() {
          daftarAset = data;
          isLoading = false;
        });
      } else {
        print(response.reasonPhrase);
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Terjadi kesalahan: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      "📦 Daftar Aset Tersedia",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.admin_panel_settings_rounded),
                    onPressed: () {
                      _showAdminDialog(context);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : daftarAset.isEmpty
                      ? const Center(
                        child: Text('Tidak ada data aset yang tersedia.'),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: daftarAset.length,
                        itemBuilder: (context, index) {
                          final aset = daftarAset[index];
                          return InkWell(
                            borderRadius: BorderRadius.circular(
                              12,
                            ), // supaya efek klik sesuai border card
                            onTap: () {
                              _showAssetDetailDialog(context, aset);
                            },
                            child: Card(
                              color: Colors.white,
                              elevation: 5,
                              shadowColor: Colors.black26,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    // Foto aset
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        color: Colors.grey.shade300,
                                        child:
                                            aset['dokumentasi_barang'] != null
                                                ? Image.network(
                                                  aset['dokumentasi_barang'],
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) => const Icon(
                                                        Icons.broken_image,
                                                        size: 30,
                                                      ),
                                                )
                                                : const Icon(
                                                  Icons.image,
                                                  size: 30,
                                                ),
                                      ),
                                    ),

                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Nama Aset: ${aset['Nama_Aset'] ?? '-'}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            "Serial Number: ${aset['Serial_Number'] ?? '-'}",
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(
                                        Icons.shopping_bag,
                                        color: Colors.amber,
                                      ),
                                    ),
                                  ],
                                ),
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

  void _showAssetDetailDialog(BuildContext context, dynamic aset) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 8, // bayangan dialog
            titleTextStyle: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            title: Text('Detail Aset'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCardInfo("Nama_Aset", aset['Nama_Aset']),
                  _buildCardInfo("Serial Number", aset['Serial_Number']),
                  _buildCardInfo("Kondisi", aset['Kondisi']),
                  _buildCardInfo("Lokasi Terkini", aset['Lokasi_Terkini']),
                  _buildCardInfo("Tanggal Upload", aset['Tanggal_Upload']),
                  if (aset['dokumentasi_barang'] != null) ...[
                    const SizedBox(height: 12),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Dokumentasi Aset",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          aset['dokumentasi_barang'],
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => const Padding(
                                padding: EdgeInsets.all(16),
                                child: Icon(
                                  Icons.broken_image,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                              ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 43, 97, 133),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  // Navigasi ke halaman PinjamAsetScreen dan kirim data aset
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PinjamAsetScreen(Aset: aset),
                    ),
                  );
                },
                child: const Text(
                  'Ajukan Pinjam',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildCardInfo(String title, String? value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 5,
              child: Text(
                value ?? "-",
                style: const TextStyle(color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdminDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Anda tidak memiliki izin untuk mengakses halaman ini.\n"
                    "Silakan hubungi administrator jika membutuhkan akses sebagai Admin Gudang.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                    ),
                    child: const Text(
                      "Oke",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
