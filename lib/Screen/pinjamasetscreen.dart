import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import 'aset_dipinjam_screen.dart';

class PinjamAsetScreen extends StatefulWidget {
  final Map<String, dynamic>? Aset;
  const PinjamAsetScreen({super.key, this.Aset});

  @override
  State<PinjamAsetScreen> createState() => _PinjamAsetScreenState();
}

class _PinjamAsetScreenState extends State<PinjamAsetScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  Uint8List? _webImage;
  final ImagePicker _picker = ImagePicker();

  String? selectedKondisi;
  String? selectedLokasi;
  DateTime selectedDate = DateTime.now();

  final _namaAsetController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _namaController = TextEditingController();
  final _teleponController = TextEditingController();

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
    if (!mounted) return; // 👈 CEK DULU

    _namaController.text = prefs.getString('nama') ?? '';
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
    if (_formKey.currentState!.validate()) {
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
          Uri.parse('http://127.0.0.1:8000/api/pinjamaset'),
        );

        request.headers['Accept'] = 'application/json';

        request.fields['Nama_Aset'] = _namaAsetController.text;
        request.fields['Serial_Number'] = _serialNumberController.text;
        request.fields['Nama_Peminjam'] = _namaController.text;
        request.fields['No_Telp'] = _teleponController.text;
        request.fields['Kondisi'] = selectedKondisi!;
        request.fields['Lokasi_Terkini'] = widget.Aset!['Lokasi_Terkini'];
        request.fields['Lokasi_Tujuan'] = selectedLokasi!;
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
              const SnackBar(content: Text("Data peminjaman disimpan!")),
            );
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AsetDipinjamScreen()),
              );
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Gagal: ${decoded['message'] ?? 'Terjadi kesalahan'}",
                ),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Gagal menyimpan data. Kode: ${response.statusCode}",
              ),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
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

  @override
  void dispose() {
    _namaAsetController.dispose();
    _serialNumberController.dispose();
    _namaController.dispose();
    _teleponController.dispose();
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
                        'Formulir Peminjaman',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Image.asset("assets/people1.png", width: 80, height: 80),
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

                  buildLabel('Nama Peminjam'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _namaController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  buildLabel('Nomor Telepon'),
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
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
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
                    initialValue: widget.Aset?['Lokasi_Terkini'] ?? '-',
                    readOnly: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  buildLabel('Lokasi Tujuan'),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedLokasi,
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
                        (value) => setState(() => selectedLokasi = value),
                    validator:
                        (value) =>
                            value == null ? 'Lokasi wajib dipilih' : null,
                  ),
                  const SizedBox(height: 12),

                  buildLabel('Tanggal Peminjaman'),
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
                      'Kirim',
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
