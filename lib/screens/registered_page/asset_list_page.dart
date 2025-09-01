import 'category_service.dart';
import 'package:flutter/material.dart';
import 'asset_model.dart';
import 'asset_service.dart';
import 'add_edit_asset_dialog.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:shimmer/shimmer.dart';

class AssetListPage extends StatefulWidget {
  @override
  _AssetListPageState createState() => _AssetListPageState();
}

class _AssetListPageState extends State<AssetListPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<Asset> assets = [];
  Set<String> selectedAssetIds = {};
  bool isBulkMode = false;
  String searchQuery = '';
  String selectedCategory = 'All';
  List<String> categories = ['All'];
  bool isLoadingAssets = true;
  bool isLoadingCategories = true;
  final _scrollController = ScrollController();

  Future<void> loadAssets() async {
    setState(() => isLoadingAssets = true);
    try {
      final loadedAssets = await AssetService.getAssets(
        search: searchQuery,
        category: selectedCategory,
      );
      setState(() {
        assets = loadedAssets;
        isLoadingAssets = false;
      });
    } catch (e) {
      setState(() => isLoadingAssets = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load assets'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> loadCategories() async {
    setState(() => isLoadingCategories = true);
    try {
      final loadedCategories = await CategoryService.getCategories();
      setState(() {
        categories = ['All', ...loadedCategories];
        isLoadingCategories = false;
      });
    } catch (e) {
      setState(() => isLoadingCategories = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to load categories'),
            backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _addCategoryDialog() async {
    final TextEditingController controller = TextEditingController();
    String? error;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Add New Category',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              style: TextStyle(fontSize: 14, fontFamily: 'Inter'),
              decoration: InputDecoration(
                labelText: 'Category Name',
                labelStyle: TextStyle(fontSize: 12, fontFamily: 'Inter'),
                errorText: error,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Color(0xFF405189), width: 1.5),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(fontSize: 12, fontFamily: 'Inter')),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) {
                error = 'Name required';
                setState(() {});
                return;
              }
              final added = await CategoryService.addCategory(name);
              if (added) {
                await loadCategories();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Category added'),
                      backgroundColor: Colors.green),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Failed to add category'),
                      backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF405189),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text('Add',
                style: TextStyle(fontSize: 12, fontFamily: 'Inter')),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    loadAssets();
    loadCategories();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showAddAssetDialog() {
    final parentContext = context;
    showDialog(
      context: context,
      builder: (context) => AddEditAssetDialog(
        onSave: (asset) async {
          await loadAssets();
          if (mounted) {
            showDialog(
              context: parentContext,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                content: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 48),
                      SizedBox(height: 12),
                      Text(
                        'Asset ditambah',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
        categories: categories.where((cat) => cat != 'All').toList(),
      ),
    );
  }

  void _showEditAssetDialog(Asset asset) {
    showDialog(
      context: context,
      builder: (context) => AddEditAssetDialog(
        asset: asset,
        onSave: (updatedAsset) async {
          await loadAssets();
        },
        categories: categories.where((cat) => cat != 'All').toList(),
      ),
    );
  }

  void _confirmDelete(Asset asset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
            SizedBox(width: 8),
            Text('Delete Asset',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    fontFamily: 'Inter')),
          ],
        ),
        content: Text('Are you sure you want to delete "${asset.name}"?',
            style: TextStyle(fontFamily: 'Inter', fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(fontFamily: 'Inter', fontSize: 12)),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteAsset(asset.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text('Delete',
                style: TextStyle(
                    fontFamily: 'Inter', color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _deleteAsset(String id) async {
    try {
      await AssetService.deleteAsset(id);
      await loadAssets();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Asset deleted successfully',
            style: TextStyle(fontFamily: 'Inter'),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Failed to delete asset',
            style: TextStyle(fontFamily: 'Inter'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Asset> get filteredAssets => assets;

  Widget buildShimmerList() {
    return ListView.builder(
      padding: EdgeInsets.all(12),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              height: 70,
              width: double.infinity,
            ),
          ),
        );
      },
    );
  }

  void _toggleBulkMode() {
    setState(() {
      isBulkMode = !isBulkMode;
      selectedAssetIds.clear();
    });
  }

  void _toggleSelectAsset(String id) {
    setState(() {
      if (selectedAssetIds.contains(id)) {
        selectedAssetIds.remove(id);
      } else {
        selectedAssetIds.add(id);
      }
    });
  }

  void _deleteSelectedAssets() async {
    if (selectedAssetIds.isEmpty) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
            SizedBox(width: 8),
            Text('Delete Selected Assets',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    fontFamily: 'Inter')),
          ],
        ),
        content: Text('Are you sure you want to delete selected assets?',
            style: TextStyle(fontFamily: 'Inter', fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: TextStyle(fontFamily: 'Inter', fontSize: 12)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
            child: Text('Delete',
                style: TextStyle(
                    fontFamily: 'Inter', color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      for (final id in selectedAssetIds) {
        await AssetService.deleteAsset(id);
      }
      await loadAssets();
      setState(() {
        selectedAssetIds.clear();
        isBulkMode = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Selected assets deleted'),
            backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _refreshAssets() async {
    await loadAssets();
    await loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Color(0xFF405189),
        elevation: 0,
        toolbarHeight: 56,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Asset Management',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
            fontFamily: 'Inter',
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 12, top: 8, bottom: 8),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${assets.length}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(isBulkMode ? Icons.close : Icons.select_all,
                color: Colors.white),
            tooltip: isBulkMode ? 'Batal Bulk' : 'Bulk Action',
            onPressed: _toggleBulkMode,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Header Section
            Container(
              color: Color(0xFF405189),
              child: Padding(
                padding: EdgeInsets.fromLTRB(12, 8, 12, 16),
                child: Column(
                  children: [
                    // Search Bar
                    Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                          loadAssets();
                        },
                        style: TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search assets...',
                          hintStyle: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                              fontFamily: 'Inter'),
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(Icons.search,
                                color: Color(0xFF405189), size: 18),
                          ),
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    // Category Filter & Add Category Button
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 32,
                            child: isLoadingCategories
                                ? Shimmer.fromColors(
                                    baseColor: Colors.grey[400]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      width: double.infinity,
                                      height: 32,
                                    ),
                                  )
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: categories.length,
                                    itemBuilder: (context, index) {
                                      final category = categories[index];
                                      final isSelected =
                                          selectedCategory == category;
                                      return Padding(
                                        padding: EdgeInsets.only(right: 6),
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              selectedCategory = category;
                                            });
                                            loadAssets();
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.white
                                                      .withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Colors.white.withOpacity(
                                                    isSelected ? 1.0 : 0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              category,
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 11,
                                                color: isSelected
                                                    ? Color(0xFF405189)
                                                    : Colors.white,
                                                fontWeight: isSelected
                                                    ? FontWeight.w600
                                                    : FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: Icon(Icons.add,
                              size: 16, color: Color(0xFF405189)),
                          label: Text('Kategori',
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: Color(0xFF405189))),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Color(0xFF405189),
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: _addCategoryDialog,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Bulk Action Bar
            if (isBulkMode)
              Container(
                color: Colors.orange[50],
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text('Bulk Mode: ${selectedAssetIds.length} selected',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: Colors.orange[900],
                            fontWeight: FontWeight.w600)),
                    Spacer(),
                    ElevatedButton.icon(
                      icon: Icon(Icons.delete, size: 16),
                      label: Text('Delete',
                          style: TextStyle(fontFamily: 'Inter', fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: selectedAssetIds.isEmpty
                          ? null
                          : _deleteSelectedAssets,
                    ),
                  ],
                ),
              ),

            // Asset List
            Expanded(
              child: RefreshIndicator(
                color: Color(0xFF405189),
                onRefresh: _refreshAssets,
                child: isLoadingAssets
                    ? buildShimmerList()
                    : filteredAssets.isEmpty
                        ? ListView(
                            physics: AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(height: 100),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.inventory_2_outlined,
                                        size: 48, color: Colors.grey[400]),
                                    SizedBox(height: 12),
                                    Text(
                                      'No assets found',
                                      style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'Try adjusting your search',
                                      style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 13,
                                          color: Colors.grey[500]),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            physics: AlwaysScrollableScrollPhysics(),
                            controller: _scrollController,
                            padding: EdgeInsets.all(12),
                            itemCount: filteredAssets.length,
                            itemBuilder: (context, index) {
                              final asset = filteredAssets[index];
                              return Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: CompactAssetCard(
                                  asset: asset,
                                  onEdit: () => _showEditAssetDialog(asset),
                                  onDelete: () => _confirmDelete(asset),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DetailPage(asset: asset),
                                    ),
                                  ),
                                  isBulkMode: isBulkMode,
                                  isSelected:
                                      selectedAssetIds.contains(asset.id),
                                  onSelect: () => _toggleSelectAsset(asset.id),
                                ),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: !isBulkMode
          ? ElevatedButton.icon(
              icon: Icon(Icons.add, size: 18),
              label: Text('Tambah Asset',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF405189),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 4,
              ),
              onPressed: _showAddAssetDialog,
            )
          : null,
    );
  }
}

// ... CompactAssetCard dan DetailPage tetap sama}

class CompactAssetCard extends StatelessWidget {
  final Asset asset;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final bool isBulkMode;
  final bool isSelected;
  final VoidCallback? onSelect;

  const CompactAssetCard({
    Key? key,
    required this.asset,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
    this.isBulkMode = false,
    this.isSelected = false,
    this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isBulkMode ? (onSelect ?? () {}) : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange[50] : Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              if (isBulkMode)
                Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (_) => onSelect?.call(),
                    activeColor: Colors.orange,
                  ),
                ),
              // Asset Image
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Color(0xFF405189).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: asset.imagePath.isNotEmpty
                      ? Image.network(
                          asset.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.inventory_2_outlined,
                              color: Color(0xFF405189),
                              size: 24,
                            );
                          },
                        )
                      : Icon(
                          Icons.inventory_2_outlined,
                          color: Color(0xFF405189),
                          size: 24,
                        ),
                ),
              ),
              SizedBox(width: 12),

              // Asset Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.name,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Color(0xFF405189).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        asset.category,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          color: Color(0xFF405189),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      asset.description,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.grey[600],
                        fontSize: 11,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Action Buttons
              if (!isBulkMode)
                Container(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: onEdit,
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.edit_outlined,
                            color: const Color(0xFF405189),
                            size: 16,
                          ),
                        ),
                      ),
                      SizedBox(width: 4),
                      InkWell(
                        onTap: onDelete,
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final Asset asset;

  const DetailPage({Key? key, required this.asset}) : super(key: key);

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(12),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.7,
                errorBuilder: (context, error, stackTrace) => Center(
                  child:
                      Icon(Icons.broken_image, color: Colors.white, size: 48),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> images = asset.imagePath.isNotEmpty
        ? asset.imagePath.split(',').map((e) => e.trim()).toList()
        : [];

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          asset.name,
          style: TextStyle(
            fontFamily: 'Inter',
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
        backgroundColor: Color(0xFF405189),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        toolbarHeight: 60,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section - klik untuk full screen
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Center(
                child: GestureDetector(
                  onTap: images.isNotEmpty
                      ? () => _showFullImage(context, images.first)
                      : null,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: images.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              images.first,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF405189).withOpacity(0.1),
                                        Color(0xFF405189).withOpacity(0.05),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: Color(0xFF405189)
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Center(
                                            child: Text(
                                              asset.name.isNotEmpty
                                                  ? asset.name[0].toUpperCase()
                                                  : 'A',
                                              style: TextStyle(
                                                fontSize: 32,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF405189),
                                                fontFamily: 'Inter',
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          'No Image',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF6B7280),
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF405189).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Text(
                                      asset.name.isNotEmpty
                                          ? asset.name[0].toUpperCase()
                                          : 'A',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF405189),
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'No Image',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6B7280),
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            ),
            // ... (other content remains unchanged)
            Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              asset.name,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F2937),
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Asset Details',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Color(0xFF405189),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          asset.category,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32),
                  // Asset Information Grid
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 16,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Asset Information',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF405189),
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 24),
                        _buildInfoRow('Kode Aset', asset.assetCode),
                        _buildInfoRow('Lokasi', asset.location),
                        _buildInfoRow('PIC', asset.pic),
                        _buildInfoRow('Status', asset.status, isLast: true),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  // Description Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 16,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF405189),
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          asset.description.isNotEmpty
                              ? asset.description
                              : 'No description available',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            color: Color(0xFF4B5563),
                            height: 1.6,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  // Date Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 16,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Color(0xFF405189).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              '📅',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date Added',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                (() {
                                  final date =
                                      DateTime.tryParse(asset.dateAdded);
                                  if (date != null) {
                                    final months = [
                                      'Jan',
                                      'Feb',
                                      'Mar',
                                      'Apr',
                                      'May',
                                      'Jun',
                                      'Jul',
                                      'Aug',
                                      'Sep',
                                      'Oct',
                                      'Nov',
                                      'Dec'
                                    ];
                                    return '${date.day} ${months[date.month - 1]} ${date.year}';
                                  } else {
                                    return asset.dateAdded;
                                  }
                                })(),
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isLast = false}) {
    return Container(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
      decoration: isLast
          ? null
          : BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFF3F4F6),
                  width: 1,
                ),
              ),
            ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value.isNotEmpty ? value : '-',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
