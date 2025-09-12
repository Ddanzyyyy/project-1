import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class AssetMobileScannerPage extends StatefulWidget {
  @override
  State<AssetMobileScannerPage> createState() => _AssetMobileScannerPageState();
}

class _AssetMobileScannerPageState extends State<AssetMobileScannerPage> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isDetected = false;
  bool _isFlashOn = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _toggleFlash() async {
    await cameraController.toggleTorch();
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("Scan Asset", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(
              _isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
            onPressed: _toggleFlash,
            tooltip: _isFlashOn ? 'Matikan Flash' : 'Nyalakan Flash',
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            fit: BoxFit.cover,
            onDetect: (barcodeCapture) {
              if (!_isDetected &&
                  barcodeCapture.barcodes.isNotEmpty &&
                  barcodeCapture.barcodes.first.rawValue != null) {
                setState(() {
                  _isDetected = true;
                });
                Navigator.pop(context, barcodeCapture.barcodes.first.rawValue);
              }
            },
          ),
            Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 3),
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.transparent,
                ),
              ),
            ),
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Arahkan kamera ke QR Code atau Barcode Asset',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Maison Book',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Bottom instructions
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.black54,
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Pastikan kode dalam jangkauan kamera',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Maison Book',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6B46C1),
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Batal'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}