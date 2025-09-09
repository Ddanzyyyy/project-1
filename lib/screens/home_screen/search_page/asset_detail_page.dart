import 'package:Simba/screens/home_screen/search_page/asset_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AssetDetailPage extends StatelessWidget {
  final AssetModel asset;

  const AssetDetailPage({Key? key, required this.asset}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    final List<String> images = asset.imageUrl.isNotEmpty
        ? asset.imageUrl.split(',').map((e) => e.trim()).toList()
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
          title: const Text(
            'Detail Asset',
            style: TextStyle(
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
                  if (asset.assetCode != null && asset.assetCode!.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFF818592).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        asset.assetCode!,
                        style: TextStyle(
                          fontFamily: 'Maison Book',
                          fontSize: 12,
                          color: Color(0xFF405189),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  SizedBox(height: 16),

                  if (asset.category != null && asset.category!.isNotEmpty)
                    _buildInfoRow('Kategori', asset.category!),
                  _buildInfoRow('Lokasi', asset.location),
                  if (asset.pic != null && asset.pic!.isNotEmpty)
                    _buildInfoRow('PIC', asset.pic!),
                  if (asset.division.isNotEmpty)
                    _buildInfoRow('Divisi', asset.division),
                  _buildInfoRow('Status', asset.status, status: true),
                  if (asset.createdAt != null && asset.createdAt!.isNotEmpty)
                    _buildInfoRow('Tanggal Input', _formatWIBDate(asset.createdAt)),

                  if (asset.description != null && asset.description!.isNotEmpty) ...[
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
                      asset.description!,
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
            if (asset.status.toLowerCase() == 'lost')
              _lostGuideCard()
            else if (asset.status.toLowerCase() == 'damaged')
              _damagedGuideCard()
            else if (asset.status.toLowerCase() == 'unscanned')
              _scanGuideCard()
            else if (asset.status.toLowerCase() == 'registered')
              _registeredGuideCard()
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(AssetModel asset) {
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
                    _statusText(value),
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

  String _statusText(String status) {
    switch (status.toLowerCase()) {
      case "registered":
        return "Registered";
      case "unscanned":
        return "Unscanned";
      case "damaged":
        return "Damaged";
      case "lost":
        return "Lost";
      default:
        return status;
    }
  }

  Color _colorStatus(String status) {
    switch (status.toLowerCase()) {
      case "registered":
        return Color(0xFF10B981); // Hijau
      case "unscanned":
        return Color(0xFFF59E0B); // Kuning
      case "damaged":
        return Color(0xFFEF4444); // Merah
      case "lost":
        return Color(0xFFEF4444); // Merah
      default:
        return Colors.grey;
    }
  }

  Color _colorStatusBg(String status) {
    switch (status.toLowerCase()) {
      case "registered":
        return Color(0xFFE7F7EE); // Hijau muda
      case "unscanned":
        return Color(0xFFFFF7E7); // Kuning muda
      case "damaged":
        return Color(0xFFFEE4E4); // Merah muda
      case "lost":
        return Color(0xFFFEE4E4); // Merah muda
      default:
        return Color(0xFFE7E9F0);
    }
  }

  Widget _lostGuideCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFFEE4E4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Color(0xFFEF4444),
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
                color: Color(0xFFEF4444),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Panduan Asset Hilang',
                style: TextStyle(
                  fontFamily: 'Maison Bold',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFEF4444),
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
              color: Color(0xFFEF4444),
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
        color: Color(0xFFFEE4E4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Color(0xFFEF4444),
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
                color: Color(0xFFEF4444),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Panduan Damaged Asset',
                style: TextStyle(
                  fontFamily: 'Maison Bold',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFEF4444),
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
              color: Color(0xFFEF4444),
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
        color: Color(0xFFFFF7E7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Color(0xFFF59E0B),
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
                color: Color(0xFFF59E0B),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Panduan Scan Asset',
                style: TextStyle(
                  fontFamily: 'Maison Bold',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFF59E0B),
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
              color: Color(0xFFF59E0B),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _registeredGuideCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFE7F7EE),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Color(0xFF10B981),
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
                color: Color(0xFF10B981),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Panduan Asset Registered',
                style: TextStyle(
                  fontFamily: 'Maison Bold',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF10B981),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Asset sudah teregister dan aktif.\n'
            'Cek data secara berkala untuk update status.',
            style: TextStyle(
              fontFamily: 'Maison Book',
              fontSize: 10,
              color: Color(0xFF10B981),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}