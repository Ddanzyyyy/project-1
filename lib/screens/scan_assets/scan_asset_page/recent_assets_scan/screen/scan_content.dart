import 'package:Simba/screens/scan_assets/scan_asset_page/recent_assets_scan/widget/recent_asset_card.dart';
import 'package:Simba/screens/scan_assets/scan_asset_page/recent_assets_scan/screen/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:Simba/screens/scan_assets/scan_asset_page/recent_assets_scan/model/recent_asset_model.dart';

class ScanContent extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Scan Asset QR Code',
            style: TextStyle(
              fontFamily: 'Maison Bold',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF405189),
            ),
          ),
          const SizedBox(height: 12),
          _buildScannerCard(),
          const SizedBox(height: 10),
          _buildManualInputSection(),
          const SizedBox(height: 20),
          _buildRecentAssetsSection(),
        ],
      ),
    );
  }

  Widget _buildScannerCard() {
    return Container(
      width: double.infinity,
      height: 170,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            const Color(0xFFFFFFFF),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF405189), width: 2),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.grey.withOpacity(0.1),
        //     blurRadius: 10,
        //     offset: const Offset(0, 4),
        //   ),
        // ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onOpenQRScanner,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF405189),
                      const Color(0xFF405189).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    // BoxShadow(
                    //   color: const Color(0xFF405189).withOpacity(0.3),
                    //   blurRadius: 15,
                    //   offset: const Offset(0, 5),
                    // ),
                  ],
                ),
                child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 12),
              const Text(
                'Tap to Open Mobile Scanner',
                style: TextStyle(
                  fontFamily: 'Maison Bold',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF405189),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Smart QR detection with auto-focus',
                style: TextStyle(
                  fontFamily: 'Maison Book',
                  fontSize: 11,
                  color: const Color(0xFF757575),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Enhanced Scanner v5.1.1',
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
          ),
          child: TextField(
            controller: qrController,
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
              suffixIcon: qrController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        qrController.clear();
                        onQRCodeChanged('');
                      },
                      icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
                    )
                  : null,
            ),
            style: const TextStyle(fontSize: 14, fontFamily: 'Maison Bold'),
            onChanged: onQRCodeChanged,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: qrController.text.isNotEmpty ? onSimulateScan : null,
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
              backgroundColor: qrController.text.isNotEmpty
                  ? const Color(0xFF405189)
                  : Colors.grey[400],
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: qrController.text.isNotEmpty ? 2 : 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentAssetsSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Assets (${recentAssets.length})',
              style: const TextStyle(
                fontFamily: 'Maison Bold',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF405189),
              ),
            ),
            TextButton(
              onPressed: onViewAllAssets,
              child: Text(
                'View All ($totalAssets)',
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
        SizedBox(
          height: 200,
          child: isLoading
              ? ShimmerLoading.recentAssetsList()
              : recentAssets.isEmpty
                  ? Center(
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
                    )
                  : ListView.builder(
                      itemCount: recentAssets.length,
                      itemBuilder: (context, index) {
                        return RecentAssetCard(asset: recentAssets[index]);
                      },
                    ),
        ),
      ],
    );
  }
}