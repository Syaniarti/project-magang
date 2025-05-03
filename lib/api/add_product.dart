import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> addProduct() async {
  final url = Uri.parse('https://dummyjson.com/products/add');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'title': 'BMW Pencil',
      // Kamu bisa tambahkan field lain di sini sesuai kebutuhan
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    final data = jsonDecode(response.body);
    print('Produk berhasil ditambahkan: $data');
  } else {
    print('Gagal menambahkan produk. Status code: ${response.statusCode}');
  }
}
