import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:io';
import '../model/logistic_asset_model.dart';
import '../service/logistic_asset_service.dart';
import 'logistic_asset_detail_page.dart';
import '../../analytic_logistic/screen/logistic_asset_analytics_page.dart';

class LogisticAssetPage extends StatefulWidget {
  @override
  _LogisticAssetPageState createState() => _LogisticAssetPageState();
}

class _LogisticAssetPageState extends State<LogisticAssetPage> {
  List<LogisticAsset> assets = [];
  List<String> categories = ['All'];
  String searchQuery = '';
  String selectedCategory = 'All';
  bool isLoading = true;
  bool isImporting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadAssets(),
      _loadCategories(),
    ]);
  }

  Future<void> _loadAssets() async {
    setState(() => isLoading = true);
    try {
      final loadedAssets = await LogisticAssetService.getLogisticAssets(
        search: searchQuery,
        category: selectedCategory,
      );
      setState(() {
        assets = loadedAssets;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorSnackBar('Failed to load assets: $e');
    }
  }

  Future<void> _loadCategories() async {
    try {
      final loadedCategories = await LogisticAssetService.getCategories();
      setState(() {
        categories = ['All', ...loadedCategories];
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load categories: $e');
    }
  }

  Future<void> _importExcel() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() => isImporting = true);

        final file = File(result.files.single.path!);
        final importResult = await LogisticAssetService.importExcel(file);

        setState(() => isImporting = false);

        _showSuccessSnackBar(
            'Import successful: ${importResult['imported']} assets imported, ${importResult['failed']} failed');

        await _loadAssets();
      }
    } catch (e) {
      setState(() => isImporting = false);
      _showErrorSnackBar('Import failed: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontFamily: 'Maison Book')),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontFamily: 'Maison Book')),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickAnalytics() {
    if (assets.isEmpty) return SizedBox.shrink();

    final totalAssets = assets.length;
    final totalAvailable =
        assets.fold(0, (sum, asset) => sum + asset.available);
    final totalBroken = assets.fold(0, (sum, asset) => sum + asset.broken);
    final totalLost = assets.fold(0, (sum, asset) => sum + asset.lost);

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(width: 8),
              Text(
                'Quick Overview',
                style: TextStyle(
                  fontFamily: 'Maison Bold',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF405189),
                ),
              ),
            ],
          ),
          SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSimpleAnalyticsCard(
                value: '$totalAssets',
                label: 'Total',
                iconImage: 'assets/images/icons/welcome_page/box_icon.png',
                color: Color(0xFF405189),
              ),
              _buildSimpleAnalyticsCard(
                value: '$totalAvailable',
                label: 'Available',
                iconImage: 'assets/images/icons/activity_page/status.png',
                color: Colors.green,
              ),
              _buildSimpleAnalyticsCard(
                value: '$totalBroken',
                label: 'Broken',
                iconImage: 'assets/images/icons/activity_page/alert.png',
                color: Colors.orange,
              ),
              _buildSimpleAnalyticsCard(
                value: '$totalLost',
                label: 'Lost',
                iconImage: 'assets/images/icons/activity_page/damage.png',
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleAnalyticsCard({
    required String value,
    required String label,
    IconData? icon,
    String? iconImage,
    required Color color,
  }) {
    return Container(
      width: 70,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            padding: EdgeInsets.all(10),
            child: iconImage != null 
                ? Image.asset(iconImage, width: 22, height: 22)
                : Icon(icon, color: color, size: 22),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Maison Bold',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Maison Book',
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Color(0xFF405189),
        elevation: 0,
        title: Text(
          'Logistic Assets',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            fontFamily: 'Maison Bold',
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'import') {
                _importExcel();
              } else if (value == 'analytics') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => LogisticAssetAnalyticsPage()),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.file_upload, color: Color(0xFF405189), size: 20),
                    SizedBox(width: 8),
                    Text('Import Excel',
                        style: TextStyle(fontFamily: 'Maison Bold')),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with search and filter
          Container(
            color: Color(0xFF405189),
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() => searchQuery = value);
                        _loadAssets();
                      },
                      style: TextStyle(fontSize: 14, fontFamily: 'Maison Book'),
                      decoration: InputDecoration(
                        hintText: 'Search by Asset No or Title...',
                        hintStyle:
                            TextStyle(fontSize: 13, color: Colors.grey[500]),
                        prefixIcon: Icon(Icons.search,
                            color: Color(0xFF405189), size: 20),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  // Category Filter
                  Container(
                    height: 32,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isSelected = selectedCategory == category;
                        return Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () {
                              setState(() => selectedCategory = category);
                              _loadAssets();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  fontFamily: 'Maison Book',
                                  fontSize: 12,
                                  color: isSelected
                                      ? Color(0xFF405189)
                                      : Colors.white,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Asset List with Analytics
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              color: Color(0xFF405189),
              child: isLoading
                  ? _buildShimmerList()
                  : assets.isEmpty
                      ? ListView(
                          physics: AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(height: 100),
                            Center(
                              child: Column(
                                children: [
                                  Icon(Icons.inventory_2_outlined,
                                      size: 64, color: Colors.grey[400]),
                                  SizedBox(height: 16),
                                  Text(
                                    'No logistic assets found',
                                    style: TextStyle(
                                      fontFamily: 'Maison Bold',
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Import Excel file to add assets',
                                    style: TextStyle(
                                      fontFamily: 'Maison Book',
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : CustomScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          slivers: [
                            // Quick Analytics Section
                            SliverToBoxAdapter(
                              child: _buildQuickAnalytics(),
                            ),
                            // Asset List
                            SliverPadding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final asset = assets[index];
                                    return _buildAssetCard(asset);
                                  },
                                  childCount: assets.length,
                                ),
                              ),
                            ),
                            // Bottom spacing
                            SliverToBoxAdapter(
                              child: SizedBox(height: 16),
                            ),
                          ],
                        ),
            ),
          ),

          // Import Loading Overlay
          if (isImporting)
            Container(
              color: Colors.black54,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF405189)),
                        SizedBox(height: 16),
                        Text(
                          'Importing Excel file...',
                          style: TextStyle(fontFamily: 'Maison Bold'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAssetCard(LogisticAsset asset) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LogisticAssetDetailPage(asset: asset),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFF405189).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        asset.assetNo,
                        style: TextStyle(
                          fontFamily: 'Maison Bold',
                          fontSize: 12,
                          color: Color(0xFF405189),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            _getStatusColor(asset.assetStatus).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        asset.assetStatus,
                        style: TextStyle(
                          fontFamily: 'Maison Bold',
                          fontSize: 10,
                          color: _getStatusColor(asset.assetStatus),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  asset.title,
                  style: TextStyle(
                    fontFamily: 'Maison Bold',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  '${asset.category} • ${asset.department}',
                  style: TextStyle(
                    fontFamily: 'Maison Book',
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatusChip(
                        'Available', asset.available, Colors.green),
                    SizedBox(width: 8),
                    _buildStatusChip('Broken', asset.broken, Colors.orange),
                    SizedBox(width: 8),
                    _buildStatusChip('Lost', asset.lost, Colors.red),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, int count, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(
          fontFamily: 'Maison Bold',
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.orange;
      case 'disposed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}