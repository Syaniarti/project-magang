// import 'package:asetcare/Screen/homescreen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:async';
// import 'package:asetcare/Screen/loginscreen.dart';

// class Splashscreen extends StatefulWidget {
//   @override
//   _SplashscreenState createState() => new _SplashscreenState();
// }

// class _SplashscreenState extends State<Splashscreen> {
//   @override
//   void initState() {
//     super.initState();
//     startLaunching();
//   }
//   startLaunching() async {
//     var duration = const Duration(seconds: 10);
//     return new Timer(duration, () {
//       Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (_) {
//         return new LoginScreen() ;
//       }));
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
//       statusBarColor: Color(0xfffbb448), 
//     ));
//     return Scaffold(
//       body: Container(
//         padding: EdgeInsets.symmetric(horizontal: 20),
//         height: MediaQuery.of(context).size.height,
//         decoration: BoxDecoration(
//             borderRadius: BorderRadius.all(Radius.circular(5)),
//             boxShadow: <BoxShadow>[
//               BoxShadow(
//                   color: Colors.grey.shade200,
//                   offset: Offset(2, 4),
//                   blurRadius: 5,
//                   spreadRadius: 2)
//             ],
//             gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [Color(0xfffbb448), Color(0xfff7892b)])),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             new Center(
//               child: new Image.asset(
//                 "assets/logo1.png",
//                 height: 70.0,
//                 width: 200.0,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }