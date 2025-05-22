import 'package:asetcare/Screen/homescreen.dart';
import 'package:asetcare/Screen/kembalikanasetscreen.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AsetDipinjamScreen extends StatefulWidget {
  final Map<String, dynamic>? aset;
  const AsetDipinjamScreen({super.key, this.aset});

  @override
  State<AsetDipinjamScreen> createState() => _AsetDipinjamScreenState();
}

class _AsetDipinjamScreenState extends State<AsetDipinjamScreen> {
  List<dynamic> daftarAset = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchAsetDipinjam();
  }

  Future<void> fetchAsetDipinjam() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/aset-dipinjam'),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> data =
            decoded is List ? decoded : (decoded['data'] ?? []);
        setState(() {
          daftarAset = data;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        print("Gagal fetch data: ${response.reasonPhrase}");
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Terjadi kesalahan: $e");
    }
  }

  List<dynamic> get filteredAset {
    if (_searchQuery.isEmpty) return daftarAset;
    return daftarAset.where((aset) {
      final name = (aset['Nama_Aset'] ?? '').toString().toLowerCase();
      final serial = (aset['Serial_Number'] ?? '').toString().toLowerCase();
      return name.contains(_searchQuery.toLowerCase()) ||
          serial.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // AppBar Custom
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Homescreen(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                  Expanded(
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      setState(() {
                        _searchQuery = _searchController.text;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
              child: Text(
                '🛠️ Daftar Aset Dipinjam',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ),
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredAset.isEmpty
                      ? const Center(
                        child: Text('Tidak ada data aset yang dipinjam.'),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredAset.length,
                        itemBuilder: (context, index) {
                          final aset = filteredAset[index];
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
                                    // Gambar / Icon Placeholder
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(8),
                                        image:
                                            aset['dokumentasi_barang'] != null
                                                ? DecorationImage(
                                                  image: NetworkImage(
                                                    'http://localhost:8000/proxy-image?path=${aset['dokumentasi_barang']}',
                                                  ),
                                                  fit: BoxFit.cover,
                                                )
                                                : null,
                                      ),
                                      child:
                                          aset['dokumentasi_barang'] == null
                                              ? const Icon(
                                                Icons.image,
                                                size: 30,
                                              )
                                              : null,
                                    ),
                                    const SizedBox(width: 12),
                                    // Informasi aset
                                    Expanded(
                                      child: Table(
                                        columnWidths: const {
                                          0: IntrinsicColumnWidth(),
                                          1: FixedColumnWidth(8),
                                          2: FlexColumnWidth(),
                                        },
                                        children: [
                                          TableRow(
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 4,
                                                ),
                                                child: Text(
                                                  "Nama Aset",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const Padding(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 4,
                                                ),
                                                child: Text(":"),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 4,
                                                    ),
                                                child: Text(
                                                  aset['Nama_Aset'] ?? '-',
                                                ),
                                              ),
                                            ],
                                          ),
                                          TableRow(
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 4,
                                                ),
                                                child: Text(
                                                  "Serial Number",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const Padding(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 4,
                                                ),
                                                child: Text(":"),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 4,
                                                    ),
                                                child: Text(
                                                  aset['Serial_Number'] ?? '-',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed:
                                          () =>
                                              _showDetailDialog(context, aset),
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
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Detail Aset Dipinjam',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCardInfo("Nama Aset", aset['Nama_Aset']),
                  _buildCardInfo("Serial Number", aset['Serial_Number']),
                  _buildCardInfo("Nama Peminjam", aset['Nama_Peminjam']),
                  _buildCardInfo("No Telp/WhatsApp", aset['No_Telp']),
                  _buildCardInfo("Kondisi", aset['Kondisi']),
                  _buildCardInfo("Lokasi Terkini", aset['Lokasi_Terkini']),
                  _buildCardInfo("Lokasi Tujuan", aset['Lokasi_Tujuan']),
                  _buildCardInfo(
                    "Tanggal Peminjaman",
                    aset['Tanggal_Peminjaman'],
                  ),
                  if (aset['dokumentasi_barang'] != null) ...[
                    const SizedBox(height: 12),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Dokumentasi Aset",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
                          'http://localhost:8000/proxy-image?path=${aset['dokumentasi_barang']}',
                          width: 100,
                          height: 100,
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => KembalikanAsetScreen(aset: aset),
                    ),
                  );
                },
                child: const Text(
                  'Kembalikan Aset',
                  style: TextStyle(color: Colors.white),
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
}
