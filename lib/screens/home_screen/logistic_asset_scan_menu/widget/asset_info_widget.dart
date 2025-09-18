import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:Simba/screens/home_screen/logistic_asset/model/logistic_asset_model.dart';
import '../screen/asset_upload_dialog.dart';

const warnaColor = Colors.white;
const primaryColor = Color(0xFF405189);

class AssetInfoWidget extends StatefulWidget {
  final LogisticAsset asset;
  final VoidCallback? onUploadSuccess; 

  const AssetInfoWidget({
    Key? key,
    required this.asset,
    this.onUploadSuccess,
  }) : super(key: key);

  @override
  State<AssetInfoWidget> createState() => _AssetInfoWidgetState();
}

class _AssetInfoWidgetState extends State<AssetInfoWidget> {
  late LogisticAsset asset;

  @override
  void initState() {
    super.initState();
    asset = widget.asset;
  }

  void _showUploadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AssetUploadDialog(asset: asset),
    ).then((result) {
      if (result == true) {
        // Panggil callback untuk update photos_count di parent
        if (widget.onUploadSuccess != null) {
          widget.onUploadSuccess!();
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Foto asset berhasil diupload!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: InteractiveViewer(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.white,
                    height: 300,
                    child: Center(
                      child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informasi Asset',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
            fontFamily: 'Maison Bold',
          ),
        ),
        const SizedBox(height: 16),

        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFF405189).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      asset.assetNo,
                      style: TextStyle(
                        fontFamily: 'Maison Bold',
                        fontSize: 14,
                        color: Color(0xFF405189),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(asset.assetStatus).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      asset.assetStatus,
                      style: TextStyle(
                        fontFamily: 'Maison Bold',
                        fontSize: 12,
                        color: _getStatusColor(asset.assetStatus),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                asset.title,
                style: TextStyle(
                  fontFamily: 'Maison Bold',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                asset.assetSpecification,
                style: TextStyle(
                  fontFamily: 'Maison Book',
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 16),

        // Information Card
        _buildInfoCard('Full Information', [
          const SizedBox(height: 8),
          _buildInfoRow('Title', asset.title),
          _buildInfoRow('Asset No', asset.assetNo),
          _buildInfoRow('General Account', asset.generalAccount),
          _buildInfoRow('Category', asset.category),
          _buildInfoRow('Sub Category', asset.subCategory),
          _buildInfoRow('Subsidiary Account', asset.subsidiaryAccount),
          _buildInfoRow('Asset Specification', asset.assetSpecification),
          _buildInfoRow(
              'Acquisition Date',
              asset.acquisitionDate != null
                  ? DateFormat('dd MMM yyyy').format(asset.acquisitionDate!)
                  : '-'),
          _buildInfoRow('Aging', '${asset.aging}'),
          _buildInfoRow('Quantity', asset.quantity.toString()),
          _buildInfoRow('Department', asset.department),
          _buildInfoRow('Control Department', asset.controlDepartment),
          _buildInfoRow('Cost Center', asset.costCenter),
          _buildInfoRow('Asset Status', asset.assetStatus),
          _buildInfoRow('Remarks', asset.remarks.isNotEmpty ? asset.remarks : '-')
        ]),

        SizedBox(height: 16),

        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Status Summary',
                style: TextStyle(
                  fontFamily: 'Maison Bold',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF405189),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatusCard('Available', asset.available, Colors.green),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildStatusCard('Broken', asset.broken, Colors.orange),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildStatusCard('Lost', asset.lost, Colors.red),
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: 16),

        // Asset Photo Section
        Text(
          'Foto Asset',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
            fontFamily: 'Maison Bold',
          ),
        ),
        const SizedBox(height: 16),

        if (asset.primaryPhoto != null && asset.primaryPhoto!.fileUrl.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Foto Asset Saat Ini',
                  style: TextStyle(
                    fontFamily: 'Maison Bold',
                    fontSize: 14,
                    color: Color(0xFF405189),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _showFullImage(context, asset.primaryPhoto!.fileUrl),
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        asset.primaryPhoto!.fileUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[100],
                            child: const Center(
                              child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[100],
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                                color: const Color(0xFF405189),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap untuk memperbesar foto',
                  style: TextStyle(
                    fontFamily: 'Maison Book',
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
        ] else if (asset.photos != null && asset.photos!.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Foto Asset Saat Ini',
                  style: TextStyle(
                    fontFamily: 'Maison Bold',
                    fontSize: 14,
                    color: Color(0xFF405189),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _showFullImage(context, asset.photos!.first.fileUrl),
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        asset.photos!.first.fileUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[100],
                            child: const Center(
                              child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap untuk memperbesar foto',
                  style: TextStyle(
                    fontFamily: 'Maison Book',
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
        ],

        // Upload Photo Section
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, primaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upload Foto Asset',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Maison Bold',
                          ),
                        ),
                        Text(
                          'Dokumentasi visual untuk asset ini',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                            fontFamily: 'Maison Book',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.camera_alt, color: primaryColor),
                  label: Text(
                    'Upload Foto Asset',
                    style: TextStyle(
                      color: primaryColor,
                      fontFamily: 'Maison Bold',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => _showUploadDialog(context),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Maison Bold',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF405189),
            ),
          ),
          SizedBox(height: 16),
          ...children,
        ],
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
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Maison Bold',
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            ': ',
            style: TextStyle(
              fontFamily: 'Maison Book',
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '-',
              style: TextStyle(
                fontFamily: 'Maison Book',
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String label, int count, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          count == 1
              ? Icon(
                  Icons.done,
                  color: color,
                  size: 30,
                )
              : Text(
                  count.toString(),
                  style: TextStyle(
                    fontFamily: 'Maison Bold',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Maison Bold',
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'available':
        return Colors.green;
      case 'inactive':
      case 'broken':
      case 'damaged':
        return Colors.orange;
      case 'disposed':
      case 'lost':
        return Colors.red;
      case 'maintenance':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}