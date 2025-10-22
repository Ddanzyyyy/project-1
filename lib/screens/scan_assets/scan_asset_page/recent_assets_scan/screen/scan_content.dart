import 'package:Simba/screens/scan_assets/scan_asset_page/recent_assets_scan/widget/recent_asset_card.dart';
import 'package:Simba/screens/scan_assets/scan_asset_page/recent_assets_scan/screen/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:Simba/screens/scan_assets/scan_asset_page/recent_assets_scan/model/recent_asset_model.dart';

class ScanContent extends StatefulWidget {
  final TextEditingController qrController;
  final List<RecentAsset> recentAssets;
  final bool isLoading;
  final int totalAssets;
  final VoidCallback onOpenQRScanner;
  final VoidCallback onSimulateScan;
  final VoidCallback onViewAllAssets;
  final Function(String) onQRCodeChanged;

  const ScanContent({
    required this.qrController,
    required this.recentAssets,
    required this.isLoading,
    required this.totalAssets,
    required this.onOpenQRScanner,
    required this.onSimulateScan,
    required this.onViewAllAssets,
    required this.onQRCodeChanged,
    Key? key,
  }) : super(key: key);

  @override
  State<ScanContent> createState() => _ScanContentState();
}

class _ScanContentState extends State<ScanContent> {
  final Map<String, String?> photoCache = {};

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      children: [
        // const SizedBox(height: 8),
        const Text(
          'Scan Asset',
          style: TextStyle(
            fontFamily: 'Maison Bold',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF405189),
          ),
        ),
        const SizedBox(height: 12),
        _buildScannerCard(context),
        const SizedBox(height: 10),
        _buildManualInputSection(),
        const SizedBox(height: 20),
        _buildRecentAssetsSection(),
      ],
    );
  }

  Widget _buildScannerCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 7,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: widget.onOpenQRScanner,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/icons/welcome_page/barcode.png',
                    width: 44,
                    height: 44,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Tap to Scan',
                          style: TextStyle(
                            fontFamily: 'Maison Bold',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF405189),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Smart QR detection with auto-focus',
                          style: TextStyle(
                            fontFamily: 'Maison Book',
                            fontSize: 11,
                            color: Color(0xFF757575),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.green,
                        width: 0.7,
                      ),
                    ),
                    child: const Text(
                      'v5.1.1',
                      style: TextStyle(
                        fontFamily: 'Maison Book',
                        fontSize: 9,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildManualInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Or enter asset code manually:',
          style: TextStyle(
            fontFamily: 'Maison Book',
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: const Color(0xFF405189),
              width: 1,
            ),
          ),
          child: TextField(
            controller: widget.qrController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.qr_code, color: Color(0xFF405189), size: 20),
              hintText: 'Enter asset code...',
              hintStyle: TextStyle(
                fontFamily: 'Maison Book',
                color: Colors.grey[500],
                fontSize: 13,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(14),
              suffixIcon: widget.qrController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        widget.qrController.clear();
                        widget.onQRCodeChanged('');
                      },
                      icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
                    )
                  : null,
            ),
            style: const TextStyle(fontSize: 14, fontFamily: 'Maison Bold'),
            onChanged: widget.onQRCodeChanged,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: widget.qrController.text.isNotEmpty ? widget.onSimulateScan : null,
            icon: const Icon(Icons.search, color: Colors.white, size: 18),
            label: const Text(
              'Search Asset',
              style: TextStyle(
                fontFamily: 'Maison Bold',
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.qrController.text.isNotEmpty
                  ? const Color(0xFF405189)
                  : Colors.grey[400],
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: widget.qrController.text.isNotEmpty ? 2 : 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentAssetsSection() {
    // Tampilkan hanya 5 asset terbaru
    final List<RecentAsset> displayedAssets = widget.recentAssets.length > 5
        ? widget.recentAssets.sublist(0, 5)
        : widget.recentAssets;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Scan History',
              style: const TextStyle(
                fontFamily: 'Maison Bold',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF405189),
              ),
            ),
            TextButton(
              onPressed: widget.onViewAllAssets,
              child: Text(
                'View All History (${widget.recentAssets.length})',
                style: TextStyle(
                  fontFamily: 'Maison Book',
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        widget.isLoading
            ? SizedBox(
                height: 200,
                child: ShimmerLoading.recentAssetsList(),
              )
            : widget.recentAssets.isEmpty
                ? SizedBox(
                    height: 200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Belum ada scan asset',
                            style: TextStyle(
                              fontFamily: 'Maison Bold',
                              color: Colors.grey[600],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Scan QR untuk menambahkan recent scan',
                            style: TextStyle(
                              fontFamily: 'Maison Book',
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [
                      for (final asset in displayedAssets)
                        RecentAssetCard(
                          asset: asset,
                        ),
                    ],
                  ),
      ],
    );
  }
}