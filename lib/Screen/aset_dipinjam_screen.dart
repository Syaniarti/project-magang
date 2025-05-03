import 'package:flutter/material.dart';

class AsetDipinjamScreen extends StatefulWidget {
  const AsetDipinjamScreen({super.key});

  @override
  State<AsetDipinjamScreen> createState() => _AsetDipinjamScreenState();
}

class _AsetDipinjamScreenState extends State<AsetDipinjamScreen> {
  final List<Map<String, String>> daftarAsetDipinjam = List.generate(8, (
    index,
  ) {
    return {
      'nama': index % 2 == 0 ? 'Obeng' : 'Tangga',
      'sn': '1213$index',
      'kondisi': 'Baik',
      'peminjam': 'User ${index + 1}',
      'telepon': '08${index}1234567$index',
      'lokasi':
          index % 3 == 0
              ? 'Baceh'
              : index % 3 == 1
              ? 'Langsa'
              : 'Meulaboh',
      'tanggal':
          '2025-04-${(index + 10).toString().padLeft(2, '0')}', // contoh tanggal dinamis
    };
  });

  String searchText = '';

  @override
  Widget build(BuildContext context) {
    final filteredList =
        daftarAsetDipinjam.where((aset) {
          final nama = aset['nama']!.toLowerCase();
          final sn = aset['sn']!.toLowerCase();
          return nama.contains(searchText.toLowerCase()) ||
              sn.contains(searchText.toLowerCase());
        }).toList();

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
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
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
                        onChanged: (value) {
                          setState(() {
                            searchText = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '🛠️ Daftar Aset Dipinjam',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // List of borrowed assets
            Expanded(
              child:
                  filteredList.isEmpty
                      ? const Center(
                        child: Text(
                          'Tidak ada data aset yang dipinjam.',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final aset = filteredList[index];
                          return GestureDetector(
                            onTap: () => _showDetailDialog(context, aset),
                            child: Card(
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
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.asset(
                                          'assets/assets/obeng.jpg',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    // Asset details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Nama Barang    : ${aset['nama']}",
                                          ),
                                          Text(
                                            "SN                       : ${aset['sn']}",
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Aksi pengembalian (placeholder)
                                    IconButton(
                                      onPressed: () {
                                        // nanti bisa diarahkan ke form pengembalian
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

  void _showDetailDialog(BuildContext context, Map<String, String> aset) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "📦 Detail Aset",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/assets/obeng.jpg',
                width: 5,
                height: 5,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),

            // Table info
            Table(
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: FlexColumnWidth(),
              },
              border: TableBorder(
                horizontalInside: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              children: [
                _buildTableRow("Nama Barang", aset['nama']),
                _buildTableRow("SN", aset['sn']),
                _buildTableRow("Kondisi", aset['kondisi']),
                _buildTableRow("Peminjam", aset['peminjam']),
                _buildTableRow("No. Telepon", aset['telepon']),
                _buildTableRow("Tanggal Pinjam", aset['tanggal']),
                _buildTableRow("Lokasi Tujuan", aset['lokasi']),
              ],
            ),

            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
              label: const Text("Tutup"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// Helper function untuk baris tabel
TableRow _buildTableRow(String label, String? value) {
  return TableRow(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          "$label:",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(value ?? "-"),
      ),
    ],
  );
}
}