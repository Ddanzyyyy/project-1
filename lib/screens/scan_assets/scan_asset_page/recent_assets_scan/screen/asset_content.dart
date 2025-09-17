import 'package:Simba/screens/scan_assets/scan_asset_page/recent_assets_scan/widget/asset_card.dart';
import 'package:Simba/screens/scan_assets/scan_asset_page/recent_assets_scan/screen/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:Simba/screens/scan_assets/scan_asset_page/recent_assets_scan/model/asset.dart';

class AssetsContent extends StatelessWidget {
  final TextEditingController searchController;
  final List<Asset> filteredAssets;
  final bool isLoading;
  final Function(String) onFilterAssets;
  final String Function(DateTime?) formatUpdatedTimeWIB;

  const AssetsContent({
    required this.searchController,
    required this.filteredAssets,
    required this.isLoading,
    required this.onFilterAssets,
    required this.formatUpdatedTimeWIB,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchBox(),
        const SizedBox(height: 15),
        _buildAssetsHeader(),
        const SizedBox(height: 10),
        Expanded(child: _buildAssetsList()),
      ],
    );
  }

  Widget _buildSearchBox() {
    return Container(
      height: 50,
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
        controller: searchController,
        onChanged: onFilterAssets,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: Color(0xFF405189), size: 20),
          hintText: 'Search assets...',
          hintStyle: TextStyle(
            fontFamily: 'Maison Book',
            color: Colors.grey[500],
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildAssetsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Assets (${filteredAssets.length})',
          style: const TextStyle(
            fontFamily: 'Maison Bold',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF405189),
          ),
        ),
        if (searchController.text.isNotEmpty)
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

  Widget _buildAssetsList() {
    if (isLoading) {
      return ShimmerLoading.assetsList();
    } else if (filteredAssets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              searchController.text.isNotEmpty
                  ? Icons.search_off
                  : Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              searchController.text.isNotEmpty
                  ? 'No assets found for "${searchController.text}"'
                  : 'No assets found',
              style: TextStyle(
                fontFamily: 'Maison Bold',
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              searchController.text.isNotEmpty
                  ? 'Try different search terms'
                  : 'Start by scanning QR codes to view assets',
              style: TextStyle(
                fontFamily: 'Maison Bold',
                color: Colors.grey[500],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    } else {
      return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: filteredAssets.length,
        itemBuilder: (context, index) {
          return AssetCard(
            asset: filteredAssets[index],
            formatUpdatedTimeWIB: formatUpdatedTimeWIB,
          );
        },
      );
    }
  }
}