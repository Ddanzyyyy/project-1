import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Simba/screens/home_screen/unscanned_assets/unscanned_asset_detail_page.dart';
import 'package:Simba/screens/home_screen/unscanned_assets/unscanned_asset_service.dart';
import 'package:Simba/screens/welcome_page/welcome_page.dart';
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

  void onSearch(String val) {
    setState(() {
      searchQuery = val;
    });
    fetchAssets();
    fetchScannedHistory();
  }

  List<AssetItem> filterAssets(List<AssetItem> list) {
    return list.where((asset) {
      final q = searchQuery.toLowerCase();
      final name = asset.name.toLowerCase();
      final code = asset.asset_code.toLowerCase();
      final cat = asset.category.toLowerCase();
      final loc = asset.location.toLowerCase();
      final match = name.contains(q) ||
          code.contains(q) ||
          cat.contains(q) ||
          loc.contains(q);
      final catMatch =
          selectedCategory == "All" || asset.category == selectedCategory;
      return match && catMatch;
    }).toList();
  }

  Future<Map<String, dynamic>?> fetchTempStatusNotes(AssetItem asset) async {
    try {
      return await UnscannedAssetService.getTemporaryStatus(
        widget.auditId,
        asset.id.toString(),
      );
    } catch (e) {
      return null;
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
            fontFamily: 'Maison Bold',
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
                style: TextStyle(fontFamily: 'Maison Book', fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Cari aset...",
                  hintStyle: TextStyle(
                    fontFamily: 'Maison Book',
                    fontSize: 13,
                    color: Colors.grey[400],
                  ),
                  prefixIcon:
                      Icon(Icons.search, color: Color(0xFF405189), size: 20),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                ),
                onChanged: onSearch,
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
                fontFamily: 'Maison Bold',
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              tabs: [
                Tab(text: 'Asset Belum di Scan'),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Riwayat Scan',
                          style: TextStyle(fontFamily: 'Maison Bold')),
                      SizedBox(width: 8),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Color(0xFF405189),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${scannedAssets.length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Maison Bold',
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
                // Asset Belum di Scan Tab
                RefreshIndicator(
                  onRefresh: () async {
                    await fetchAssets();
                  },
                  child: _buildAssetsList(
                    assets: filterAssets(assets),
                    isLoading: isLoading,
                    isScanned: false,
                    onScan: (asset) async {
                      // Implement scan logic if needed
                    },
                    onManualScan: (asset) async {
                      // Implement manual logic if needed
                    },
                  ),
                ),
                // Riwayat Scan Tab (pencarian dan kategori filter juga berlaku!)
                RefreshIndicator(
                  onRefresh: () async {
                    await fetchScannedHistory();
                  },
                  child: _buildAssetsList(
                    assets: filterAssets(scannedAssets),
                    isLoading: isLoadingHistory,
                    isScanned: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetsList({
    required List<AssetItem> assets,
    required bool isLoading,
    required bool isScanned,
    Function(AssetItem)? onScan,
    Function(AssetItem)? onManualScan,
  }) {
    if (isLoading) {
      return ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: 5,
        itemBuilder: (context, idx) => Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.white,
          child: Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Container(
              height: 70,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      );
    }

    if (assets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF405189).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isScanned ? Icons.history_rounded : Icons.qr_code_2,
                size: 40,
                color: Color(0xFF405189),
              ),
            ),
            SizedBox(height: 16),
            Text(
              isScanned
                  ? "Belum ada asset yang di-scan"
                  : "Tidak ada aset belum di-scan",
              style: TextStyle(
                fontFamily: 'Maison Bold',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF405189),
              ),
            ),
            SizedBox(height: 4),
            Text(
              isScanned
                  ? "Mulai scan asset untuk melihat riwayat"
                  : "Semua aset sudah terscan",
              style: TextStyle(
                fontFamily: 'Maison Book',
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(12),
      itemCount: assets.length,
      itemBuilder: (context, idx) {
        final asset = assets[idx];
        return Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () async {
              if (!isScanned) {
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
              } else {
                // Ambil temp_status dan notes dari backend
                showDialog(
                  context: context,
                  builder: (ctx) {
                    return FutureBuilder<Map<String, dynamic>?>(
                      future: fetchTempStatusNotes(asset),
                      builder: (context, snapshot) {
                        final tempStatus = snapshot.data;
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          title: Text(
                            asset.name,
                            style: TextStyle(
                              fontFamily: 'Maison Bold',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF405189),
                            ),
                          ),
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.qr_code_2,
                                        color: Color(0xFF405189), size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      "Barcode: ",
                                      style: TextStyle(
                                          fontFamily: 'Maison Bold',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Expanded(
                                      child: Text(
                                        asset.asset_code,
                                        style: TextStyle(
                                            fontFamily: 'Maison Book',
                                            fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.schedule,
                                        color: Colors.orange, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      "Tanggal Scan: ",
                                      style: TextStyle(
                                          fontFamily: 'Maison Bold',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Expanded(
                                      child: Text(
                                        asset.scanned_at ??
                                            asset.last_scanned_at ??
                                            '-',
                                        style: TextStyle(
                                            fontFamily: 'Maison Book',
                                            fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.person,
                                        color: Colors.green, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      "Scanned By: ",
                                      style: TextStyle(
                                          fontFamily: 'Maison Bold',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Expanded(
                                      child: Text(
                                        asset.pic,
                                        style: TextStyle(
                                            fontFamily: 'Maison Book',
                                            fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.green[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        "Scanned",
                                        style: TextStyle(
                                          fontFamily: 'Maison Bold',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                          color: Colors.green[800],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Divider(),
                                // Info temp_status dan notes
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2)),
                                        SizedBox(width: 10),
                                        Text(
                                          "Memuat status & catatan...",
                                          style: TextStyle(
                                              fontFamily: 'Maison Book',
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  )
                                else if (tempStatus != null)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.assignment_turned_in,
                                              color: Color(0xFF405189),
                                              size: 18),
                                          SizedBox(width: 8),
                                          Text(
                                            "Status Sementara: ",
                                            style: TextStyle(
                                                fontFamily: 'Maison Bold',
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          Expanded(
                                            child: Text(
                                              tempStatus['temp_status'] ??
                                                  "Belum ada",
                                              style: TextStyle(
                                                  fontFamily: 'Maison Book',
                                                  fontSize: 12,
                                                  color: Colors.blue[700]),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      if ((tempStatus['notes'] ?? '')
                                          .isNotEmpty)
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Icon(Icons.notes,
                                                color: Colors.blue, size: 18),
                                            SizedBox(width: 8),
                                            Text(
                                              "Catatan: ",
                                              style: TextStyle(
                                                  fontFamily: 'Maison Bold',
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            Expanded(
                                              child: Text(
                                                tempStatus['notes'],
                                                style: TextStyle(
                                                    fontFamily: 'Maison Book',
                                                    fontSize: 12,
                                                    color: Colors.grey[700]),
                                              ),
                                            ),
                                          ],
                                        )
                                      else
                                        Row(
                                          children: [
                                            Icon(Icons.notes,
                                                color: Colors.blue, size: 18),
                                            SizedBox(width: 8),
                                            Text(
                                              "Catatan: ",
                                              style: TextStyle(
                                                  fontFamily: 'Maison Bold',
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            Expanded(
                                              child: Text(
                                                "Belum ada",
                                                style: TextStyle(
                                                    fontFamily: 'Maison Book',
                                                    fontSize: 12,
                                                    color: Colors.grey[500]),
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  )
                                else
                                  Text(
                                    "Tidak ada data status/catatan untuk asset ini.",
                                    style: TextStyle(
                                        fontFamily: 'Maison Book',
                                        fontSize: 12,
                                        color: Colors.grey[500]),
                                  ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: Text(
                                'Tutup',
                                style: TextStyle(
                                  fontFamily: 'Maison Bold',
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
                );
              }
            },
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Color(0xFF405189).withOpacity(0.08),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Asset Image
                  Container(
                    width: 48,
                    height: 48,
                    margin: EdgeInsets.symmetric(horizontal: 12),
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
                                      fontFamily: 'Maison Bold',
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
                                fontFamily: 'Maison Bold',
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF405189),
                              ),
                            ),
                          ),
                  ),
                  // Asset Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          asset.name,
                          style: TextStyle(
                            fontFamily: 'Maison Bold',
                            fontSize: 13,
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
                            fontFamily: 'Maison Book',
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Color(0xFF405189).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                asset.category,
                                style: TextStyle(
                                  fontFamily: 'Maison Bold',
                                  fontSize: 10,
                                  color: Color(0xFF405189),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                asset.location,
                                style: TextStyle(
                                  fontFamily: 'Maison Book',
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Action Buttons or Status
                  if (!isScanned)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _actionButton(
                            label: "Scan",
                            color: Color(0xFF405189),
                            onPressed: () => onScan?.call(asset),
                          ),
                          SizedBox(height: 4),
                          _actionButton(
                            label: "Manual",
                            color: Colors.orange,
                            onPressed: () => onManualScan?.call(asset),
                          ),
                        ],
                      ),
                    )
                  else
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "Scanned",
                          style: TextStyle(
                            fontSize: 11,
                            fontFamily: 'Maison Bold',
                            color: Colors.green[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
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
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.3), width: 0.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Maison Bold',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }
}
