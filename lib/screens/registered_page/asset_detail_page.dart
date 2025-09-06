import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'asset_model.dart';

class AssetDetailPage extends StatefulWidget {
  final Asset asset;
  const AssetDetailPage({Key? key, required this.asset}) : super(key: key);

  @override
  State<AssetDetailPage> createState() => _AssetDetailPageState();
}

class _AssetDetailPageState extends State<AssetDetailPage> {
  /// Format created_at (from DB) to Indonesia date and WIB time
  String _formatWIBDate(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) return "-";
    try {
      // Parse as UTC then add 7 hours for WIB
      DateTime utcDate = DateTime.parse(createdAt);
      DateTime wibDate = utcDate.add(Duration(hours: 7));
      return DateFormat('dd MMM yyyy HH:mm', 'id_ID').format(wibDate) + ' WIB';
    } catch (e) {
      return createdAt;
    }
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
            'Detail Asset',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Maison Bold',
            ),
          ),
          centerTitle: true,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
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
                          borderRadius: BorderRadius.circular(10),
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
                  borderRadius: BorderRadius.circular(10),
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
                        borderRadius: BorderRadius.circular(10),
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
                borderRadius: BorderRadius.circular(10),
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
                      color: Color(0xFF818592).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      asset.assetCode,
                      style: TextStyle(
                        fontFamily: 'Maison Book',
                        fontSize: 12,
                        color: Color(0xFF405189),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  _buildInfoRow('Kategori', asset.category),
                  _buildInfoRow('Lokasi', asset.location),
                  _buildInfoRow('PIC', asset.pic),
                  _buildInfoRow('Status', asset.status, status: true),
                  // Tanggal input dari created_at
                  _buildInfoRow('Tanggal Input', _formatWIBDate(asset.createdAt)),

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

            // Panduan Card sesuai status
            if (asset.status == 'lost')
              _lostGuideCard()
            else if (asset.status == 'damaged')
              _damagedGuideCard()
            else if (asset.status == 'unscanned')
              _scanGuideCard()
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(Asset asset) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF405189).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
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
      case "lost":
        return Colors.red;
      case "damaged":
        return Colors.orange;
      case "active":
        return Color(0xFF405189);
      case "unscanned":
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }

  Color _colorStatusBg(String status) {
    switch (status) {
      case "lost":
        return Color(0xFFFEE4E4);
      case "damaged":
        return Color(0xFFFFF9E4);
      case "active":
        return Color(0xFFE8ECFB);
      case "unscanned":
        return Color(0xFFE0F2F1);
      default:
        return Color(0xFFE7E9F0);
    }
  }

  Widget _lostGuideCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(10),
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
                'Panduan Asset Hilang',
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
            '• Cek detail asset hilang.\n'
            '• Laporkan temuan asset dengan prosedur.\n'
            '• Update status asset bila ditemukan atau diinput ulang.',
            style: TextStyle(
              fontFamily: 'Maison Book',
              fontSize: 12,
              color: Colors.red[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _damagedGuideCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.orange[200]!,
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
                color: Colors.orange[600],
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Panduan Damaged Asset',
                style: TextStyle(
                  fontFamily: 'Maison Bold',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Cek detail asset rusak.\n'
            'Laporkan kerusakan di halaman Damaged.\n'
            'Asset Status Otomatis Terupdate.',
            style: TextStyle(
              fontFamily: 'Maison Book',
              fontSize: 10,
              color: Colors.orange[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _scanGuideCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.blueGrey[200]!,
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
                color: Colors.blueGrey[600],
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Panduan Scan Asset',
                style: TextStyle(
                  fontFamily: 'Maison Bold',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Arahkan kamera ke Barcode asset di Halaman Unscanned Asset.\n'
            'Pastikan data asset di Registered.\n'
            'Update status asset Otomatis bila proses scan berhasil.',
            style: TextStyle(
              fontFamily: 'Maison Book',
              fontSize: 10,
              color: Colors.blueGrey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}