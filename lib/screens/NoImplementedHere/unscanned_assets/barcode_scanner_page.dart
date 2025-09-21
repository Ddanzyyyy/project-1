import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'asset_item.dart';

class BarcodeScannerPage extends StatefulWidget {
  final String auditId;
  final AssetItem asset;
  final String selectedStatus;
  final String notes;

  const BarcodeScannerPage({
    Key? key,
    required this.auditId,
    required this.asset,
    required this.selectedStatus,
    required this.notes,
  }) : super(key: key);

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  MobileScannerController cameraController = MobileScannerController();
  bool isScanning = true;
  bool isProcessing = false;
  bool isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera permission is required to scan barcodes'), backgroundColor: Colors.red),
      );
      Navigator.pop(context);
    }
  }

  void _onDetect(BarcodeCapture capture) async {
    if (!isScanning || isProcessing) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final barcode = barcodes.first;
    if (barcode.rawValue == null || barcode.rawValue!.isEmpty) return;

    setState(() {
      isProcessing = true;
      isScanning = false;
    });

    // Kirim hasil scan ke halaman sebelumnya
    if (mounted) {
      Navigator.pop(context, barcode.rawValue!);
    }
  }

  void _toggleFlash() async {
    await cameraController.toggleTorch();
    setState(() {
      isFlashOn = !isFlashOn;
    });
  }

  void _switchCamera() {
    cameraController.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(controller: cameraController, onDetect: _onDetect),

          // Custom AppBar (simple & flat)
          SafeArea(
            child: Container(
              height: 56,
              color: Colors.black.withOpacity(0.6),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'Scan Barcode',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'MaisonBold',
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: Icon(isFlashOn ? Icons.flash_on : Icons.flash_off,
                        color: isFlashOn ? Colors.yellow : Colors.white),
                    onPressed: _toggleFlash,
                  ),
                  IconButton(
                    icon: Icon(Icons.flip_camera_android, color: Colors.white),
                    onPressed: _switchCamera,
                  ),
                ],
              ),
            ),
          ),

          // Simple overlay border
          Center(
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFF405189), width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          // Bottom info sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black.withOpacity(0.7),
              padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.asset.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'MaisonBold',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Kode: ${widget.asset.asset_code}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontFamily: 'MaisonBook',
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (widget.selectedStatus != 'pending' || widget.notes.isNotEmpty) ...[
                    SizedBox(height: 8),
                    Text(
                      'Status: ${widget.selectedStatus}${widget.notes.isNotEmpty ? " • ${widget.notes}" : ""}',
                      style: TextStyle(
                        color: Colors.green[300],
                        fontFamily: 'MaisonBook',
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  SizedBox(height: 8),
                  Text(
                    'Arahkan kamera ke barcode asset',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontFamily: 'MaisonBook',
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Processing overlay
          if (isProcessing)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF405189)),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Memproses barcode...',
                      style: TextStyle(
                        fontFamily: 'MaisonBold',
                        fontSize: 15,
                        color: Color(0xFF405189),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}