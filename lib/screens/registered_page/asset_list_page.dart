import 'package:flutter/material.dart';
import 'asset_model.dart';
import 'asset_service.dart';
import 'category_service.dart';
import 'add_edit_asset_dialog.dart';
import 'asset_detail_page.dart';
import 'asset_card.dart';
import 'lost_asset_page.dart';

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
          content: Text('Failed to load assets',
              style: TextStyle(fontFamily: 'Maison Book')),
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
            content: Text('Failed to load categories',
                style: TextStyle(fontFamily: 'Maison Book')),
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
                fontFamily: 'Maison Bold')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              style: TextStyle(fontSize: 14, fontFamily: 'Maison Bold'),
              decoration: InputDecoration(
                labelText: 'Category Name',
                labelStyle: TextStyle(fontSize: 12, fontFamily: 'Maison Book'),
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
                style: TextStyle(fontSize: 12, fontFamily: 'Maison Book')),
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
                      content: Text('Category added',
                          style: TextStyle(fontFamily: 'Maison Bold')),
                      backgroundColor: Colors.green),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Failed to add category',
                          style: TextStyle(fontFamily: 'Maison Book')),
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
                style: TextStyle(fontSize: 12, fontFamily: 'Maison Bold')),
          ),
        ],
      ),
    );
  }

  void _showAddAssetDialog() {
    showDialog(
      context: context,
      builder: (context) => AddEditAssetDialog(
        onSave: (asset) async {
          await loadAssets();
          // Hapus modal asset ditambah, cukup reload dan update UI saja.
        },
        categories: categories.where((cat) => cat != 'All').toList(),
      ),
    );
  }

  void _showEditAssetDialog(Asset asset) async {
    Asset? hasilEdit;
    await showDialog(
      context: context,
      builder: (context) => AddEditAssetDialog(
        asset: asset,
        onSave: (updatedAsset) async {
          await loadAssets();
          hasilEdit = updatedAsset;
        },
        categories: categories.where((cat) => cat != 'All').toList(),
      ),
    );
    // Setelah dialog tertutup, cek status
    if (hasilEdit != null && hasilEdit!.status == 'lost') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LostAssetPage(),
        ),
      );
    }
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
                    fontFamily: 'Maison Bold')),
          ],
        ),
        content: Text('Are you sure you want to delete "${asset.name}"?',
            style: TextStyle(fontFamily: 'Maison Book', fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(fontFamily: 'Maison Book', fontSize: 12)),
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
                    fontFamily: 'Maison Bold', color: Colors.white, fontSize: 12)),
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
            style: TextStyle(fontFamily: 'Maison Bold'),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Failed to delete asset',
            style: TextStyle(fontFamily: 'Maison Book'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                    fontFamily: 'Maison Bold')),
          ],
        ),
        content: Text('Are you sure you want to delete selected assets?',
            style: TextStyle(fontFamily: 'Maison Book', fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: TextStyle(fontFamily: 'Maison Book', fontSize: 12)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
            child: Text('Delete',
                style: TextStyle(
                    fontFamily: 'Maison Bold', color: Colors.white, fontSize: 12)),
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
            content: Text('Selected assets deleted',
                style: TextStyle(fontFamily: 'Maison Bold')),
            backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _refreshAssets() async {
    await loadAssets();
    await loadCategories();
  }

  List<Asset> get filteredAssets => assets;

  Widget buildShimmerList() {
    return ListView.builder(
      padding: EdgeInsets.all(12),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            height: 70,
            width: double.infinity,
          ),
        );
      },
    );
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
            fontWeight: FontWeight.w700,
            fontSize: 16,
            fontFamily: 'Maison Bold',
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
                  fontFamily: 'Maison Bold',
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
                        style: TextStyle(fontSize: 14, fontFamily: 'Maison Book'),
                        decoration: InputDecoration(
                          hintText: 'Search assets...',
                          hintStyle: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                              fontFamily: 'Maison Book'),
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
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    width: double.infinity,
                                    height: 32,
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
                                                fontFamily: 'Maison Book',
                                                fontSize: 11,
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
                        ),
                        SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: Icon(Icons.add,
                              size: 16, color: Color(0xFF405189)),
                          label: Text('Kategori',
                              style: TextStyle(
                                  fontFamily: 'Maison Bold',
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
                            fontFamily: 'Maison Bold',
                            fontSize: 13,
                            color: Colors.orange[900],
                            fontWeight: FontWeight.w700)),
                    Spacer(),
                    ElevatedButton.icon(
                      icon: Icon(Icons.delete, size: 16),
                      label: Text('Delete',
                          style: TextStyle(fontFamily: 'Maison Bold', fontSize: 12)),
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
                                          fontFamily: 'Maison Bold',
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w700),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'Try adjusting your search',
                                      style: TextStyle(
                                          fontFamily: 'Maison Book',
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
                                child: AssetCard(
                                  asset: asset,
                                  onEdit: () => _showEditAssetDialog(asset),
                                  onDelete: () => _confirmDelete(asset),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AssetDetailPage(asset: asset),
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
                      fontFamily: 'Maison Bold',
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
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