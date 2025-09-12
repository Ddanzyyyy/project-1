import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'logistic_asset_service.dart';
import 'logistic_asset_detail_page.dart';

class LogisticAssetScanPage extends StatefulWidget {
  @override
  State<LogisticAssetScanPage> createState() => _LogisticAssetScanPageState();
}

class _LogisticAssetScanPageState extends State<LogisticAssetScanPage> {
  bool isSearching = false;
  String? lastCode;
  bool isFlashOn = false;
  late MobileScannerController cameraController;

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _toggleFlash() async {
    try {
      await cameraController.toggleTorch();
      setState(() {
        isFlashOn = !isFlashOn;
      });
    } catch (e) {
      print('Error toggling flash: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tidak dapat mengaktifkan flash'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _onDetect(BarcodeCapture capture) async {
    if (isSearching) return;

    final code = capture.barcodes.first.rawValue;
    if (code == null || code == lastCode) return;

    setState(() {
      isSearching = true;
      lastCode = code;
    });

    try {
      final asset = await LogisticAssetService.getLogisticAssetByAssetNo(code);

      setState(() => isSearching = false);

      if (asset != null) {
        // Asset found - navigate to detail
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => LogisticAssetDetailPage(asset: asset),
          ),
        );
      } else {
        _showAssetNotFoundDialog(code);
      }
    } catch (e) {
      setState(() => isSearching = false);
      _showErrorDialog('Error searching asset: $e');
    }
  }

  void _showAssetNotFoundDialog(String assetNo) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Row(
          children: [
            Icon(Icons.search_off, color: Colors.grey[600], size: 20),
            SizedBox(width: 8),
            Text(
              'Asset Tidak Ditemukan',
              style: TextStyle(
                fontFamily: 'Maison Bold',
                fontSize: 16,
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          'Asset dengan nomor "$assetNo" tidak ditemukan dalam database.',
          style: TextStyle(
            fontFamily: 'Maison Book',
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                lastCode = null;
                isSearching = false;
              });
            },
            child: Text(
              'Scan Lagi',
              style: TextStyle(
                fontFamily: 'Maison Book',
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'Kembali',
              style: TextStyle(
                fontFamily: 'Maison Bold',
                color: Color(0xFF405189),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
            SizedBox(width: 8),
            Text(
              'Informasi',
              style: TextStyle(
                fontFamily: 'Maison Bold',
                fontSize: 16,
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            fontFamily: 'Maison Book',
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                lastCode = null;
                isSearching = false;
              });
            },
            child: Text(
              'Coba Lagi',
              style: TextStyle(
                fontFamily: 'Maison Bold',
                color: Color(0xFF405189),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        elevation: 0,
        title: Text(
          'Scan Asset',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
            fontFamily: 'Maison Bold',
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white70, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: isFlashOn ? Colors.yellow : Colors.white70,
              size: 24,
            ),
            onPressed: _toggleFlash,
            tooltip: isFlashOn ? 'Matikan Flash' : 'Nyalakan Flash',
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),
          
          // Scanning frame overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white60,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),



          // Instructions at bottom
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                margin: EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Arahkan kamera ke QR Code atau Barcode',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontFamily: 'Maison Book',
                  ),
                ),
              ),
            ),
          ),

          // Subtle loading indicator
          if (isSearching)
            Container(
              color: Colors.black45,
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Color(0xFF405189),
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Mencari asset...',
                        style: TextStyle(
                          fontFamily: 'Maison Book',
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}