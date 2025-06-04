import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:asetcare/Screen/homescreen.dart';
import 'package:asetcare/Screen/profilscreen.dart';
import 'package:asetcare/Screen/hasilqrscreen.dart';


class Qrscanscreen extends StatefulWidget {
  const Qrscanscreen({super.key});

  @override
  State<Qrscanscreen> createState() => _Qrscanscreen();
}

class _Qrscanscreen extends State<Qrscanscreen> {
  int _selectedIndex = 0;
  final MobileScannerController controller = MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates);
  bool isFlashOn = false;
  bool? cameraAllowed; // nullable
  String? qrData;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
  final status = await Permission.camera.request();
  setState(() {
    cameraAllowed = status.isGranted;
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildBody() {
  if (_selectedIndex == 1) {
    if (cameraAllowed == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!cameraAllowed!) {
      return const Center(child: Text("Izin kamera tidak diberikan."));
    }

    return Stack(
      children: [
        MobileScanner(
          controller: controller,
          onDetect: (BarcodeCapture capture) {
            if (capture.barcodes.isNotEmpty) {
              final String? code = capture.barcodes.first.rawValue;
              if (code != null && qrData == null) {
                controller.stop();
                setState(() => qrData = code);
                _showQrResult(code);
              }
            }
          },
        ),
        const Positioned(
          top: 80,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              'Scan QRCode',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _controlButton(
                Icons.flash_on,
                isFlashOn ? Colors.yellow : Colors.white,
                _toggleFlash,
              ),
              _controlButton(
                Icons.cameraswitch,
                Colors.white,
                _switchCamera,
              ),
            ],
          ),
        ),
      ],
    );
  } else if (_selectedIndex == 0) {
    return const Homescreen(); // <- tampilkan halaman beranda
  } else if (_selectedIndex == 2) {
    return const ProfilScreen(); // <- tampilkan halaman profil
  }

  return const SizedBox.shrink();
}


  Widget _buildBottomNavBar(BuildContext context) {
  return Stack(
    alignment: Alignment.center,
    children: [
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          border: Border.all(
            color: Colors.black,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem("Beranda", Icons.home, 0),
            _navItem("Profil", Icons.person, 2),
          ],
        ),
      ),
      Positioned(
        bottom: 20,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedIndex = 1;
            });
          },
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF6CA9D4),
              border: Border.all(color: Colors.black, width: 3),
            ),
            child: const Icon(
              Icons.qr_code,
              size: 34,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ],
  );
}

Widget _navItem(String label, IconData icon, int index) {
  bool isActive = _selectedIndex == index;
  return GestureDetector(
    onTap: () {
      setState(() {
        _selectedIndex = index;
      });
    },
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isActive ? Colors.blue : Colors.grey),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.blue : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    ),
  );
}


  Widget _controlButton(IconData icon, Color color, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, color: color, size: 35),
      onPressed: onPressed,
    );
  }

 void _toggleFlash() async {
  await controller.toggleTorch();
  setState(() {
    isFlashOn = !isFlashOn;
  });
}

  void _switchCamera() {
    controller.switchCamera();
  }

void _showQrResult(String data) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => HasilQrScreen(qrData: data),
    ),
  ).then((_) {
    controller.start();
    setState(() => qrData = null);
  });
}

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
