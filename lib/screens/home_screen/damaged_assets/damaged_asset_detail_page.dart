import 'package:Simba/screens/home_screen/damaged_assets/damaged_report_form.dart';
import 'package:Simba/screens/home_screen/damaged_assets/damaged_report_list.dart';
import 'package:flutter/material.dart';
import 'package:Simba/screens/registered_page/asset_model.dart';
import 'package:Simba/screens/home_screen/damaged_assets/damage_report_model.dart';
import 'package:Simba/screens/home_screen/damaged_assets/damage_report_service.dart';
import 'package:intl/intl.dart';

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
      damageReports =
          await DamageReportService.getDamageReports(assetId: widget.asset.id);
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

  @override
  Widget build(BuildContext context) {
    final asset = widget.asset;
    final List<String> images = asset.imagePath.isNotEmpty
        ? asset.imagePath.split(',').map((e) => e.trim()).toList()
        : [];

    // Format tanggal input dari database field createdAt (WIB)
    String formattedDateInput =
        asset.createdAt.isNotEmpty ? _formatWIBDate(asset.createdAt) : '';

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xFF405189),
          elevation: 0,
          leading: IconButton(
            icon:
                const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Detail Asset Rusak',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Maison Bold',
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
            // Asset Image
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
                            errorBuilder: (context, error, stackTrace) =>
                                Center(
                              child: Icon(Icons.broken_image,
                                  color: Colors.white, size: 48),
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
                      fontFamily: 'Maison Bold',
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
                        fontFamily: 'Maison Bold',
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
                  if (formattedDateInput.isNotEmpty)
                    _buildInfoRow('Tanggal Input', formattedDateInput),
                  if (asset.description.isNotEmpty) ...[
                    SizedBox(height: 12),
                    Divider(color: Colors.grey[300]),
                    SizedBox(height: 12),
                    Text(
                      'Deskripsi',
                      style: TextStyle(
                        fontFamily: 'Maison Bold',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF405189),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      asset.description,
                      style: TextStyle(
                        fontFamily: 'Maison Book',
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
            DamageReportList(
              assetId: asset.id,
              damageReports: damageReports,
              isLoadingReport: isLoadingReport,
              reloadReports: _loadDamageReport,
            ),

            SizedBox(height: 20),

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
                          fontFamily: 'Maison Bold',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Cek detail asset rusak.\n'
                    'Laporkan kerusakan dengan tombol di kanan atas.\n'
                    'Update status atau riwayat perbaikan dari laporan kerusakan.',
                    style: TextStyle(
                      fontFamily: 'Maison Book',
                      fontSize: 10,
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
                  fontFamily: 'Maison Bold',
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
                fontFamily: 'Maison Book',
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
                fontFamily: 'Maison Bold',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF405189),
              ),
            ),
          ),
          Text(
            ': ',
            style: TextStyle(
              fontFamily: 'Maison Book',
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
                      fontFamily: 'Maison Bold',
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
                      fontFamily: 'Maison Book',
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

  String _formatWIBDate(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) return "-";
    try {
      DateTime utcDate = DateTime.parse(createdAt);
      DateTime wibDate = utcDate.add(Duration(hours: 7));
      return DateFormat('dd MMM yyyy HH:mm', 'id_ID').format(wibDate) + ' WIB';
    } catch (e) {
      return createdAt;
    }
  }
}
