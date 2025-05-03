import 'dart:io';
import 'package:asetcare/Screen/aset_dipinjam_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';


class PinjamAsetScreen extends StatefulWidget {
  const PinjamAsetScreen({super.key});

  @override
  State<PinjamAsetScreen> createState() => _PinjamAsetScreenState();
}

class _PinjamAsetScreenState extends State<PinjamAsetScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedKondisi;
  String? selectedLokasi;
  DateTime selectedDate = DateTime.now();

  File? _selectedImage;
  Uint8List? _webImage;
  final ImagePicker _picker = ImagePicker();

  final _namaController = TextEditingController();
  final _teleponController = TextEditingController();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
        });
      } else {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _teleponController.dispose();
    super.dispose();
  }

  Widget buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: text,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const TextSpan(
              text: ' *',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedImage == null && _webImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Dokumentasi aset wajib diupload"),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data peminjaman disimpan!")),
      );

      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const AsetDipinjamScreen(),
          ),
        );
      });
    }
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
                        'Formulir peminjaman',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Image.asset("assets/people1.png", width: 80, height: 80),
                  const SizedBox(height: 20),

                  buildLabel('Nama Lengkap'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _namaController,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    validator: (value) =>
                        value == null || value.trim().isEmpty ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),

                  buildLabel('Nomor Telepon'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _teleponController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    validator: (value) =>
                        value == null || value.trim().isEmpty ? 'Nomor wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),

                  buildLabel('Kondisi'),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedKondisi,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    hint: const Text('Pilih kondisi'),
                    items: ['Baru', 'Baik', 'Rusak Ringan', 'Rusak Berat', 'Tidak Layak Pakai']
                        .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                        .toList(),
                    onChanged: (value) => setState(() => selectedKondisi = value),
                    validator: (value) => value == null ? 'Kondisi wajib dipilih' : null,
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  const SizedBox(height: 12),

                  buildLabel('Lokasi Tujuan'),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedLokasi,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    hint: const Text('Pilih lokasi tujuan'),
                    items: ['ULTG Banda Aceh', 'ULTG Meulaboh', 'ULTG Langsa']
                        .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                        .toList(),
                    onChanged: (value) => setState(() => selectedLokasi = value),
                    validator: (value) => value == null ? 'Lokasi wajib dipilih' : null,
                    dropdownColor: Colors.white,
                  ),
                  const SizedBox(height: 12),

                  buildLabel('Tanggal Peminjaman'),
                  const SizedBox(height: 6),
                  TextFormField(
                    readOnly: true,
                    enabled: false,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    controller: TextEditingController(
                      text:
                          '${selectedDate.day.toString().padLeft(2, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.year}',
                    ),
                  ),
                  const SizedBox(height: 12),

                  buildLabel('Dokumentasi Aset'),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _webImage != null || _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: kIsWeb
                                  ? Image.memory(_webImage!, fit: BoxFit.contain)
                                  : Image.file(_selectedImage!, fit: BoxFit.contain),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.cloud_upload, size: 40, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Klik untuk upload foto', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF82B1FF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      minimumSize: const Size.fromHeight(45),
                    ),
                    child: const Text('Kirim', style: TextStyle(fontSize: 16, color: Colors.white)),
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
