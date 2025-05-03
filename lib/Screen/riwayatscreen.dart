import 'package:flutter/material.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> riwayatItems = [
    {"nama": "Kursi", "seri": "SeriL23"},
    {"nama": "Meja", "seri": "SeriM45"},
    {"nama": "Buku", "seri": "SeriB90"},
    {"nama": "Pena", "seri": "SeriP21"},
    {"nama": "Pensil", "seri": "SeriPN09"},
     {"nama": "Kursi", "seri": "SeriL23"},
    {"nama": "Meja", "seri": "SeriM45"},
    {"nama": "Buku", "seri": "SeriB90"},
    {"nama": "Pena", "seri": "SeriP21"},
    {"nama": "Pensil", "seri": "SeriPN09"},
  ];

   String searchText = '';

  List<Map<String, String>> filteredItems = [];

  @override
  void initState() {
    super.initState();
    filteredItems = riwayatItems;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      filteredItems = riwayatItems.where((item) {
        return item['nama']!.toLowerCase().contains(query) ||
            item['seri']!.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _downloadPDF() {
    // TODO: Implement PDF generation logic here
    debugPrint("Download PDF triggered");
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFDFD),
        elevation: 0,
        title: const Text(""),
        automaticallyImplyLeading: false,
        toolbarHeight: 0, // hide built-in AppBar height
      ),
      body: Column(
        children: [
          // Search Bar & Download Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
  children: [
    IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.black),
      onPressed: () => Navigator.pop(context),
    ),
    const SizedBox(width: 8),
    // kolom pencarian
       Expanded(
  child: Container(
    height: 45,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: Colors.grey.shade200, // sesuai tampilanmu
      borderRadius: BorderRadius.circular(12),
    ),
    child: TextField(
      controller: _searchController,
      decoration: const InputDecoration(
        hintText: 'Search',
        hintStyle: TextStyle(color: Colors.grey),
        prefixIcon: Icon(Icons.search, color: Colors.grey),
        border: InputBorder.none,
        contentPadding: EdgeInsets.only(top: 14), // ⬅️ Ini yang bikin teks turun
        isDense: true,
      ),
      onChanged: (value) {
        setState(() {
          searchText = value;
        });
      },
    ),
  ),
),


    const SizedBox(width: 5),
    IconButton(
      icon: const Icon(Icons.download, color: Colors.black54),
      tooltip: 'Unduh PDF',
      onPressed: _downloadPDF,
    ),
  ],
),

          ),

          // Optional Title
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Daftar Riwayat Peminjaman",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          // List View
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                   boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Gambar
                      Container(
                        width: 80,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.image,
                            size: 32, color: Colors.white),
                      ),
                      const SizedBox(width: 10),

                      // Nama + Seri
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['nama']!,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(item['seri']!,
                                style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),

                      // Tanggal & Status
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Row(
                            children: [
                              Icon(Icons.logout, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text("28-02-2025", style: TextStyle(fontSize: 13)),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.login, size: 18, color: Colors.teal),
                              SizedBox(width: 8),
                              Text("04-03-2025", style: TextStyle(fontSize: 13)),
                            ],
                          ),
                            ],
        ),
                          const SizedBox(width: 50),
                         Container(
          alignment: Alignment.centerRight,
          height: 40, 
          child: Text(
            "Selesai",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.green.shade700,
            ),
          ),
        ),
                  
                
                    ],
                  )   
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
