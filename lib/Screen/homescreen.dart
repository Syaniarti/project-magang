import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:asetcare/models/riwayat_item.dart'; // pastikan path benar
import 'package:asetcare/Screen/qrscanscreen.dart';
import 'package:asetcare/Screen/aset_tersedia_screen.dart';
import 'package:asetcare/Screen/aset_dipinjam_screen.dart';
import 'package:asetcare/Screen/pegawai_screen.dart';
import 'package:asetcare/Screen/profilscreen.dart';
import 'package:asetcare/Screen/riwayatscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Homescreen> {
  int _selectedIndex = 0;
  String _name = '';
  String _nip = '';

  List<RiwayatItem> riwayatItems = [];
  bool isLoadingRiwayat = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchRiwayat();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('nama') ?? '';
      _nip = prefs.getString('nip') ?? '';
    });
  }

  Future<void> _fetchRiwayat() async {
    setState(() => isLoadingRiwayat = true);
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
          isLoadingRiwayat = false;
        });
      } else {
        throw Exception('Gagal memuat riwayat');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data riwayat: $e')),
      );
      setState(() => isLoadingRiwayat = false);
    }
  }

  void navigateTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final List<_MenuItem> menuItems = [
      _MenuItem("Aset Tersedia", Icons.checklist, const AsetTersediaScreen()),
      _MenuItem("Aset Dipinjam", Icons.inventory, const AsetDipinjamScreen()),
      _MenuItem("Pegawai", Icons.group, const PegawaiScreen()),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      extendBody: true,
      body:
          _selectedIndex == 0
              ? _buildHomeContent(context, menuItems)
              : const ProfilScreen(),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildHomeContent(BuildContext context, List<_MenuItem> menuItems) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.0, -0.8),
                radius: 1.1,
                colors: [
                  Color(0xFFCCE7FF),
                  Color(0xFF5A8ECF),
                  Color(0xFF1E3C72),
                ],
                stops: [0.0, 0.6, 1.0],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(70)),
            ),
            child: SizedBox(
              height: 140,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Selamat Datang,",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _name,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _nip,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: ClipRRect(
                      child: Image.asset(
                        'assets/pegawai.png',
                        width: 140,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: menuItems.length,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => item.page),
                    );
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 182, 208, 235),
                          border: Border.all(
                            color: const Color.fromARGB(255, 9, 13, 14),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item.icon,
                          size: 30,
                          color: const Color.fromARGB(255, 6, 65, 120),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 6, 65, 120),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text(
                  "Riwayat Peminjaman",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => navigateTo(context, const RiwayatScreen()),
                  child: const Text(
                    "Lihat Selengkapnya",
                    style: TextStyle(
                      color: Color.fromARGB(255, 6, 111, 197),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child:
                isLoadingRiwayat
                    ? const Center(child: CircularProgressIndicator())
                    : riwayatItems.isEmpty
                    ? const Center(child: Text("Data riwayat kosong"))
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount:
                          riwayatItems.length > 5
                              ? 5
                              : riwayatItems.length, // tampilkan max 5 item
                      itemBuilder: (context, index) {
                        final item = riwayatItems[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading:
                                item.dokumentasi_barang != null &&
                                        item.dokumentasi_barang!.isNotEmpty
                                    ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
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
                                      ),
                                    )
                                    : const Icon(
                                      Icons.image,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                            title: Text(
                              item.Nama_Aset,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(item.Serial_Number),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Tanggal Pinjam: ${item.Tanggal_Peminjaman}",
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  item.Status,
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            onTap: () => _showDetailDialog(item),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
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

  Widget _buildBottomNavBar(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(35),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(
                "Beranda",
                Icons.home,
                () => setState(() => _selectedIndex = 0),
                _selectedIndex == 0,
              ),
              _navItem(
                "Profil",
                Icons.person,
                () => setState(() => _selectedIndex = 2),
                _selectedIndex == 2,
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 20, // posisinya sedikit naik dari container
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Qrscanscreen()),
              );
            },
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6CA9D4),
                border: Border.all(color: Colors.black, width: 3),
              ),
              child: const Icon(Icons.qr_code, size: 34, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _navItem(
    String label,
    IconData icon,
    VoidCallback onTap,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? const Color(0xFF066FC5) : Colors.grey),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? const Color(0xFF066FC5) : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final String label;
  final IconData icon;
  final Widget page;

  _MenuItem(this.label, this.icon, this.page);
}
