import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class QRScannerPage extends StatefulWidget {
  final Function(String) onQRScanned;

  const QRScannerPage({Key? key, required this.onQRScanned}) : super(key: key);

  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage>
    with TickerProviderStateMixin {
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;
  bool _isScanning = false;
  bool _hasScannedResult = false;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _scanAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_scanController);
    
    // Initialize as ready but not scanning
    _initializeCamera();
  }

  void _initializeCamera() async {
    // Simulate camera initialization
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _isReady = true;
      });
    }
  }

  void _startScanning() {
    if (!_isReady || _isScanning) return;
    
    setState(() {
      _isScanning = true;
      _hasScannedResult = false;
    });
    
    _scanController.repeat();
    HapticFeedback.lightImpact();
    
    // Simulate scanning process
    _simulateQRDetection();
  }

  void _stopScanning() {
    setState(() {
      _isScanning = false;
    });
    _scanController.stop();
    _scanController.reset();
  }

  void _simulateQRDetection() async {
    // Simulate scanning delay (3-5 seconds)
    int scanDuration = 3 + Random().nextInt(3);
    await Future.delayed(Duration(seconds: scanDuration));
    
    if (mounted && _isScanning) {
      // Generate random QR code for simulation
      List<String> availableQRCodes = [
        'QR001IT',
        'QR045FN', 
        'QR023IT',
        'QR099NEW',
        'QR200PRJ',
        'QR300DV',
        'QR400ST'
      ];
      
      String detectedQR = availableQRCodes[Random().nextInt(availableQRCodes.length)];
      _onQRDetected(detectedQR);
    }
  }

  void _onQRDetected(String qrCode) {
    if (!_hasScannedResult && _isScanning) {
      setState(() {
        _hasScannedResult = true;
        _isScanning = false;
      });
      
      _scanController.stop();
      HapticFeedback.heavyImpact();
      
      _showScanResult(qrCode);
    }
  }

  void _showScanResult(String qrCode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 24),
            SizedBox(width: 8),
            Text(
              'QR Code Detected',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.qr_code, color: const Color(0xFF405189), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      qrCode,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF405189),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person, color: Colors.grey[600], size: 16),
                SizedBox(width: 4),
                Text(
                  'Scanned by: caccarehana',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.grey[600], 
                    fontSize: 12
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey[600], size: 16),
                SizedBox(width: 4),
                Text(
                  'Time: ${DateTime.now().toString().substring(0, 19)}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.grey[600], 
                    fontSize: 12
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _restartScanning();
            },
            child: const Text(
              'Scan Again',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close scanner
              widget.onQRScanned(qrCode); // Return result
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF405189),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Use This QR',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _restartScanning() {
    setState(() {
      _hasScannedResult = false;
    });
    _startScanning();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview simulation
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.grey[900]!,
                  Colors.black,
                  Colors.grey[900]!,
                ],
              ),
            ),
            child: Container(
              margin: EdgeInsets.all(50),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white24, width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt,
                      color: Colors.white54,
                      size: 48,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Camera View',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white54,
                        fontSize: 16,
                      ),
                    ),
                    if (!_isReady)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // QR Scanner Overlay
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isScanning 
                      ? const Color(0xFF405189)
                      : Colors.white54,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  // Corner decorations
                  _buildCornerDecoration(Alignment.topLeft),
                  _buildCornerDecoration(Alignment.topRight),
                  _buildCornerDecoration(Alignment.bottomLeft),
                  _buildCornerDecoration(Alignment.bottomRight),
                  
                  // Scanning line animation
                  if (_isScanning)
                    AnimatedBuilder(
                      animation: _scanAnimation,
                      builder: (context, child) {
                        return Positioned(
                          top: _scanAnimation.value * 250,
                          left: 10,
                          right: 10,
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  const Color(0xFF405189),
                                  Colors.transparent,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      },
                    ),
                  
                  // Status indicator
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isScanning) ...[
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  const Color(0xFF405189),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Scanning...',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ] else if (!_isReady) ...[
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Loading camera...',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ] else if (_hasScannedResult) ...[
                            Icon(Icons.check_circle, color: Colors.green, size: 16),
                            SizedBox(width: 8),
                            Text(
                              'Scan Complete!',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ] else ...[
                            Icon(Icons.qr_code_scanner, color: Colors.white, size: 16),
                            SizedBox(width: 8),
                            Text(
                              'Ready to scan',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Top Bar
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Simulate flash toggle
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Flash toggled'),
                          duration: Duration(seconds: 1),
                          backgroundColor: const Color(0xFF405189),
                        ),
                      );
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.flash_auto, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'QR Code Scanner',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isScanning 
                        ? 'Scanning for QR codes...' 
                        : 'Tap the scan button to start',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Control Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Manual Input Button
                      ElevatedButton.icon(
                        onPressed: _isScanning ? null : () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.keyboard, 
                          color: _isScanning ? Colors.grey : Colors.white,
                          size: 18,
                        ),
                        label: Text(
                          'Manual Input',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: _isScanning ? Colors.grey : Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isScanning ? Colors.grey[800] : Colors.white24,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      
                      // Scan Button
                      ElevatedButton.icon(
                        onPressed: _isReady && !_hasScannedResult
                            ? (_isScanning ? _stopScanning : _startScanning)
                            : null,
                        icon: Icon(
                          _isScanning ? Icons.stop : Icons.qr_code_scanner,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: Text(
                          _isScanning ? 'Stop Scan' : 'Start Scan',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isReady && !_hasScannedResult
                              ? (_isScanning ? Colors.red : const Color(0xFF405189))
                              : Colors.grey[600],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // User info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person, color: Colors.white70, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'User: caccarehana',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.access_time, color: Colors.white70, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        DateTime.now().toString().substring(0, 19),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCornerDecoration(Alignment alignment) {
    Color cornerColor = _isScanning 
        ? const Color(0xFF405189)
        : Colors.white54;
        
    return Align(
      alignment: alignment,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          border: Border(
            top: alignment == Alignment.topLeft || alignment == Alignment.topRight
                ? BorderSide(color: cornerColor, width: 4)
                : BorderSide.none,
            bottom: alignment == Alignment.bottomLeft || alignment == Alignment.bottomRight
                ? BorderSide(color: cornerColor, width: 4)
                : BorderSide.none,
            left: alignment == Alignment.topLeft || alignment == Alignment.bottomLeft
                ? BorderSide(color: cornerColor, width: 4)
                : BorderSide.none,
            right: alignment == Alignment.topRight || alignment == Alignment.bottomRight
                ? BorderSide(color: cornerColor, width: 4)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }
}