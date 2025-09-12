// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class AssetMobileScannerPage extends StatefulWidget {
  @override
  State<AssetMobileScannerPage> createState() => _AssetMobileScannerPageState();
}

class _AssetMobileScannerPageState extends State<AssetMobileScannerPage> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isDetected = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("Scan Asset", style: TextStyle(color: Colors.white)),
        // actions: [
        //   IconButton(
        //     icon: ValueListenableBuilder(
        //       valueListenable: cameraController.torchState,
        //       builder: (context, state, child) {
        //         if (state == TorchState.off) {
        //           return Icon(Icons.flash_off, color: Colors.white);
        //         } else {
        //           return Icon(Icons.flash_on, color: Colors.yellow);
        //         }
        //       },
        //     ),
        //     onPressed: () => cameraController.toggleTorch(),
        //   ),
        //   IconButton(
        //     icon: ValueListenableBuilder(
        //       valueListenable: cameraController.cameraFacingState,
        //       builder: (context, state, child) {
        //         if (state == CameraFacing.front) {
        //           return Icon(Icons.camera_front, color: Colors.white);
        //         } else {
        //           return Icon(Icons.camera_rear, color: Colors.white);
        //         }
        //       },
        //     ),
        //     onPressed: () => cameraController.switchCamera(),
        //   ),
        // ],
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
          // Overlay with scanning instructions
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