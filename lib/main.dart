import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:asetcare/Screen/loginscreen.dart';
import 'package:asetcare/Screen/homescreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  runApp(MyApp(isLoggedIn: token != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? const Homescreen() : const LoginScreen(),
    );
  }
}
