import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';

import 'aset_tersedia_screen.dart';
import 'aset_dipinjam_screen.dart';

class KembalikanAsetScreen extends StatefulWidget {
  final Map<String, dynamic>? Aset;
  const KembalikanAsetScreen({super.key, this.Aset});

  @override
  State<KembalikanAsetScreen> createState() => _KembalikanAsetScreenState();
}

class _KembalikanAsetScreenState extends State<KembalikanAsetScreen> {
  final _formKey = GlobalKey<FormState>();

  File? _selectedImage;
  Uint8List? _webImage;
  final ImagePicker _picker = ImagePicker();

  final _namaAsetController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _namaController = TextEditingController();
  final _teleponController = TextEditingController();
  final lokasiPengembalianController = TextEditingController();

  String? selectedKondisi;

  @override
  void initState() {
    super.initState();
    _ambilDataProfil();
    if (widget.Aset != null) {
      _namaAsetController.text = widget.Aset!['Nama_Aset'] ?? '';
      _serialNumberController.text = widget.Aset!['Serial_Number'] ?? '';
    }
  }

  Future<void> _ambilDataProfil() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    _namaController.text = prefs.getString('nama') ?? '';
    _teleponController.text = prefs.getString('telepon') ?? '';
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() => _webImage = bytes);
      } else {
        setState(() => _selectedImage = File(pickedFile.path));
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null && _webImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Dokumentasi aset wajib diupload")),
      );
      return;
    }

    if (widget.Aset == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data aset tidak tersedia")),
      );
      return;
    }

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://127.0.0.1:8000/api/asetdikembalikan'),
      );

      request.fields['nama'] = _namaAsetController.text;
      request.fields['serial_number'] = _serialNumberController.text;
      request.fields['nama_peminjam'] = _namaController.text;
      request.fields['telepon'] = _teleponController.text;
      request.fields['kondisi_aset'] = selectedKondisi!;
      request.fields['lokasi_terkini'] = widget.Aset!['Lokasi_Tujuan'] ?? '-';
      request.fields['lokasi_pengembalian'] =
          lokasiPengembalianController.text;
      request.fields['tanggal_pengembalian'] =
          DateTime.now().toIso8601String();

      if (!kIsWeb) {
        var imageFile = await http.MultipartFile.fromPath(
          'dokumentasi_barang',
          _selectedImage!.path,
          contentType: MediaType(
            'image',
            path.extension(_selectedImage!.path).replaceFirst('.', ''),
          ),
        );
        request.files.add(imageFile);
      } else {
        var image = http.MultipartFile.fromBytes(
          'dokumentasi_barang',
          _webImage!,
          filename: 'upload.jpg',
          contentType: MediaType('image', 'jpg'),
        );
        request.files.add(image);
      }

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final decoded = jsonDecode(responseBody);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (decoded['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Data pengembalian disimpan!")),
          );
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AsetDipinjamScreen()),
            );
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal: ${decoded['message']}")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menyimpan. Code: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Widget buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: text,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _teleponController.dispose();
    _namaAsetController.dispose();
    _serialNumberController.dispose();
    lokasiPengembalianController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lokasiTerkini = widget.Aset?['Lokasi_Tujuan'] ?? '-';

    return Scaffold(
      backgroundColor: const Color(0xFF3C5A99),
      body: Center(
        child: Container(
          width: 370,
          margin: const EdgeInsets.symmetric(vertical: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Formulir Pengembalian',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Image.asset("assets/truck1.png", width: 80),
                  const SizedBox(height: 20),

                  buildLabel('Nama Aset'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _namaAsetController,
                    readOnly: true,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),

                  buildLabel('Serial Number'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _serialNumberController,
                    readOnly: true,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),

                  buildLabel('Nama Peminjam'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _namaController,
                    readOnly: true,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),

                  buildLabel('Nomor Telepon'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _teleponController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),

                  buildLabel('Kondisi Aset Saat Ini'),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedKondisi,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    hint: const Text('Pilih kondisi'),
                    items: [
                      'Baru',
                      'Baik',
                      'Rusak Ringan',
                      'Rusak Berat',
                      'Tidak Layak Pakai',
                    ]
                        .map((value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => selectedKondisi = value);
                    },
                    validator: (value) =>
                        value == null ? 'Kondisi wajib dipilih' : null,
                  ),
                  const SizedBox(height: 12),

                  buildLabel('Lokasi Terkini'),
                  const SizedBox(height: 6),
                  TextFormField(
                    initialValue: lokasiTerkini,
                    readOnly: true,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),

                  buildLabel('Lokasi Pengembalian'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: lokasiPengembalianController,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Lokasi wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),

                  buildLabel('Upload Dokumentasi Aset'),
                  const SizedBox(height: 6),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.upload_file),
                    label: const Text("Pilih Gambar"),
                  ),
                  const SizedBox(height: 10),
                  if (_selectedImage != null || _webImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _selectedImage != null
                          ? Image.file(_selectedImage!, width: 200)
                          : Image.memory(_webImage!, width: 200),
                    ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 14),
                    ),
                    child: const Text("Kembalikan Aset"),
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
