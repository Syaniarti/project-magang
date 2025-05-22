import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:asetcare/Screen/aset_tersedia_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GenerateQrScreen(),
    ),
  );
}

class GenerateQrScreen extends StatefulWidget {
  const GenerateQrScreen({super.key});

  @override
  State<GenerateQrScreen> createState() => _GenerateQrScreenState();
}

class _GenerateQrScreenState extends State<GenerateQrScreen> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController nomorSeriController = TextEditingController();
  final GlobalKey globalKey = GlobalKey();

  String? kondisi;
  String? lokasi;
  Uint8List? dokumentasi;
  String? qrData;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        dokumentasi = bytes;
      });
    }
  }

  void _generateQr() {
    final nama = namaController.text.trim();
    final nomorSeri = nomorSeriController.text.trim();
    final tanggalUpdate = DateTime.now().toString().split(' ')[0];

    if (nama.isNotEmpty &&
        nomorSeri.isNotEmpty &&
        kondisi != null &&
        lokasi != null &&
        dokumentasi != null) {
      setState(() {
        qrData = jsonEncode({
          'namaAset': nama,
          'nomorSeri': nomorSeri,
          'kondisi': kondisi,
          'lokasi': lokasi,
          'updateTerakhir': tanggalUpdate,
          'dokumentasi':
              'dokumentasi_${DateTime.now().millisecondsSinceEpoch}.png', // Simulasi nama file dokumentasi
        });
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi semua data terlebih dahulu')),
      );
    }
  }

  Future<void> _downloadQR() async {
    final status = await Permission.storage.request();
    if (!status.isGranted) return;

    try {
      if (globalKey.currentContext == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('QR belum siap untuk disimpan.')),
        );
        return;
      }

      await Future.delayed(const Duration(milliseconds: 300));
      RenderRepaintBoundary boundary =
          globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) throw Exception('Gagal konversi ke byte');

      Uint8List pngBytes = byteData.buffer.asUint8List();
      final result = await ImageGallerySaver.saveImage(
        pngBytes,
        quality: 100,
        name: 'qr_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (result['isSuccess'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('QR code berhasil disimpan ke Galeri')),
        );
      } else {
        throw Exception('Gagal menyimpan ke galeri');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan QR: $e')));
    }
  }

  Future<void> _tambahBarang() async {
    final nama = namaController.text.trim();
    final nomorSeri = nomorSeriController.text.trim();

    if (nama.isEmpty ||
        nomorSeri.isEmpty ||
        kondisi == null ||
        lokasi == null ||
        dokumentasi == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi semua data terlebih dahulu')),
      );
      return;
    }

    final url = Uri.parse('https://dummyjson.com/products/add');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': nama,
          'serialNumber': nomorSeri,
          'condition': kondisi,
          'location': lokasi,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Aset berhasil ditambahkan: ${responseData['title']}',
            ),
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AsetTersediaScreen(Aset: responseData),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menambahkan barang: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E467F),
      body: SafeArea(
        child: Center(
          child: Container(
            width: 320,
            margin: const EdgeInsets.symmetric(vertical: 30),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  const Text(
                    'Tambah Aset',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Image.asset("assets/box.png", width: 80, height: 80),
                  const SizedBox(height: 20),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          text: 'Nama Aset ',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: '*',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: namaController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          text: 'Serial Number ',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: '*',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: nomorSeriController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          text: 'Kondisi ',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: '*',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        value: kondisi,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items:
                            ['Baru', 'Baik', 'Rusak Ringan', 'Rusak Berat']
                                .map(
                                  (item) => DropdownMenuItem(
                                    value: item,
                                    child: Text(item),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) => setState(() => kondisi = value),
                        validator:
                            (value) =>
                                value == null ? 'Kondisi wajib dipilih' : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          text: 'Lokasi Terkini ',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: '*',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        value: lokasi,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items:
                            ['GI Banda Aceh', 'GI Meulaboh', 'GI Langsa']
                                .map(
                                  (item) => DropdownMenuItem(
                                    value: item,
                                    child: Text(item),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) => setState(() => lokasi = value),
                        validator:
                            (value) =>
                                value == null ? 'Lokasi wajib dipilih' : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  RichText(
                    text: const TextSpan(
                      text: 'Dokumentasi Aset ',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: '*',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                          dokumentasi == null
                              ? const Center(child: Icon(Icons.image, size: 40))
                              : ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  dokumentasi!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: _generateQr,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6CA9D4),
                        ),
                        child: const Text("QR Code"),
                      ),
                      ElevatedButton(
                        onPressed: _tambahBarang,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        child: const Text("Tambahkan Aset"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (qrData != null)
                    Column(
                      children: [
                        const Text(
                          'QR Code:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 10),
                        RepaintBoundary(
                          key: globalKey,
                          child: QrImageView(
                            data: qrData!,
                            version: QrVersions.auto,
                            size: 200.0,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: _downloadQR,
                          icon: const Icon(Icons.download),
                          label: const Text('Download QR'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
