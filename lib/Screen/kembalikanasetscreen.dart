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
  final dynamic aset;
  const KembalikanAsetScreen({Key? key, required this.aset}) : super(key: key);

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
  String? lokasiPengembalianValue;

  String? selectedKondisi;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _ambilDataProfil();
    if (widget.aset != null) {
      _namaAsetController.text = widget.aset!['Nama_Aset'] ?? '';
      _serialNumberController.text = widget.aset!['Serial_Number'] ?? '';
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

    if (widget.aset == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Data aset tidak tersedia")));
      return;
    }

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://127.0.0.1:8000/api/asetdikembalikan'),
      );

      //  final prefs = await SharedPreferences.getInstance();

      // final token = prefs.getString('token') ?? '';
      // request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      request.fields['peminjaman_id'] = widget.aset!['id'].toString();
      request.fields['Nama_Aset'] = _namaAsetController.text;
      request.fields['Serial_Number'] = _serialNumberController.text;
      request.fields['Nama_Pengembali'] = _namaController.text;
      request.fields['No_Telp'] = _teleponController.text;
      request.fields['Kondisi'] = selectedKondisi!;
      request.fields['Lokasi_Terkini'] = widget.aset!['Lokasi_Tujuan'] ?? '-';
      request.fields['Lokasi_Pengembalian'] = lokasiPengembalianValue ?? '-';
      request.fields['Tanggal_Peminjaman'] =  '${selectedDate.toIso8601String().substring(0,10)}';

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
              MaterialPageRoute(builder: (_) => const AsetTersediaScreen()),
            );
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal: ${decoded['message']}")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal menyimpan. Code: ${response.statusCode}"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
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
            const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  buildLabel('Serial Number'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _serialNumberController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  buildLabel('Nama Pengembali'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _namaController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  buildLabel('No Telp/WhatsApp'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _teleponController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  buildLabel('Kondisi'),
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
                    items:
                        [
                              'Baru',
                              'Baik',
                              'Rusak Ringan',
                              'Rusak Berat',
                              'Tidak Layak Pakai',
                            ]
                            .map(
                              (value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() => selectedKondisi = value);
                    },
                    validator:
                        (value) =>
                            value == null ? 'Kondisi wajib dipilih' : null,
                  ),
                  const SizedBox(height: 12),

                  buildLabel('Lokasi Terkini'),
                  const SizedBox(height: 6),
                  TextFormField(
                    initialValue: widget.aset?['Lokasi_Tujuan'] ?? '-',
                    readOnly: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  buildLabel('Lokasi Tujuan'),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: lokasiPengembalianValue,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Pilih lokasi tujuan'),
                    items:
                        ['ULTG Banda Aceh', 'ULTG Meulaboh', 'ULTG Langsa']
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(),
                    onChanged:
                        (value) =>
                            setState(() => lokasiPengembalianValue = value),
                    validator:
                        (value) =>
                            value == null ? 'Lokasi wajib dipilih' : null,
                  ),
                  const SizedBox(height: 12),

                  buildLabel('Tanggal Pengembalian'),
                  const SizedBox(height: 6),
                  TextFormField(
                    readOnly: true,
                    enabled: false,
                    initialValue:
                        '${selectedDate.day.toString().padLeft(2, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.year}',
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  buildLabel('Dokumentasi Aset'),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 170,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                          _webImage != null || _selectedImage != null
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child:
                                    kIsWeb
                                        ? Image.memory(
                                          _webImage!,
                                          fit: BoxFit.contain,
                                        )
                                        : Image.file(
                                          _selectedImage!,
                                          fit: BoxFit.contain,
                                        ),
                              )
                              : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.cloud_upload,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Klik untuk upload foto',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                    ),
                  ),
                  const SizedBox(height: 20),

                   ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF82B1FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      minimumSize: const Size.fromHeight(45),
                    ),
                    child: const Text(
                      'Kembalikan Aset',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
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
