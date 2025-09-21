import 'package:flutter/material.dart';
import 'package:Simba/screens/NoImplementedHere/damaged_assets/damaged_asset_card.dart';
import 'package:Simba/screens/NoImplementedHere/registered_page/asset_model.dart';
import 'package:Simba/screens/NoImplementedHere/registered_page/asset_service.dart';

class DamagedAssetPage extends StatefulWidget {
  @override
  State<DamagedAssetPage> createState() => _DamagedAssetPageState();
}

class _DamagedAssetPageState extends State<DamagedAssetPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<Asset> assets = [];
  bool isLoadingAssets = true;
  String searchQuery = '';
  final _searchController = TextEditingController();

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadAssets() async {
    setState(() => isLoadingAssets = true);
    try {
      final allAssets = await AssetService.getAssets();
      assets = allAssets.where((a) => a.status == 'damaged').toList();
      setState(() => isLoadingAssets = false);
    } catch (e) {
      setState(() => isLoadingAssets = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat asset'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Asset> get filteredAssets {
    if (searchQuery.isEmpty) return assets;
    return assets
        .where((a) =>
            a.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            a.category.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Color(0xFF405189),
        elevation: 0,
        toolbarHeight: 56,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Asset Rusak',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
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
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Container(
              color: Color(0xFF405189),
              child: Padding(
                padding: EdgeInsets.fromLTRB(12, 8, 12, 16),
                child: Column(
                  children: [
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
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                        style: TextStyle(fontSize: 14, fontFamily: 'Maison Book'),
                        decoration: InputDecoration(
                          hintText: 'Cari asset rusak...',
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
                  ],
                ),
              ),
            ),
            Expanded(
              child: isLoadingAssets
                  ? Center(child: CircularProgressIndicator(color: Color(0xFF405189)))
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
                                    'Tidak ada asset rusak',
                                    style: TextStyle(
                                        fontFamily: 'Maison Bold',
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Semua asset dalam kondisi baik',
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
                          padding: EdgeInsets.all(12),
                          itemCount: filteredAssets.length,
                          itemBuilder: (context, index) {
                            final asset = filteredAssets[index];
                            return Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: DamagedAssetCard(asset: asset),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}