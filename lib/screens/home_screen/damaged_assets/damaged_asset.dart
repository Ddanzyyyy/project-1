import 'package:Simba/screens/home_screen/damaged_assets/detail_damage_laporan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:Simba/screens/registered_page/asset_model.dart';
import 'package:Simba/screens/registered_page/asset_service.dart';
import 'package:Simba/screens/home_screen/damaged_assets/damage_report_model.dart';
import 'package:Simba/screens/home_screen/damaged_assets/damage_report_service.dart';

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
                        style: TextStyle(fontSize: 14, fontFamily: 'Inter'),
                        decoration: InputDecoration(
                          hintText: 'Cari asset rusak...',
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
                                        fontFamily: 'Inter',
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Semua asset dalam kondisi baik',
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

class DamagedAssetCard extends StatelessWidget {
  final Asset asset;
  const DamagedAssetCard({Key? key, required this.asset}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DamagedAssetDetailPage(asset: asset),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Detail Page Asset Rusak Mirror UnscannedAssetDetail ---
class DamagedAssetDetailPage extends StatefulWidget {
  final Asset asset;

  const DamagedAssetDetailPage({
    Key? key,
    required this.asset,
  }) : super(key: key);

  @override
  State<DamagedAssetDetailPage> createState() => _DamagedAssetDetailPageState();
}

class _DamagedAssetDetailPageState extends State<DamagedAssetDetailPage> {
  List<DamageReport> damageReports = [];
  bool isLoadingReport = true;

  @override
  void initState() {
    super.initState();
    _loadDamageReport();
  }

  Future<void> _loadDamageReport() async {
    setState(() => isLoadingReport = true);
    try {
      damageReports = await DamageReportService.getDamageReports(assetId: widget.asset.id);
    } catch (e) {}
    setState(() => isLoadingReport = false);
  }

  void _showReportForm() async {
    final result = await showDialog(
      context: context,
      builder: (context) => DamageReportForm(assetId: widget.asset.id),
    );
    if (result == true) _loadDamageReport();
  }

  void _showUpdateStatus(DamageReport report) async {
    final result = await showDialog(
      context: context,
      builder: (context) => DamageStatusForm(report: report),
    );
    if (result == true) _loadDamageReport();
  }

  @override
  Widget build(BuildContext context) {
    final asset = widget.asset;
    final List<String> images = asset.imagePath.isNotEmpty
        ? asset.imagePath.split(',').map((e) => e.trim()).toList()
        : [];

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xFF405189),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Detail Asset Rusak',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.add_photo_alternate, color: Colors.white),
              tooltip: 'Laporkan Kerusakan',
              onPressed: _showReportForm,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Asset Image with full screen feature
            GestureDetector(
              onTap: () {
                if (images.isNotEmpty) {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      backgroundColor: Colors.black,
                      insetPadding: EdgeInsets.all(12),
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            images[0],
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Center(
                              child: Icon(Icons.broken_image, color: Colors.white, size: 48),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Color(0xFF405189).withOpacity(0.1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: images.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          images[0],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholderImage(asset),
                        ),
                      )
                    : _buildPlaceholderImage(asset),
              ),
            ),
            SizedBox(height: 20),

            // Asset Info Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asset.name,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF405189),
                    ),
                  ),
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFFEF4444).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      asset.assetCode,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFFEF4444),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  _buildInfoRow('Kategori', asset.category),
                  _buildInfoRow('Lokasi', asset.location),
                  _buildInfoRow('PIC', asset.pic),
                  _buildInfoRow('Status', asset.status, status: true),
                  if (asset.dateAdded.isNotEmpty)
                    _buildInfoRow('Tanggal Input', asset.dateAdded),

                  if (asset.description.isNotEmpty) ...[
                    SizedBox(height: 12),
                    Divider(color: Colors.grey[300]),
                    SizedBox(height: 12),
                    Text(
                      'Deskripsi',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF405189),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      asset.description,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 24),

            // Damage Reports List
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Laporan Kerusakan',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF405189),
                    ),
                  ),
                  SizedBox(height: 10),
                  isLoadingReport
                      ? Center(child: CircularProgressIndicator(color: Color(0xFF405189)))
                      : damageReports.isEmpty
                          ? _emptyReport()
                          : Column(
                              children: [
                                for (int i = 0; i < damageReports.length; i++) ...[
                                  _damageReportCard(damageReports[i], context),
                                  if (i < damageReports.length - 1)
                                    Divider(thickness: 1, color: Color(0xFFE7E9F0)),
                                ]
                              ],
                            ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Panduan Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.red[200]!,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.red[600],
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Panduan Asset Rusak',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Cek detail asset rusak.\n'
                    '• Laporkan kerusakan dengan tombol di kanan atas.\n'
                    '• Update status atau riwayat perbaikan dari laporan kerusakan.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Colors.red[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(Asset asset) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF405189).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF405189).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Text(
                asset.name.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF405189),
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tidak ada gambar',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool status = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF405189),
              ),
            ),
          ),
          Text(
            ': ',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: Color(0xFF405189),
            ),
          ),
          status
              ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _colorStatusBg(value),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: _colorStatus(value),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                )
              : Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Color _colorStatus(String status) {
    switch (status) {
      case "rusak berat":
        return Color(0xFFD90429);
      case "rusak ringan":
        return Color(0xFFF7B801);
      case "butuh perbaikan":
        return Color(0xFF405189);
      case "damaged":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _colorStatusBg(String status) {
    switch (status) {
      case "rusak berat":
        return Color(0xFFFEE4E4);
      case "rusak ringan":
        return Color(0xFFFFF9E4);
      case "butuh perbaikan":
        return Color(0xFFE8ECFB);
      default:
        return Color(0xFFE7E9F0);
    }
  }

  Widget _damageReportCard(DamageReport report, BuildContext context) {
  return Slidable(
    key: ValueKey(report.id),
    startActionPane: ActionPane(
      motion: const DrawerMotion(),
      children: [
        SlidableAction(
          onPressed: (context) => _showUpdateStatus(report),
          backgroundColor: Color(0xFF405189),
          foregroundColor: Colors.white,
          icon: Icons.edit_outlined,
          label: 'Edit',
        ),
      ],
    ),
    endActionPane: ActionPane(
      motion: const DrawerMotion(),
      children: [
        SlidableAction(
          onPressed: (context) async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text('Hapus Laporan'),
                content: Text('Yakin ingin menghapus laporan kerusakan ini?'),
                
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text('Batal'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text('Hapus'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              final success = await DamageReportService.deleteDamageReport(report.id);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Laporan berhasil dihapus'), backgroundColor: Colors.green),
                );
                // Refresh list
                if (context.mounted) {
                  final state = context.findAncestorStateOfType<_DamagedAssetDetailPageState>();
                  state?._loadDamageReport();
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal menghapus laporan'), backgroundColor: Colors.red),
                );
              }
            }
          },
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          icon: Icons.delete_outline,
          label: 'Hapus',
        ),
      ],
    ),
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      elevation: 0,
      color: Colors.white,
      margin: EdgeInsets.only(bottom: 18),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailLaporanDamagePage(report: report),
            ),
          );
        },
        borderRadius: BorderRadius.circular(13),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (report.imageUrl != null && report.imageUrl!.isNotEmpty)
                    GestureDetector(
                      onTap: () => _showFullImage(context, report.imageUrl!),
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Color(0xFF405189).withOpacity(0.09),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(9),
                          child: Image.network(report.imageUrl!, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.status,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: _colorStatus(report.status),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          report.description,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Dilaporkan: ${report.dateReported}',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (report.repairHistory.isNotEmpty) ...[
                SizedBox(height: 12),
                Divider(thickness: 0.7, color: Color(0xFFE7E9F0)),
                Padding(
                  padding: EdgeInsets.only(top: 5, bottom: 6),
                  child: Text(
                    'Riwayat Perbaikan:',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Color(0xFF405189),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                ...report.repairHistory.map((rh) => ListTile(
                      leading: rh.imageUrl != null && rh.imageUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(rh.imageUrl!, width: 32, height: 32, fit: BoxFit.cover),
                            )
                          : Icon(Icons.build, color: Color(0xFF405189)),
                      title: Text(
                        rh.action,
                        style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 13),
                      ),
                      subtitle: Text(
                        '${rh.dateRepaired}${rh.notes != null && rh.notes!.isNotEmpty ? ' - ${rh.notes}' : ''}',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.grey[600]),
                      ),
                    )),
              ]
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _emptyReport() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.report_gmailerrorred, color: Color(0xFFBDBDBD), size: 46),
            SizedBox(height: 10),
            Text(
              'Tidak ada laporan kerusakan',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Asset ini belum pernah dilaporkan rusak',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                  child: Icon(Icons.broken_image, color: Colors.white, size: 48),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DamageReportForm extends StatefulWidget {
  final String assetId;
  DamageReportForm({required this.assetId});

  @override
  State<DamageReportForm> createState() => _DamageReportFormState();
}

class _DamageReportFormState extends State<DamageReportForm> {
  final descController = TextEditingController();
  String status = 'rusak ringan';
  XFile? imageFile;
  bool isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => imageFile = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 20,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(0xFF405189).withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.report, color: Color(0xFF405189), size: 26),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Form Laporkan Kerusakan',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF405189),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                
                // Status Dropdown
                DropdownButtonFormField<String>(
                  value: status,
                  items: [
                    DropdownMenuItem(
                      value: 'rusak ringan',
                      child: Text('Rusak Ringan', style: TextStyle(fontFamily: 'Inter')),
                    ),
                    DropdownMenuItem(
                      value: 'rusak berat',
                      child: Text('Rusak Berat', style: TextStyle(fontFamily: 'Inter')),
                    ),
                    DropdownMenuItem(
                      value: 'butuh perbaikan',
                      child: Text('Butuh Perbaikan', style: TextStyle(fontFamily: 'Inter')),
                    ),
                  ],
                  onChanged: (val) => setState(() => status = val ?? 'rusak ringan'),
                  decoration: InputDecoration(
                    labelText: 'Status Kerusakan',
                    labelStyle: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
                    fillColor: Color(0xFFF6F7FB),
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                SizedBox(height: 16),

                // Deskripsi Kerusakan
                TextField(
                  controller: descController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Deskripsi Kerusakan',
                    labelStyle: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
                    hintText: 'Jelaskan secara detail kerusakan asset...',
                    hintStyle: TextStyle(fontFamily: 'Inter', color: Colors.grey[400]),
                    fillColor: Color(0xFFF6F7FB),
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  style: TextStyle(fontFamily: 'Inter'),
                ),
                SizedBox(height: 16),

                // Foto Kerusakan
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: Icon(Icons.photo, size: 20),
                      label: Text('Upload Foto', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF405189),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                    ),
                    if (imageFile != null)
                      Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFE8ECFB),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: Color(0xFF405189), size: 16),
                              SizedBox(width: 6),
                              Text('Foto dipilih', style: TextStyle(fontSize: 12, fontFamily: 'Inter', color: Color(0xFF405189))),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                if (imageFile != null) ...[
                  SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(imageFile!.path),
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
                SizedBox(height: 28),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('Batal', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, color: Colors.grey[600])),
                    ),
                    SizedBox(width: 14),
                    ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              setState(() => isLoading = true);
                              final imageUrl = await DamageReportService.uploadImage(imageFile);
                              final success = await DamageReportService.createDamageReport(
                                assetId: widget.assetId,
                                description: descController.text,
                                status: status,
                                imageUrl: imageUrl,
                              );
                              if (!success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Gagal input laporan kerusakan'), backgroundColor: Colors.red),
                                );
                              }
                              setState(() => isLoading = false);
                              Navigator.pop(context, true);
                            },
                      child: isLoading
                          ? SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              child: Text('Laporkan', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 15)),
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF405189),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------- FORM UPDATE STATUS ----------------------
class DamageStatusForm extends StatefulWidget {
  final DamageReport report;
  DamageStatusForm({required this.report});

  @override
  State<DamageStatusForm> createState() => _DamageStatusFormState();
}

class _DamageStatusFormState extends State<DamageStatusForm> {
  String status = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    status = widget.report.status;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 20,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFF405189).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.edit, color: Color(0xFF405189), size: 26),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Update Status Kerusakan',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF405189),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: status,
                items: [
                  DropdownMenuItem(value: 'rusak ringan', child: Text('Rusak Ringan', style: TextStyle(fontFamily: 'Inter'))),
                  DropdownMenuItem(value: 'rusak berat', child: Text('Rusak Berat', style: TextStyle(fontFamily: 'Inter'))),
                  DropdownMenuItem(value: 'butuh perbaikan', child: Text('Butuh Perbaikan', style: TextStyle(fontFamily: 'Inter'))),
                ],
                onChanged: (val) => setState(() => status = val ?? status),
                decoration: InputDecoration(
                  labelText: 'Status Kerusakan',
                  labelStyle: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
                  fillColor: Color(0xFFF6F7FB),
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('Batal', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, color: Colors.grey[600])),
                  ),
                  SizedBox(width: 14),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            setState(() => isLoading = true);
                            await DamageReportService.updateDamageReportStatus(widget.report.id, status);
                            setState(() => isLoading = false);
                            Navigator.pop(context, true);
                          },
                    child: isLoading
                        ? SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            child: Text('Update', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 15)),
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF405189),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}