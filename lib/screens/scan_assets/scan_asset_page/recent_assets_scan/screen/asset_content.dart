import 'package:flutter/material.dart';
import 'package:Simba/screens/scan_assets/scan_asset_page/recent_assets_scan/widget/asset_card.dart';
import 'package:Simba/screens/scan_assets/scan_asset_page/recent_assets_scan/widget/recent_asset_card.dart';
import 'package:Simba/screens/scan_assets/scan_asset_page/recent_assets_scan/screen/shimmer_loading.dart';
import 'package:Simba/screens/scan_assets/scan_asset_page/recent_assets_scan/model/asset.dart';
import 'package:Simba/screens/scan_assets/scan_asset_page/recent_assets_scan/model/recent_asset_model.dart';

class AssetsContent extends StatefulWidget {
  final TextEditingController searchController;
  final List<Asset> scannedAssets;
  final List<Asset> unscannedAssets;
  final List<RecentAsset> recentScannedAssets;
  final bool isLoading;
  final Function(String) onFilterAssets;
  final String Function(DateTime?) formatUpdatedTimeWIB;

  const AssetsContent({
    required this.searchController,
    required this.scannedAssets,
    required this.unscannedAssets,
    required this.recentScannedAssets,
    required this.isLoading,
    required this.onFilterAssets,
    required this.formatUpdatedTimeWIB,
    Key? key,
  }) : super(key: key);

  @override
  State<AssetsContent> createState() => _AssetsContentState();
}

class _AssetsContentState extends State<AssetsContent> {
  int selectedPage = 0; // 0: scannedAssets, 1: unscannedAssets
  // In-memory photo cache
  final Map<String, String?> photoCache = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeaderTabs(),
        const SizedBox(height: 10),
        _buildSearchBox(),
        const SizedBox(height: 15),
        Expanded(
          child: selectedPage == 0
              ? _buildScannedAssetsSection(context)
              : _buildUnscannedAssetsSection(context),
        ),
      ],
    );
  }

  Widget _buildHeaderTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTabButton('Scanned Assets', 0),
        const SizedBox(width: 12),
        _buildTabButton('Not Yet Scanned', 1),
      ],
    );
  }

  Widget _buildTabButton(String label, int value) {
    final bool isSelected = selectedPage == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedPage = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF405189) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF405189),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Maison Bold',
                fontSize: 14,
                color: isSelected ? Colors.white : const Color(0xFF405189),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      height: 48,
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
        controller: widget.searchController,
        onChanged: widget.onFilterAssets,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: Color(0xFF405189), size: 20),
          hintText: 'Search Category, Asset ID',
          hintStyle: TextStyle(
            fontFamily: 'Maison Book',
            color: Colors.grey[500],
            fontSize: 12,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildScannedAssetsSection(BuildContext context) {
    // Ambil recent asset (untuk card/foto dsb) sesuai asset yang sudah di scan
    final scannedRecentAssets = widget.recentScannedAssets
        .where((recent) =>
            widget.scannedAssets.any((a) => a.assetCode == recent.assetNo))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Scanned Assets', scannedRecentAssets.length),
        const SizedBox(height: 10),
        Expanded(
          child: widget.isLoading
              ? ShimmerLoading.assetsList()
              : scannedRecentAssets.isEmpty
                  ? Center(
                      child: Text(
                        'No assets have been scanned.',
                        style: TextStyle(
                          fontFamily: 'Maison Bold',
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: scannedRecentAssets.length,
                      itemBuilder: (context, index) {
                        return RecentAssetCard(
                          asset: scannedRecentAssets[index],
                          photoCache: photoCache, // <-- WAJIB!
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildUnscannedAssetsSection(BuildContext context) {
    final filtered = widget.unscannedAssets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Assets Not Yet Scanned', filtered.length),
        const SizedBox(height: 10),
        Expanded(
          child: widget.isLoading
              ? ShimmerLoading.assetsList()
              : filtered.isEmpty
                  ? Center(
                      child: Text(
                        'All assets have been scanned.',
                        style: TextStyle(
                          fontFamily: 'Maison Bold',
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        return AssetCard(
                          asset: filtered[index],
                          formatUpdatedTimeWIB: widget.formatUpdatedTimeWIB,
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String label, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label ($count)',
          style: const TextStyle(
            fontFamily: 'Maison Bold',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF405189),
          ),
        ),
        if (widget.searchController.text.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF405189).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Filtered',
              style: TextStyle(
                fontFamily: 'Maison Bold',
                fontSize: 10,
                color: const Color(0xFF405189),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}