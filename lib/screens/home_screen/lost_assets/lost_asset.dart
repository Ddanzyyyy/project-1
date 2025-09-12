import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'lost_asset_service.dart';
import 'lost_asset_form.dart';
import 'lost_asset_detail.dart';
import 'compact_lost_asset_card.dart';
import 'registered_lost_asset_card.dart';
import 'lost_asset_detail_dialog.dart';

const primaryColor = Color(0xFF405189);
const secondaryColor = Color(0xFFF8F9FA);

class LostAssetPage extends StatefulWidget {
  @override
  State<LostAssetPage> createState() => _LostAssetPageState();
}

class _LostAssetPageState extends State<LostAssetPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late TabController _tabController;

  List<Map<String, dynamic>> lostAssets = [];
  List<Map<String, dynamic>> registeredLostAssets = [];
  bool loading = true;
  final service = LostAssetService();
  String currentUser = 'Unknown';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
      if (_tabController.index == 1) {
        fetchAllData();
      }
    });
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _loadCurrentUser();
    fetchAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUser = prefs.getString('username') ?? 'Unknown';
    });
  }

  Future<void> fetchAllData() async {
    setState(() => loading = true);
    try {
      final lostData = await service.fetchLostAssets();
      final registeredData = await service.fetchRegisteredAssets();
      setState(() {
        lostAssets = lostData;
        registeredLostAssets = registeredData;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Gagal mengambil data aset hilang: $e',
            style: TextStyle(fontFamily: 'Maison Book')),
        backgroundColor: Colors.red,
      ));
    }
  }

  void openReportForm() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => ReportLostAssetForm(
        service: service,
        currentUser: currentUser,
        onAssetReported: () {
          fetchAllData();
        },
      ),
    );
  }

  Future<void> _refreshAssets() async {
    await fetchAllData();
  }

  void showRegisteredAssetDetail(Map asset) {
    showDialog(
      context: context,
      builder: (context) => LostAssetDetailDialog(asset: asset),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        toolbarHeight: 56,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Lost Assets',
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
                '${_tabController.index == 0 ? lostAssets.length : registeredLostAssets.length}',
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          labelStyle: TextStyle(
            fontFamily: 'Maison Bold',
            fontSize: 14,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: 'Maison Book',
            fontSize: 14,
          ),
          onTap: (index) {
            setState(() {});
          },
          tabs: [
            Tab(text: 'Laporan Hilang'),
            Tab(text: 'Asset Lost'),
          ],
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Container(
              color: primaryColor,
              child: Padding(
                padding: EdgeInsets.fromLTRB(12, 8, 12, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _tabController.index == 0 
                            ? 'Daftar Aset Hilang' 
                            : 'Asset Terdaftar (Status Lost)',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          fontFamily: 'Maison Bold',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  RefreshIndicator(
                    color: primaryColor,
                    onRefresh: _refreshAssets,
                    child: _buildLostAssetsList(),
                  ),
                  RefreshIndicator(
                    color: primaryColor,
                    onRefresh: _refreshAssets,
                    child: _buildRegisteredLostAssetsList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 0
          ? ElevatedButton.icon(
              icon: Icon(Icons.add, size: 18),
              label: Text('Laporkan Hilang',
                  style: TextStyle(
                      fontFamily: 'Maison Bold',
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 4,
              ),
              onPressed: openReportForm,
            )
          : null,
    );
  }

  Widget _buildLostAssetsList() {
    if (loading) {
      return ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: 5,
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

    if (lostAssets.isEmpty) {
      return ListView(
        physics: AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 100),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[400]),
                SizedBox(height: 12),
                Text(
                  'No lost assets found',
                  style: TextStyle(
                      fontFamily: 'Maison Bold',
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 6),
                Text(
                  'Try reporting lost assets!',
                  style: TextStyle(
                      fontFamily: 'Maison Book',
                      fontSize: 13,
                      color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(12),
      itemCount: lostAssets.length,
      itemBuilder: (context, index) {
        final asset = lostAssets[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: CompactLostAssetCard(
            asset: asset,
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LostAssetDetailPage(
                    asset: asset,
                    service: service,
                    currentUser: currentUser,
                  ),
                ),
              );
              if (result == 'found') {
                await fetchAllData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Aset berhasil dipindahkan ke daftar aktif.',
                      style: TextStyle(fontFamily: 'Maison Book'),
                    ),
                    backgroundColor: Colors.blue,
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildRegisteredLostAssetsList() {
    if (loading) {
      return ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: 5,
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

    if (registeredLostAssets.isEmpty) {
      return ListView(
        physics: AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 100),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[400]),
                SizedBox(height: 12),
                Text(
                  'Tidak ada asset lost',
                  style: TextStyle(
                      fontFamily: 'Maison Bold',
                      fontSize: 16,
                      color: Colors.grey[600]),
                ),
                SizedBox(height: 6),
                Text(
                  'Semua asset dalam kondisi baik.',
                  style: TextStyle(
                      fontFamily: 'Maison Book',
                      fontSize: 13,
                      color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(12),
      itemCount: registeredLostAssets.length,
      itemBuilder: (context, index) {
        final asset = registeredLostAssets[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: RegisteredLostAssetCard(
            asset: asset,
            onTap: () => showRegisteredAssetDetail(asset),
          ),
        );
      },
    );
  }
}