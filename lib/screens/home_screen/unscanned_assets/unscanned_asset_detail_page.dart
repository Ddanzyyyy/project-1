import 'package:Simba/screens/home_screen/unscanned_assets/asset_info_card.dart';
import 'package:Simba/screens/home_screen/unscanned_assets/save_status_card.dart';
import 'package:Simba/screens/home_screen/unscanned_assets/status_and_notes_card.dart';
import 'package:flutter/material.dart';
import 'asset_item.dart';
import 'barcode_scanner_page.dart';
import 'unscanned_asset_service.dart';

class UnscannedAssetDetailPage extends StatefulWidget {
  final AssetItem asset;
  final String auditId;
  final VoidCallback onAssetScanned;

  UnscannedAssetDetailPage({
    required this.asset,
    required this.auditId,
    required this.onAssetScanned,
  });

  @override
  State<UnscannedAssetDetailPage> createState() =>
      _UnscannedAssetDetailPageState();
}

class _UnscannedAssetDetailPageState extends State<UnscannedAssetDetailPage> {
  bool isLoading = false;
  bool isLoadingStatus = false;
  String selectedStatus = 'pending';
  final TextEditingController notesController = TextEditingController();
  Map<String, dynamic>? savedTempStatus;
  bool hasExistingStatus = false;

  final List<Map<String, dynamic>> statusOptions = [
    {'value': 'pending', 'label': 'Pending', 'color': Colors.grey[600]},
    {'value': 'needs_verification', 'label': 'Perlu Verifikasi', 'color': Colors.orange[600]},
    {'value': 'damaged', 'label': 'Rusak', 'color': Colors.red[600]},
    {'value': 'missing', 'label': 'Hilang', 'color': Colors.red[800]},
    {'value': 'relocated', 'label': 'Dipindahkan', 'color': Colors.blue[600]},
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingTempStatus();
  }

  Future<void> _loadExistingTempStatus() async {
    setState(() => isLoadingStatus = true);
    try {
      final tempStatus = await UnscannedAssetService.getTemporaryStatus(
        widget.auditId,
        widget.asset.id.toString(),
      );
      if (tempStatus != null) {
        setState(() {
          savedTempStatus = tempStatus;
          hasExistingStatus = true;
          selectedStatus = tempStatus['temp_status'] ?? 'pending';
          notesController.text = tempStatus['notes'] ?? '';
        });
      }
    } catch (e) {
      print('Error loading temp status: $e');
    }
    setState(() => isLoadingStatus = false);
  }

  Future<void> manualScan() async {
    setState(() => isLoading = true);
    try {
      final success = await UnscannedAssetService.manualScanAssetWithStatus(
        widget.auditId,
        widget.asset.id.toString(),
        selectedStatus,
        notesController.text,
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.orange,
            content: Text(
              '${widget.asset.name} ditandai manual!',
              style: TextStyle(fontFamily: 'MaisonBook', fontSize: 12),
            ),
          ),
        );
        widget.onAssetScanned();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Gagal menandai manual',
              style: TextStyle(fontFamily: 'MaisonBook', fontSize: 12),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error: $e',
              style: TextStyle(fontFamily: 'MaisonBook', fontSize: 12)),
        ),
      );
    }
    setState(() => isLoading = false);
  }

  Future<void> _navigateToBarcodeScan() async {
    final scannedBarcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => BarcodeScannerPage(
          asset: widget.asset,
          auditId: widget.auditId,
          selectedStatus: selectedStatus,
          notes: notesController.text,
        ),
      ),
    );

    if (scannedBarcode != null && scannedBarcode.isNotEmpty) {
      setState(() => isLoading = true);
      try {
        final success = await UnscannedAssetService.scanAssetWithStatus(
          widget.auditId,
          scannedBarcode,
          selectedStatus,
          notesController.text,
        );
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Color(0xFF405189),
              content: Text(
                '${widget.asset.name} berhasil discan!',
                style: TextStyle(fontFamily: 'MaisonBook', fontSize: 12),
              ),
            ),
          );
          widget.onAssetScanned();
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                'Gagal scan asset',
                style: TextStyle(fontFamily: 'MaisonBook', fontSize: 12),
              ),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Error: $e',
                style: TextStyle(fontFamily: 'MaisonBook', fontSize: 12)),
          ),
        );
      }
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xFF405189),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Detail Asset',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'MaisonBold',
            ),
          ),
          centerTitle: true,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            AssetInfoCard(asset: widget.asset),
            SizedBox(height: 20),
            if (hasExistingStatus && savedTempStatus != null)
              SavedStatusCard(savedTempStatus: savedTempStatus!, statusOptions: statusOptions),
            StatusAndNotesCard(
              selectedStatus: selectedStatus,
              statusOptions: statusOptions,
              notesController: notesController,
              onStatusChanged: (val) => setState(() => selectedStatus = val),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _navigateToBarcodeScan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF405189),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.qr_code_scanner, size: 18),
                              SizedBox(width: 8),
                              Text('Scan Barcode', style: TextStyle(fontFamily: 'MaisonBold', fontSize: 14, fontWeight: FontWeight.w600)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : manualScan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.edit, size: 18),
                              SizedBox(width: 8),
                              Text('Manual', style: TextStyle(fontFamily: 'MaisonBold', fontSize: 14, fontWeight: FontWeight.w600)),
                            ],
                          ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue[200]!, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                      SizedBox(width: 8),
                      Text('Panduan Scan', style: TextStyle(fontFamily: 'MaisonBold', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.blue[700])),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Isi status dan catatan terlebih dahulu (opsional)\n'
                    '• Scan Barcode: Buka kamera untuk scan barcode fisik\n'
                    '• Manual: Tandai manual jika barcode rusak/tidak bisa dibaca\n'
                    '• Status dan catatan akan otomatis tersimpan setelah scan berhasil',
                    style: TextStyle(fontFamily: 'MaisonBook', fontSize: 10, color: Colors.blue[600], height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}