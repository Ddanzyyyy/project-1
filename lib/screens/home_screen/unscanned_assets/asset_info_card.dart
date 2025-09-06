import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'asset_item.dart';

class AssetInfoCard extends StatelessWidget {
  final AssetItem asset;
  const AssetInfoCard({super.key, required this.asset});

  String _formatCreatedAt(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "-";
    try {
      DateTime dt = DateTime.parse(dateStr).toLocal();
      return DateFormat('dd MMM yyyy HH:mm WIB').format(dt);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (asset.image_path.isNotEmpty) {
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
                        asset.image_path.split(',')[0],
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            Center(child: Icon(Icons.broken_image, color: Colors.white, size: 48)),
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
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: Offset(0, 4))],
            ),
            child: asset.image_path.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      asset.image_path.split(',')[0],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(context, asset),
                    ),
                  )
                : _buildPlaceholderImage(context, asset),
          ),
        ),
        SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(asset.name, style: TextStyle(fontFamily: 'MaisonBold', fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF405189))),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0xFF405189).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(asset.asset_code, style: TextStyle(fontFamily: 'MaisonBold', fontSize: 12, color: Color(0xFF405189), fontWeight: FontWeight.w600)),
              ),
              SizedBox(height: 16),
              _buildInfoRow('Kategori', asset.category),
              _buildInfoRow('Lokasi', asset.location),
              _buildInfoRow('PIC', asset.pic),
              if (asset.created_at != null && asset.created_at?.isNotEmpty == true)
                _buildInfoRow('Tanggal Input', _formatCreatedAt(asset.created_at)),
              if (asset.description.isNotEmpty) ...[
                SizedBox(height: 12),
                Divider(color: Colors.grey[300]),
                SizedBox(height: 12),
                Text('Deskripsi', style: TextStyle(fontFamily: 'MaisonBold', fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF405189))),
                SizedBox(height: 4),
                Text(asset.description, style: TextStyle(fontFamily: 'MaisonBook', fontSize: 13, color: Colors.grey[700], height: 1.4)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage(BuildContext context, AssetItem asset) {
    return Container(
      decoration: BoxDecoration(color: Color(0xFF405189).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(color: Color(0xFF405189).withOpacity(0.2), shape: BoxShape.circle),
              child: Text(asset.name.substring(0, 1).toUpperCase(), style: TextStyle(fontFamily: 'MaisonBold', fontSize: 32, fontWeight: FontWeight.w700, color: Color(0xFF405189))),
            ),
            SizedBox(height: 8),
            Text('Tidak ada gambar', style: TextStyle(fontFamily: 'MaisonBook', fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(fontFamily: 'MaisonBold', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF405189))),
          ),
          Text(': ', style: TextStyle(fontFamily: 'MaisonBook', fontSize: 13, color: Color(0xFF405189))),
          Expanded(child: Text(value, style: TextStyle(fontFamily: 'MaisonBook', fontSize: 13, color: Colors.grey[700]))),
        ],
      ),
    );
  }
}