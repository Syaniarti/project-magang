import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> login(username, password) async {
  final url = Uri.parse('https://dummyjson.com/auth/login');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'username': username,
      'password': password,
      'expiresInMins': 30, // optional, default is 60 kalau di server
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print('Login successful!');
    print(data);
  } else {
    print('Login failed with status: ${response.statusCode}');
    print(response.body);
  }
}
