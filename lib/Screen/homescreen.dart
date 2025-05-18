import 'package:flutter/material.dart';
import 'package:asetcare/Screen/qrscanscreen.dart';
import 'package:asetcare/Screen/aset_tersedia_screen.dart';
import 'package:asetcare/Screen/aset_dipinjam_screen.dart';
import 'package:asetcare/Screen/pegawai_screen.dart';
import 'package:asetcare/Screen/profilscreen.dart';
import 'package:asetcare/Screen/admingudangscreen.dart';
import 'package:asetcare/Screen/riwayatscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: Homescreen()));
}

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Homescreen> {
  int _selectedIndex = 0;
  String _name = '';
  String _nip = '';
  bool isAdminApproved = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('nama') ?? '';
      _nip = prefs.getString('nip') ?? '';
    });
  }

  void navigateTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> riwayatItems = [
      {"nama": "Kursi", "seri": "Seril23"},
      {"nama": "Meja", "seri": "Seril23"},
      {"nama": "Buku", "seri": "Seril23"},
      {"nama": "Pena", "seri": "Seril23"},
      {"nama": "Pensil", "seri": "Seril23"},
    ];

    return Scaffold(
      extendBody: true,
      body: _selectedIndex == 0
          ? _buildHomeContent(context, riwayatItems)
          : _selectedIndex == 1
              ? const Qrscanscreen()
              : const ProfilScreen(),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildHomeContent(BuildContext context, List<Map<String, String>> riwayatItems) {
    final List<_MenuItem> menuItems = [
      _MenuItem("QR Code", Icons.qr_code, const Qrscanscreen()),
      _MenuItem("Aset Tersedia", Icons.checklist, const AsetTersediaScreen()),
      _MenuItem("Aset Dipinjam", Icons.inventory, const AsetDipinjamScreen()),
      _MenuItem("Pegawai", Icons.group, const PegawaiScreen()),
    ];

    return Scaffold(
  backgroundColor: Colors.white,
  body: SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.0, -0.8),
                radius: 1.1,
                colors: [Color(0xFFCCE7FF), Color(0xFF5A8ECF), Color(0xFF1E3C72)],
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
                        const Text("Selamat Datang,", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(_name, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text(_nip, style: const TextStyle(color: Colors.white70, fontSize: 20)),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 10,
                    bottom: -30,
                    child: ClipRRect(
                      child: Image.asset('assets/pegawai.png', width: 10, fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 30),
                      onPressed: () {
                        if (isAdminApproved) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPage()));
                        } else {
                          _showAdminDialog(context);
                        }
                      },
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
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 30,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return GestureDetector(
                  onTap: () => navigateTo(context, item.page),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 182, 208, 235),
                          border: Border.all(color: const Color.fromARGB(255, 9, 13, 14)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(item.icon, size: 30, color: const Color.fromARGB(255, 6, 65, 120)),
                      ),
                      const SizedBox(height: 6),
                      Text(item.label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Color.fromARGB(255, 6, 65, 120))),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text("Riwayat Peminjaman", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600)),
                const Spacer(),
                GestureDetector(
                  onTap: () => navigateTo(context, const RiwayatScreen()),
                  child: const Text("Lihat Selengkapnya", style: TextStyle(color: Color.fromARGB(255, 6, 111, 197), fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView.builder(
                itemCount: riwayatItems.length,
                itemBuilder: (context, index) {
                  final item = riwayatItems[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.image, size: 32, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['nama']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text(item['seri']!, style: const TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: const [
                            Row(
                              children: [
                                Icon(Icons.logout, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text("28-02-2025", style: TextStyle(fontSize: 14)),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.login, size: 18, color: Colors.teal),
                                SizedBox(width: 8),
                                Text("04-03-2025", style: TextStyle(fontSize: 14)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Text("Selesai", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.green.shade700)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
  ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
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
              _navItem("Beranda", Icons.home, () => setState(() => _selectedIndex = 0), _selectedIndex == 0),
              _navItem("Profil", Icons.person, () => setState(() => _selectedIndex = 2), _selectedIndex == 2),
            ],
          ),
        ),
        Positioned(
          bottom: 20,
          child: GestureDetector(
            onTap: () => setState(() => _selectedIndex = 1),
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

  Widget _navItem(String label, IconData icon, VoidCallback onTap, bool isActive) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? Colors.blue : Colors.grey),
          Text(label, style: TextStyle(color: isActive ? Colors.blue : Colors.grey, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  void _showAdminDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Anda tidak memiliki izin untuk\nmengakses halaman ini.\n\nSilakan hubungi administrator\njika membutuhkan akses\nsebagai Admin Gudang.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue[200],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                ),
                child: const Text("Oke", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
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
