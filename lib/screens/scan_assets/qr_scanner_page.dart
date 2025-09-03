import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QRScannerPage extends StatefulWidget {
  final Function(String) onQRScanned;

  const QRScannerPage({
    Key? key,
    required this.onQRScanned,
  }) : super(key: key);

  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  MobileScannerController cameraController = MobileScannerController();
  bool isFlashOn = false;
  bool isFrontCamera = false;
  bool hasScanned = false;
  String currentUser = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUser = prefs.getString('username') ?? '';
    });
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (hasScanned) return; // Prevent multiple scans
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? code = barcode.rawValue;
      if (code != null && code.isNotEmpty) {
        setState(() => hasScanned = true);
        HapticFeedback.mediumImpact();
        widget.onQRScanned(code);
        Navigator.pop(context);
        break;
      }
    }
  }

  void _toggleFlash() {
    cameraController.toggleTorch();
    setState(() => isFlashOn = !isFlashOn);
    HapticFeedback.lightImpact();
  }

  void _switchCamera() {
    cameraController.switchCamera();
    setState(() => isFrontCamera = !isFrontCamera);
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),
          // Simple top bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Close button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                // Camera controls
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: _toggleFlash,
                    ),
                    IconButton(
                      icon: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white, size: 24),
                      onPressed: _switchCamera,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Overlay with scanning area
          _buildScannerOverlay(),
          // Instructions and user info
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 40,
            left: 30,
            right: 30,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 40),
                const SizedBox(height: 12),
                const Text(
                  'Arahkan QR ke area kotak',
                  style: TextStyle(
                    fontFamily: 'Maison Bold',
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Scanner otomatis membaca QR code.',
                  style: TextStyle(
                    fontFamily: 'Maison Book',
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (currentUser.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.09),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      'User: @$currentUser',
                      style: const TextStyle(
                        fontFamily: 'Maison Book',
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return IgnorePointer(
      child: Container(
        decoration: ShapeDecoration(
          shape: QrScannerOverlayShape(
            borderColor: const Color(0xFF405189),
            borderRadius: 20,
            borderLength: 36,
            borderWidth: 6,
            cutOutSize: 240,
          ),
        ),
      ),
    );
  }
}

// Custom overlay shape for QR scanner - simple
class QrScannerOverlayShape extends ShapeBorder {
  const QrScannerOverlayShape({
    this.borderColor = Colors.blue,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 32,
    double? cutOutSize,
  }) : cutOutSize = cutOutSize ?? 220;

  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path _getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top + borderRadius)
        ..quadraticBezierTo(rect.left, rect.top, rect.left + borderRadius, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return _getLeftTopPath(rect)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;
    final borderOffset = borderWidth / 2;
    final _borderLength = borderLength > cutOutSize / 2 ? cutOutSize / 2 : borderLength;
    final _cutOutSize = cutOutSize < width ? cutOutSize : width - borderOffset;

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final boxPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final cutOutRect = Rect.fromLTWH(
      rect.left + width / 2 - _cutOutSize / 2 + borderOffset,
      rect.top + height / 2 - _cutOutSize / 2 + borderOffset,
      _cutOutSize - borderOffset * 2,
      _cutOutSize - borderOffset * 2,
    );

    // Draw overlay
    canvas.saveLayer(rect, backgroundPaint);
    canvas.drawRect(rect, backgroundPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)),
      boxPaint,
    );
    canvas.restore();

    // Draw border corners
    final borderRect = RRect.fromRectAndRadius(
      cutOutRect,
      Radius.circular(borderRadius),
    );

    // Top left corner
    canvas.drawPath(
      Path()
        ..moveTo(borderRect.left, borderRect.top + _borderLength)
        ..lineTo(borderRect.left, borderRect.top + borderRadius)
        ..quadraticBezierTo(borderRect.left, borderRect.top, borderRect.left + borderRadius, borderRect.top)
        ..lineTo(borderRect.left + _borderLength, borderRect.top),
      borderPaint,
    );
    // Top right corner
    canvas.drawPath(
      Path()
        ..moveTo(borderRect.right - _borderLength, borderRect.top)
        ..lineTo(borderRect.right - borderRadius, borderRect.top)
        ..quadraticBezierTo(borderRect.right, borderRect.top, borderRect.right, borderRect.top + borderRadius)
        ..lineTo(borderRect.right, borderRect.top + _borderLength),
      borderPaint,
    );
    // Bottom left corner
    canvas.drawPath(
      Path()
        ..moveTo(borderRect.left, borderRect.bottom - _borderLength)
        ..lineTo(borderRect.left, borderRect.bottom - borderRadius)
        ..quadraticBezierTo(borderRect.left, borderRect.bottom, borderRect.left + borderRadius, borderRect.bottom)
        ..lineTo(borderRect.left + _borderLength, borderRect.bottom),
      borderPaint,
    );
    // Bottom right corner
    canvas.drawPath(
      Path()
        ..moveTo(borderRect.right - _borderLength, borderRect.bottom)
        ..lineTo(borderRect.right - borderRadius, borderRect.bottom)
        ..quadraticBezierTo(borderRect.right, borderRect.bottom, borderRect.right, borderRect.bottom - borderRadius)
        ..lineTo(borderRect.right, borderRect.bottom - _borderLength),
      borderPaint,
    );
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
      borderRadius: borderRadius,
      borderLength: borderLength,
      cutOutSize: cutOutSize,
    );
  }
}