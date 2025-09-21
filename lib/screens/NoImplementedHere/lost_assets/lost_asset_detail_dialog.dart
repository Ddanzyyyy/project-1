import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const primaryColor = Color(0xFF405189);

class LostAssetDetailDialog extends StatelessWidget {
  final Map asset;
  const LostAssetDetailDialog({Key? key, required this.asset}) : super(key: key);

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
    final List<String> images = (asset['image_path'] != null && asset['image_path'].toString().isNotEmpty)
        ? asset['image_path'].toString().split(',').map((e) => e.trim()).toList()
        : [];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(16),
        width: 400,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                      ),
                      child: Icon(Icons.info_outline, color: primaryColor, size: 24),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Detail Asset Hilang',
                      style: TextStyle(
                        fontFamily: 'Maison Bold',
                        fontSize: 15,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
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
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: primaryColor.withOpacity(0.1),
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
              SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(14),
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
                      asset['name'] ?? '-',
                      style: TextStyle(
                        fontFamily: 'Maison Bold',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
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
                        asset['asset_code'] ?? '-',
                        style: TextStyle(
                          fontFamily: 'Maison Book',
                          fontSize: 12,
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildInfoRow('Kategori', asset['category'] ?? '-'),
                    _buildInfoRow('Lokasi', asset['location'] ?? '-'),
                    _buildInfoRow('PIC', asset['pic'] ?? '-'),
                    _buildInfoRow('Status', asset['status'] ?? '-', status: true),
                    _buildInfoRow('Tanggal Input', _formatWIBDate(asset['created_at']?.toString())),
                    if ((asset['description'] ?? '').toString().isNotEmpty) ...[
                      SizedBox(height: 12),
                      Divider(color: Colors.grey[300]),
                      SizedBox(height: 12),
                      Text(
                        'Deskripsi',
                        style: TextStyle(
                          fontFamily: 'Maison Bold',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        asset['description'] ?? '-',
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
              SizedBox(height: 20),
              // Guide Hilang
              // if ((asset['status']?.toString().toLowerCase() ?? '') == 'lost')
              //   _lostGuideCard(),
              // // Info asset status lost
              // SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange[700], size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Asset ini berstatus "Lost" di registered asset jika ditemukan segera laporkan dengan update status ke registered kemudian isi form laporan kehilangan.',
                        style: TextStyle(
                          fontFamily: 'Maison Book',
                          fontSize: 10,
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: Text(
                      'Tutup',
                      style: TextStyle(
                        fontFamily: 'Maison Bold',
                        color: primaryColor,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(Map asset) {
    return Container(
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Text(
                (asset['name'] ?? '-').toString().substring(0, 1).toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Maiso nBold',
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
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
                color: primaryColor,
              ),
            ),
          ),
          Text(
            ': ',
            style: TextStyle(
              fontFamily: 'Maison Book',
              fontSize: 13,
              color: primaryColor,
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
        return Color(0xFFE7F7EE); 
      case "unscanned":
        return Color(0xFFFFF7E7); 
      case "damaged":
        return Color(0xFFFEE4E4); 
      case "lost":
        return Color(0xFFFEE4E4); 
      default:
        return Color(0xFFE7E9F0);
    }
  }

  // Widget _lostGuideCard() {
  //   return Container(
  //     width: double.infinity,
  //     padding: EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Color(0xFFFEE4E4),
  //       borderRadius: BorderRadius.circular(10),
  //       border: Border.all(
  //         color: Color(0xFFEF4444),
  //         width: 1,
  //       ),
  //     ),
      // child: Column(
      //   crossAxisAlignment: CrossAxisAlignment.start,
      //   children: [
      //     Row(
      //       children: [
      //         Icon(
      //           Icons.info_outline,
      //           color: Color(0xFFEF4444),
      //           size: 20,
      //         ),
      //         SizedBox(width: 8),
      //         Text(
      //           'Panduan Asset Hilang',
      //           style: TextStyle(
      //             fontFamily: 'Maison Bold',
      //             fontSize: 14,
      //             fontWeight: FontWeight.w600,
      //             color: Color(0xFFEF4444),
      //           ),
      //         ),
      //       ],
      //     ),
      //     SizedBox(height: 8),
      //     Text(
      //       'Cek detail asset hilang.\n'
      //       'Laporkan temuan asset dengan prosedur.\n'
      //       'Update status asset bila ditemukan atau diinput ulang.',
      //       style: TextStyle(
      //         fontFamily: 'Maison Book',
      //         fontSize: 10,
      //         color: Color(0xFFEF4444),
      //         height: 1.4,
      //       ),
      //     ),
      //   ],
      // ),
    
  }
