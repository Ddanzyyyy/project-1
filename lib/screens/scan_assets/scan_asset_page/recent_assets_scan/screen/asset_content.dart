import 'package:flutter/material.dart';
import 'dart:async';
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
  int selectedPage = 0;
  Timer? _debounce;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    widget.searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    widget.searchController.removeListener(_onSearchChanged);
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(AssetsContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Set first load to false after initial data is loaded
    if (_isFirstLoad && !widget.isLoading) {
      _isFirstLoad = false;
    }
  }

  void _onSearchChanged() {
    // Cancel previous debounce
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    // Debounce search to reduce server load
    _debounce = Timer(const Duration(milliseconds: 600), () {
      widget.onFilterAssets(widget.searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 12),
              _buildHeaderTabs(),
              const SizedBox(height: 10),
              _buildSearchBox(),
              const SizedBox(height: 15),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: _buildSectionHeader(
            selectedPage == 0 ? 'Scanned Assets' : 'Assets Not Yet Scanned',
            selectedPage == 0
                ? widget.recentScannedAssets
                    .where((recent) => widget.scannedAssets
                        .any((a) => a.assetCode == recent.assetNo))
                    .length
                : widget.unscannedAssets.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 10)),
        if (selectedPage == 0)
          _buildScannedAssetsList()
        else
          _buildUnscannedAssetsList(),
      ],
    );
  }

  Widget _buildScannedAssetsList() {
    final scannedRecentAssets = widget.recentScannedAssets
        .where((recent) =>
            widget.scannedAssets.any((a) => a.assetCode == recent.assetNo))
        .toList();

    // Only show shimmer on first load
    if (_isFirstLoad && widget.isLoading) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 400,
          child: ShimmerLoading.assetsList(),
        ),
      );
    } else if (scannedRecentAssets.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: Text(
              'No assets have been scanned.',
              style: TextStyle(
                fontFamily: 'Maison Bold',
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
        ),
      );
    } else {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return RecentAssetCard(asset: scannedRecentAssets[index]);
          },
          childCount: scannedRecentAssets.length,
        ),
      );
    }
  }

  Widget _buildUnscannedAssetsList() {
    final filtered = widget.unscannedAssets;

    // Only show shimmer on first load
    if (_isFirstLoad && widget.isLoading) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 400,
          child: ShimmerLoading.assetsList(),
        ),
      );
    } else if (filtered.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: Text(
              'All assets have been scanned.',
              style: TextStyle(
                fontFamily: 'Maison Bold',
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
        ),
      );
    } else {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return AssetCard(
              asset: filtered[index],
              formatUpdatedTimeWIB: widget.formatUpdatedTimeWIB,
            );
          },
          childCount: filtered.length,
        ),
      );
    }
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
          if (selectedPage != value) {
            setState(() {
              selectedPage = value;
              // Clear search when switching tabs
              widget.searchController.clear();
            });
          }
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
        decoration: InputDecoration(
          prefixIcon:
              const Icon(Icons.search, color: Color(0xFF405189), size: 20),
          suffixIcon: widget.searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                  onPressed: () {
                    widget.searchController.clear();
                    widget.onFilterAssets('');
                  },
                )
              : null,
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