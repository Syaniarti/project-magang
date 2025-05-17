import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AsetDipinjamScreen extends StatefulWidget {
  const AsetDipinjamScreen({super.key});

  @override
  State<AsetDipinjamScreen> createState() => _AsetDipinjamScreenState();
}

class _AsetDipinjamScreenState extends State<AsetDipinjamScreen> {
  List<dynamic> daftarAset = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/aset-dipinjam'),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        setState(() {
          daftarAset = json['data'];
          isLoading = false;
        });
      } else {
        print('Error: ${response.reasonPhrase}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
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
                      '🛠️ Daftar Aset Dipinjam',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : daftarAset.isEmpty
                      ? const Center(
                          child: Text('Tidak ada data aset yang dipinjam.'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: daftarAset.length,
                          itemBuilder: (context, index) {
                            final aset = daftarAset[index];
                            return InkWell(
                              onTap: () => _showDetailDialog(context, aset),
                              borderRadius: BorderRadius.circular(12),
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
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade300,
                                          borderRadius: BorderRadius.circular(8),
                                          image: aset['dokumentasi_barang'] != null
                                              ? DecorationImage(
                                                  image: NetworkImage(
                                                    aset['dokumentasi_barang'],
                                                  ),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                        ),
                                        child: aset['dokumentasi_barang'] == null
                                            ? const Icon(
                                                Icons.image,
                                                size: 30,
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                        onPressed: () {
                                          // Aksi jika diklik (misalnya pindah ke form pengembalian)
                                        },
                                        icon: const Icon(
                                          Icons.assignment_returned,
                                          color: Colors.green,
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

  void _showDetailDialog(BuildContext context, dynamic aset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(aset['Nama_Aset'] ?? 'Detail Aset'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (aset['dokumentasi_barang'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    aset['dokumentasi_barang'],
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 16),
              _buildCardInfo("Serial Number", aset['Serial_Number']),
              _buildCardInfo("Nama Peminjam", aset['Nama_Peminjam']),
              _buildCardInfo("No Telp/WhatsApp", aset['no_Telp']),
              _buildCardInfo("Kondisi", aset['Kondisi']),
              _buildCardInfo("Lokasi Terkini", aset['Lokasi_Terkini']),
              _buildCardInfo("Lokasi Tujuan", aset['Lokasi_Tujuan']),
              _buildCardInfo("Tanggal Peminjaman", aset['Tanggal_Peminjaman']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
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
                "$title:",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 5,
              child: Text(
                value ?? '-',
                style: const TextStyle(color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
