import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:asetcare/Screen/homescreen.dart';

class PegawaiScreen extends StatefulWidget {
  const PegawaiScreen({super.key});

  @override
  State<PegawaiScreen> createState() => _PegawaiScreenState();
}

class _PegawaiScreenState extends State<PegawaiScreen> {
  List<Map<String, dynamic>> pegawaiList = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchPegawai();
  }

  Future<void> fetchPegawai() async {
    final url = Uri.parse(
      'http://127.0.0.1:8000/api/pegawais',
    ); // Ganti IP jika perlu
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          setState(() {
            pegawaiList = List<Map<String, dynamic>>.from(data['data']);
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
          print("Data kosong atau tidak valid");
        }
      } else {
        setState(() => isLoading = false);
        print("Gagal load data: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Error: $e");
    }
  }

  List<dynamic> get filteredPegawai {
    if (_searchQuery.isEmpty) return pegawaiList;
    return pegawaiList.where((pegawai) {
      final nama = (pegawai['nama'] ?? '').toString().toLowerCase();
      final nip = (pegawai['nip'] ?? '').toString().toLowerCase();
      return nama.contains(_searchQuery.toLowerCase()) ||
          nip.contains(_searchQuery.toLowerCase());
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
                  '👤 Daftar Pegawai',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredPegawai.isEmpty
                      ? const Center(child: Text('Pegawai tidak terdaftar.'))
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredPegawai.length,
                        itemBuilder: (context, index) {
                          final pegawai = filteredPegawai[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: const CircleAvatar(
                                radius: 24,
                                backgroundColor: Color(0xFFBFD7ED),
                                child: Icon(
                                  Icons.person,
                                  color: Color(0xFF2B3A55),
                                ),
                              ),
                              title: Text(
                                pegawai['nama'] ?? '',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                pegawai['nip'] ?? '',
                                style: const TextStyle(color: Colors.grey),
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
