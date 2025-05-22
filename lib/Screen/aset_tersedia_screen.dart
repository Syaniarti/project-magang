import 'package:asetcare/Screen/homescreen.dart';
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
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchAset();
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => Homescreen()),
                        (route) => false, // hapus semua route sebelumnya
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
                  "📦 Daftar Aset Tersedia",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredAset.isEmpty
                      ? const Center(
                        child: Text('Tidak ada data aset yang tersedia.'),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredAset.length,
                        itemBuilder: (context, index) {
                          final aset = filteredAset[index];
                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              _showAssetDetailDialog(context, aset);
                            },
                            child: Card(
                              color: Colors.white,
                              elevation: 6,
                              shadowColor: Colors.black26,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        color: Colors.grey.shade300,
                                        child:
                                            aset['dokumentasi_barang'] != null
                                                ? Image.network(
                                                  'http://localhost:8000/proxy-image?path=${aset!['dokumentasi_barang']}',
                                                  fit: BoxFit.cover,
                                                )
                                                : const Icon(
                                                  Icons.image,
                                                  size: 30,
                                                ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Table(
                                        columnWidths: const {
                                          0: IntrinsicColumnWidth(), // Kolom label
                                          1: FixedColumnWidth(
                                            8,
                                          ), // Kolom titik dua
                                          2: FlexColumnWidth(), // Kolom nilai isi
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
            elevation: 8,
            titleTextStyle: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            title: const Text('Detail Aset'),
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
                    const SizedBox(height: 2),
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
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          'http://localhost:8000/proxy-image?path=${aset!['dokumentasi_barang']}',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
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
                      builder: (context) => PinjamAsetScreen(aset: aset),
                    ),
                  );
                },
                child: const Text(
                  'Pinjam Aset',
                  style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
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
