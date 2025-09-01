import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Simba/screens/home_screen/unscanned_assets/unscanned_asset_detail_page.dart';
import 'package:Simba/screens/home_screen/unscanned_assets/unscanned_asset_service.dart';
import 'package:Simba/screens/welcome_page.dart';
import 'asset_item.dart';

class UnscannedAssetsPage extends StatefulWidget {
  final String auditId;
  UnscannedAssetsPage({required this.auditId});

  @override
  State<UnscannedAssetsPage> createState() => _UnscannedAssetsPageState();
}

class _UnscannedAssetsPageState extends State<UnscannedAssetsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<AssetItem> assets = [];
  List<AssetItem> scannedAssets = [];
  bool isLoading = true;
  bool isLoadingHistory = true;
  String searchQuery = '';
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchAssets();
    fetchScannedHistory();
  }

  Future<void> fetchAssets() async {
    setState(() => isLoading = true);
    final items = await UnscannedAssetService.fetchUnscannedAssets(
      auditId: widget.auditId.toString(),
      search: searchQuery,
      category: selectedCategory == "All" ? null : selectedCategory,
    );
    setState(() {
      assets = items;
      isLoading = false;
    });
  }

  Future<void> fetchScannedHistory() async {
    setState(() => isLoadingHistory = true);
    final items = await UnscannedAssetService.fetchScannedHistory(
      auditId: widget.auditId.toString(),
    );
    setState(() {
      scannedAssets = items;
      isLoadingHistory = false;
    });
  }

  Future<void> scanAsset(AssetItem asset) async {
    try {
      final success = await UnscannedAssetService.scanAsset(
        widget.auditId.toString(),
        asset.asset_code,
      );
      if (success) {
        await fetchAssets();
        await fetchScannedHistory();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) {
            bool allScanned = assets.isEmpty;
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFF405189).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check_circle, color: Color(0xFF405189), size: 24),
                  ),
                  SizedBox(width: 12),
                  Text(
                    allScanned ? 'Audit Selesai!' : 'Berhasil!',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF405189),
                    ),
                  ),
                ],
              ),
              content: Text(
                allScanned
                    ? 'Semua asset sudah di-scan. Audit selesai!'
                    : 'Asset "${asset.name}" berhasil di-scan!',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              actions: [
                if (!allScanned)
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: Text(
                      'Scan Lagi',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF405189),
                      ),
                    ),
                  ),
                if (allScanned)
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Audit selesai, semua asset sudah di-scan!'),
                          backgroundColor: Color(0xFF405189),
                        ),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => WelcomePage()),
                      );
                    },
                    child: Text(
                      'Audit Selesai',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF405189),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(e.toString().replaceFirst('Exception: ', ''),
            style: TextStyle(fontFamily: 'Inter', fontSize: 12))));
    }
  }

  Future<void> manualScan(AssetItem asset) async {
    try {
      final success = await UnscannedAssetService.manualScanAsset(
        widget.auditId.toString(), asset.id.toString()
      );
      if (success) {
        await fetchAssets();
        await fetchScannedHistory();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) {
            bool allScanned = assets.isEmpty;
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.edit, color: Colors.orange, size: 24),
                  ),
                  SizedBox(width: 12),
                  Text(
                    allScanned ? 'Audit Selesai!' : 'Manual!',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              content: Text(
                allScanned
                    ? 'Semua asset sudah di-scan. Audit selesai!'
                    : 'Asset "${asset.name}" ditandai manual!',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              actions: [
                if (!allScanned)
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: Text(
                      'Scan Lagi',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF405189),
                      ),
                    ),
                  ),
                if (allScanned)
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Audit selesai, semua asset sudah di-scan!'),
                          backgroundColor: Color(0xFF405189),
                        ),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => WelcomePage()),
                      );
                    },
                    child: Text(
                      'Audit Selesai',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF405189),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(e.toString().replaceFirst('Exception: ', ''),
            style: TextStyle(fontFamily: 'Inter', fontSize: 12))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Color(0xFF405189),
        elevation: 0,
        title: const Text(
          'Audit Asset',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => WelcomePage()),
            );
          },
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Color(0xFF405189),
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                style: TextStyle(fontFamily: 'Inter', fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Cari aset...",
                  hintStyle: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Colors.grey[400],
                  ),
                  prefixIcon: Icon(Icons.search, color: Color(0xFF405189), size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                ),
                onChanged: (val) {
                  searchQuery = val;
                  fetchAssets();
                  fetchScannedHistory();
                },
              ),
            ),
          ),
          // TabBar di bawah search
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Color(0xFF405189),
              labelColor: Color(0xFF405189),
              unselectedLabelColor: Colors.grey,
              labelStyle: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              tabs: [
                Tab(text: 'Asset Belum di Scan'),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Riwayat Scan'),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Color(0xFF405189),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${scannedAssets.length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab Asset Belum di Scan
                RefreshIndicator(
                  onRefresh: () async {
                    await fetchAssets();
                  },
                  child: _buildUnscannedAssetsTab(),
                ),
                // Tab Riwayat Scan
                RefreshIndicator(
                  onRefresh: () async {
                    await fetchScannedHistory();
                  },
                  child: _buildScannedHistoryTab(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnscannedAssetsTab() {
    if (isLoading) {
      // shimmer loading asset belum di scan
      return ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: 5,
        itemBuilder: (context, idx) => Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              title: Container(
                height: 14,
                width: 100,
                color: Colors.grey[200],
              ),
              subtitle: Padding(
                padding: EdgeInsets.only(top: 4),
                child: Container(
                  height: 10,
                  width: 80,
                  color: Colors.grey[200],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return assets.isEmpty
      ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFF405189).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.qr_code_2,
                    size: 40, color: Color(0xFF405189)),
              ),
              SizedBox(height: 16),
              Text("Tidak ada aset belum di-scan",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF405189),
                  )),
              SizedBox(height: 4),
              Text("Semua aset sudah terscan",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Colors.grey[500],
                  )),
            ],
          ),
        )
      : ListView.builder(
          padding: EdgeInsets.all(12),
          itemCount: assets.length,
          itemBuilder: (context, idx) {
            final asset = assets[idx];
            return Container(
              margin: EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Color(0xFF405189).withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UnscannedAssetDetailPage(
                        asset: asset,
                        auditId: widget.auditId,
                        onAssetScanned: () => fetchAssets(),
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Asset Image
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Color(0xFF405189).withOpacity(0.1),
                        ),
                        child: asset.image_path.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  asset.image_path.split(',')[0],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xFF405189).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        asset.name.substring(0, 1).toUpperCase(),
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF405189),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Center(
                                child: Text(
                                  asset.name.substring(0, 1).toUpperCase(),
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF405189),
                                  ),
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
                                color: Color(0xFF405189),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2),
                            Text(
                              asset.asset_code,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
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
                                SizedBox(width: 6),
                                Text(
                                  asset.location,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Action Buttons
                      Column(
                        children: [
                          _actionButton(
                            label: "Scan",
                            color: Color(0xFF405189),
                            onPressed: () => scanAsset(asset),
                          ),
                          SizedBox(height: 4),
                          _actionButton(
                            label: "Manual",
                            color: Colors.orange,
                            onPressed: () => manualScan(asset),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
  }

  Widget _buildScannedHistoryTab() {
    if (isLoadingHistory) {
      // shimmer loading riwayat scan
      return ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: 5,
        itemBuilder: (context, idx) => Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              title: Container(
                height: 12,
                width: 90,
                color: Colors.grey[200],
              ),
              subtitle: Padding(
                padding: EdgeInsets.only(top: 4),
                child: Container(
                  height: 9,
                  width: 70,
                  color: Colors.grey[200],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return scannedAssets.isEmpty
      ? ListView(
          physics: AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: 100),
            Center(
              child: Text(
                "Belum ada asset yang di-scan.",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF405189),
                ),
              ),
            ),
          ],
        )
      : ListView.builder(
          padding: EdgeInsets.all(12),
          itemCount: scannedAssets.length,
          itemBuilder: (context, idx) {
            final asset = scannedAssets[idx];
            return Container(
              margin: EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Color(0xFF405189).withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: Text(
                          asset.name,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF405189),
                          ),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.qr_code_2, color: Color(0xFF405189), size: 18),
                                SizedBox(width: 8),
                                Text(
                                  "Barcode: ",
                                  style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                                Expanded(
                                  child: Text(
                                    asset.asset_code,
                                    style: TextStyle(fontFamily: 'Inter', fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.schedule, color: Colors.orange, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  "Tanggal Scan: ",
                                  style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                                Expanded(
                                  child: Text(
                                    asset.scanned_at ?? asset.last_scanned_at ?? '-',
                                    style: TextStyle(fontFamily: 'Inter', fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.person, color: Colors.green, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  "Scanned By: ",
                                  style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                                Expanded(
                                  child: Text(
                                    asset.pic,
                                    style: TextStyle(fontFamily: 'Inter', fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.green[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "Scanned",
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      color: Colors.green[800],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: Text(
                              'Tutup',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF405189),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                leading: asset.image_path.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          asset.image_path.split(',')[0],
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Color(0xFF405189).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            asset.name.substring(0, 1).toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF405189),
                            ),
                          ),
                        ),
                      ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        asset.name,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF405189),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Scanned",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: Colors.green[800],
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Barcode: ${asset.asset_code}",
                      style: TextStyle(fontFamily: 'Inter', fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Tanggal Scan: ${asset.scanned_at ?? asset.last_scanned_at ?? '-'}",
                      style: TextStyle(fontFamily: 'Inter', fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                trailing: Icon(Icons.chevron_right, color: Color(0xFF405189), size: 18),
              ),
            );
          },
        );
  }

  Widget _actionButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.3), width: 0.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }
}