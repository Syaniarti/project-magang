import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/riwayat_item.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<RiwayatItem> riwayatItems = [];
  bool isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchRiwayat();
  }

  Future<void> fetchRiwayat() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/riwayat-peminjaman'),
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'];
        setState(() {
          riwayatItems =
              data.map((item) => RiwayatItem.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Gagal memuat riwayat');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengambil data: $e')));
      setState(() => isLoading = false);
    }
  }

  List<RiwayatItem> get filteredItems {
    if (_searchQuery.isEmpty) return riwayatItems;
    return riwayatItems.where((item) {
      return item.Nama_Aset.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          item.Serial_Number.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _showDetailDialog(RiwayatItem item) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Detail Riwayat Peminjaman',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  _buildCardInfo("Nama Aset", item.Nama_Aset),
                  _buildCardInfo("Serial Number", item.Serial_Number),
                  _buildCardInfo("Lokasi Peminjaman", item.Lokasi_Peminjaman),
                  _buildCardInfo("Tanggal Peminjaman", item.Tanggal_Peminjaman),
                  _buildCardInfo(
                    "Lokasi Pengembalian",
                    item.Lokasi_Pengembalian ?? "-",
                  ),
                  _buildCardInfo(
                    "Tanggal Pengembalian",
                    item.Tanggal_Pengembalian ?? "-",
                  ),
                  _buildCardInfo("Status", item.Status),
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
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
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
                    onPressed: () => Navigator.pop(context),
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
                        onChanged: (val) {
                          setState(() => _searchQuery = val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "📚 Riwayat Peminjaman Aset",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredItems.isEmpty
                      ? const Center(child: Text("Data tidak ditemukan."))
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return InkWell(
                            onTap: () => _showDetailDialog(item),
                            borderRadius: BorderRadius.circular(12),
                            child: Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Gambar
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child:
                                          item.dokumentasi_barang != null &&
                                                  item
                                                      .dokumentasi_barang!
                                                      .isNotEmpty
                                              ? Image.network(
                                                'http://localhost:8000/proxy-image?path=${item.dokumentasi_barang}',
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover,
                                                errorBuilder: (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) {
                                                  return const Icon(
                                                    Icons.broken_image,
                                                    size: 50,
                                                    color: Colors.grey,
                                                  );
                                                },
                                              )
                                              : Container(
                                                width: 50,
                                                height: 50,
                                                color: Colors.grey.shade300,
                                                child: const Icon(
                                                  Icons.image,
                                                  color: Colors.white,
                                                ),
                                              ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Informasi Aset (Nama & Serial)
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.Nama_Aset,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item.Serial_Number,
                                            style: const TextStyle(
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Status dan Tanggal
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          item.Status.toLowerCase() == "selesai"
                                              ? "Selesai"
                                              : "Belum Selesai",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                item.Status.toLowerCase() ==
                                                        "selesai"
                                                    ? Colors.green
                                                    : Colors.red,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.logout,
                                              color: Colors.red,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              item.Tanggal_Peminjaman,
                                              style: const TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.login,
                                              color: Colors.teal,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              item.Tanggal_Pengembalian ?? "-",
                                              style: const TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
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
}
