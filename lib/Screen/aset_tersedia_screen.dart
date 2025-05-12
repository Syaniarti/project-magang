import 'package:asetcare/Screen/pinjamasetscreen.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AsetTersediaScreen extends StatefulWidget {
  final Map<String, dynamic>? newAsset;
  const AsetTersediaScreen({super.key, this.newAsset});

  @override
  State<AsetTersediaScreen> createState() => _AsetTersediaScreenState();
}

class _AsetTersediaScreenState extends State<AsetTersediaScreen> {
  List<dynamic> daftarAset = [];
  String searchText = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchAset(); // ambil semua aset saat pertama buka screen

    if (widget.newAsset != null) {
      // Tambahkan aset baru ke daftar
      setState(() {
        daftarAset.insert(0, widget.newAsset!); // Masukkan ke urutan atas
      });
    }
  }

  Future<void> fetchAset({String? query}) async {
    setState(() {
      isLoading = true;
    });

    final url =
        query == null || query.isEmpty
            ? 'https://dummyjson.com/products'
            : 'https://dummyjson.com/products/search?q=$query';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        daftarAset = data['products'];
        isLoading = false;
      });
    } else {
      setState(() {
        daftarAset = [];
        isLoading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchText = value;
    });
    fetchAset(query: value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: SafeArea(
        child: Column(
          children: [
            // Header bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // tombol kembali
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  // kolom pencarian
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          border: InputBorder.none,
                          icon: Icon(Icons.search),
                        ),
                        onChanged: _onSearchChanged,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.admin_panel_settings_rounded),
                    onPressed: () {
                      _showAdminDialog(context);
                    },
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '📦 Daftar Aset Tersedia',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // List of assets
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : daftarAset.isEmpty
                      ? const Center(
                        child: Text(
                          'Tidak ada data aset yang tersedia.',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: daftarAset.length,
                        itemBuilder: (context, index) {
                          final aset = daftarAset[index];
                          return Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // Asset image
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(8),
                                      image:
                                          aset['thumbnail'] != null
                                              ? DecorationImage(
                                                image: NetworkImage(
                                                  aset['thumbnail'],
                                                ),
                                                fit: BoxFit.cover,
                                              )
                                              : null,
                                    ),
                                    child:
                                        aset['thumbnail'] == null
                                            ? const Icon(Icons.image, size: 30)
                                            : null,
                                  ),
                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const SizedBox(
                                              width: 110, // panjang label tetap
                                              child: Text(
                                                "Nama Aset",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            Text(": ${aset['title']}"),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const SizedBox(
                                              width: 110,
                                              child: Text(
                                                "Serial Number",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            Text(": ${aset['id']}"),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const SizedBox(
                                              width: 110,
                                              child: Text(
                                                "Kondisi",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            Text(": \$${aset['price']}"),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // aksi pinjam
                                  IconButton(
                                    onPressed:
                                        () => _showAssetDetailDialog(
                                          context,
                                          aset,
                                        ),
                                    icon: const Icon(
                                      Icons.shopping_bag,
                                      color: Colors.amber,
                                    ),
                                  ),
                                ],
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
    builder: (context) => AlertDialog(
      title: Text(aset['title'] ?? 'Detail Aset'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (aset['thumbnail'] != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(aset['thumbnail']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Text("Deskripsi: ${aset['description'] ?? '-'}"),
          const SizedBox(height: 8),
          Text("Harga: \$${aset['price']}"),
          const SizedBox(height: 8),
          Text("Rating: ${aset['rating']}"),
          const SizedBox(height: 8),
          Text("Stok: ${aset['stock']} unit"),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
          ),
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PinjamAsetScreen(),
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
                    "Anda tidak memiliki izin untuk\nmengakses halaman ini.\n\nSilakan hubungi administrator\njika membutuhkan akses\nsebagai Admin Gudang.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
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
