import 'package:Simba/screens/home_screen/logistic_asset_scan_menu/asset_info_widget.dart';
import 'package:Simba/screens/home_screen/logistic_asset_scan_menu/asset_mobile_scanner_page.dart';
import 'package:Simba/screens/home_screen/logistic_asset_scan_menu/asset_upload_dialog.dart';
import 'package:Simba/screens/home_screen/lost_assets/compact_lost_asset_card.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:Simba/screens/home_screen/logistic_asset/logistic_asset_service.dart';
import 'package:Simba/screens/home_screen/logistic_asset/logistic_asset_model.dart';

class LogisticAssetScanMenuPage extends StatefulWidget {
  @override
  State<LogisticAssetScanMenuPage> createState() =>
      _LogisticAssetScanMenuPageState();
}

class _LogisticAssetScanMenuPageState extends State<LogisticAssetScanMenuPage> {
  String _scanStatus = '';
  LogisticAsset? _scannedAsset;
  bool _isLoadingAsset = false;
  String? _lastScannedAssetNo;

  Future<void> _scanAsset() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera permission required for scanning')),
      );
      return;
    }

    final scanResult = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AssetMobileScannerPage(),
      ),
    );

    if (scanResult != null && scanResult is String && scanResult.isNotEmpty) {
      await _loadAssetInfo(scanResult);
    }
  }

  Future<void> _loadAssetInfo(String assetNo) async {
    setState(() {
      _isLoadingAsset = true;
      _scanStatus = 'Mencari asset...';
      _scannedAsset = null;
      _lastScannedAssetNo = assetNo;
    });

    try {
      final asset = await LogisticAssetService.getLogisticAssetByAssetNo(assetNo);

      setState(() {
        _isLoadingAsset = false;
        if (asset != null) {
          _scannedAsset = asset;
          _scanStatus = 'Asset ditemukan!';
        } else {
          _scanStatus = 'Asset dengan nomor $assetNo tidak ditemukan.';
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingAsset = false;
        _scanStatus = 'Error: ${e.toString()}';
      });
    }
  }

  Future<void> _refreshAssetInfo() async {
    if (_lastScannedAssetNo != null) {
      await _loadAssetInfo(_lastScannedAssetNo!);
    } else {
      setState(() {
        _scanStatus = '';
        _scannedAsset = null;
      });
    }
  }

  void _showUploadDialog() {
    if (_scannedAsset == null) return;

    showDialog(
      context: context,
      builder: (context) => AssetUploadDialog(asset: _scannedAsset!),
    ).then((result) {
      if (result == true && _lastScannedAssetNo != null) {
        _refreshAssetInfo();
        setState(() {
          _scanStatus = 'Foto berhasil diupload!';
        });
      }
    });
  }

  void _showManualInputDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Input Asset No',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Maison Bold',
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Masukkan Asset No',
                  hintStyle: TextStyle(fontSize: 14, fontFamily: "Maison Book"),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              if (controller.text.trim().isNotEmpty) {
                _loadAssetInfo(controller.text.trim());
              }
            },
            child: Text('Cari'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(
          'Scan Logistic Asset',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
            fontFamily: 'Maison Bold',
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAssetInfo,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), 
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF405189), Color(0xFF405189)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Icon(
                            Icons.qr_code_scanner,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Asset Scanner',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Maison Bold',
                                ),
                              ),
                              Text(
                                'Scan Bar Code atau Barcode untuk mencari asset',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 12,
                                  fontFamily: 'Maison Book',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Pilih Jenis Input',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                  fontFamily: 'Maison Bold',
                ),
              ),
              const SizedBox(height: 16),

              _buildScanOption(
                title: 'Scan Barcode',
                subtitle: 'Scan Barcode untuk asset',
                icon: Icons.qr_code_2,
                color: Color(0xFF10B981),
                onTap: _scanAsset,
              ),

              const SizedBox(height: 12),

              _buildScanOption(
                title: 'Input Manual',
                subtitle: 'Masukkan Asset No secara manual',
                icon: Icons.keyboard,
                color: Color(0xFF3B82F6),
                onTap: _showManualInputDialog,
              ),

              const SizedBox(height: 24),

              if (_isLoadingAsset) ...[
                Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF405189)),
                      ),
                      SizedBox(height: 16),
                      Text(
                        _scanStatus,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontFamily: 'Maison Book',
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Asset Info Widget
              if (_scannedAsset != null) ...[
                AssetInfoWidget(
                  asset: _scannedAsset!,
                ),
              ],

              // Status Message
              if (_scanStatus.isNotEmpty && !_isLoadingAsset && _scannedAsset == null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _scanStatus.contains('Error')
                        ? Colors.red[50]
                        : Colors.orange[50],
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: _scanStatus.contains('Error')
                          ? Colors.red[200]!
                          : Colors.orange[200]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _scanStatus.contains('Error')
                            ? Icons.error
                            : Icons.warning,
                        color: _scanStatus.contains('Error')
                            ? Colors.red[600]
                            : Colors.orange[600],
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _scanStatus,
                          style: TextStyle(
                            color: _scanStatus.contains('Error')
                                ? Colors.red[700]
                                : Colors.orange[700],
                            fontFamily: 'Maison Book',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    double textSize = 12,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                      fontFamily: 'Maison Bold',
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: textSize,
                      color: Colors.grey[600],
                      fontFamily: 'Maison Book',
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}