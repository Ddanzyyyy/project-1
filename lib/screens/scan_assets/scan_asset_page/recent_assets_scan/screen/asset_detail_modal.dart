import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/asset.dart';
import 'package:Simba/screens/home_screen/logistic_asset_scan_menu/screen/asset_upload_dialog.dart';
import 'package:Simba/screens/home_screen/logistic_asset/model/logistic_asset_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class AssetDetailModal extends StatefulWidget {
  final Asset asset;
  final bool showUploadPhotoButton;
  final VoidCallback? onPhotoUploaded; 

  const AssetDetailModal({
    Key? key,
    required this.asset,
    this.showUploadPhotoButton = false,
    this.onPhotoUploaded,
  }) : super(key: key);

  @override
  State<AssetDetailModal> createState() => _AssetDetailModalState();
}

class _AssetDetailModalState extends State<AssetDetailModal> {
  late Asset asset;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    asset = widget.asset;
  }

  Future<void> _refreshPhotosCount() async {
    setState(() { isLoading = true; });
    try {
      final recentAssetId = asset.id;
      final url = Uri.parse('http://192.168.8.129:8000/api/recent-assets/$recentAssetId/photos-count');
      final response = await http.patch(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          setState(() {
            asset = asset.copyWith(photosCount: data['data']['photos_count']);
          }); 
        }
      }
    } catch (e) {}
    setState(() { isLoading = false; });
  }

  Future<void> _showUploadPhotoDialog(BuildContext context) async {
    final logisticAsset = _assetToLogisticAsset(asset);
    final result = await showDialog(
      context: context,
      builder: (ctx) => AssetUploadDialog(asset: logisticAsset),
    );
    
    if (result == true) {
      await _refreshPhotosCount();
      
      if (widget.onPhotoUploaded != null) {
        widget.onPhotoUploaded!();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Foto asset berhasil diupload!'), 
          backgroundColor: Colors.green
        ),
      );
    }
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

  LogisticAsset _assetToLogisticAsset(Asset asset) {
    return LogisticAsset(
      id: asset.id.toString(),
      title: asset.name,
      assetNo: asset.assetCode,
      generalAccount: asset.generalAccount ?? '',
      subsidiaryAccount: asset.subsidiaryAccount ?? '',
      category: asset.category,
      subCategory: asset.subCategory ?? '',
      assetSpecification: asset.assetSpecification ?? '',
      assetStatus: asset.status,
      acquisitionDate: asset.acquisitionDate ?? asset.createdAt,
      aging: asset.aging ?? '',
      quantity: asset.quantity ?? 1,
      department: asset.location,
      controlDepartment: asset.controlDepartment ?? '',
      costCenter: asset.costCenter ?? '',
      available: asset.available ?? (asset.status.toLowerCase() == 'available' ? 1 : 0),
      broken: asset.broken ?? (asset.status.toLowerCase() == 'broken' || asset.status.toLowerCase() == 'damaged' ? 1 : 0),
      lost: asset.lost ?? (asset.status.toLowerCase() == 'lost' ? 1 : 0),
      remarks: asset.remarks ?? asset.description,
      createdAt: asset.createdAt ?? DateTime.now(),
      updatedAt: asset.updatedAt ?? DateTime.now(),
      photos: asset.photos,
      primaryPhoto: asset.primaryPhoto,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 32,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Asset Detail',
                      style: TextStyle(
                        color: Color(0xFF405189),
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        fontFamily: 'Maison Bold',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF405189), size: 24),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(7),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF405189).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Text(
                                asset.assetCode,
                                style: const TextStyle(
                                  fontFamily: 'Maison Bold',
                                  fontSize: 14,
                                  color: Color(0xFF405189),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getStatusColor(asset.status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Text(
                                asset.status,
                                style: TextStyle(
                                  fontFamily: 'Maison Bold',
                                  fontSize: 12,
                                  color: _getStatusColor(asset.status),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          asset.name,
                          style: const TextStyle(
                            fontFamily: 'Maison Bold',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          asset.assetSpecification ?? asset.description,
                          style: TextStyle(
                            fontFamily: 'Maison Book',
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Full Information
                  _buildInfoCard('Full Information', [
                    _buildInfoRow('Title', asset.name),
                    _buildInfoRow('Asset No', asset.assetCode),
                    _buildInfoRow('General Account', asset.generalAccount ?? '-'),
                    _buildInfoRow('Category', asset.category),
                    _buildInfoRow('Sub Category', asset.subCategory ?? '-'),
                    _buildInfoRow('Subsidiary Account', asset.subsidiaryAccount ?? '-'),
                    _buildInfoRow('Asset Specification', asset.assetSpecification ?? '-'),
                    _buildInfoRow(
                      'Acquisition Date',
                      asset.acquisitionDate != null
                          ? DateFormat('dd MMM yyyy').format(asset.acquisitionDate!)
                          : '-'
                    ),
                    _buildInfoRow('Aging', asset.aging ?? '-'),
                    _buildInfoRow('Quantity', asset.quantity?.toString() ?? '1'),
                    _buildInfoRow('Department', asset.location),
                    _buildInfoRow('Control Department', asset.controlDepartment ?? '-'),
                    _buildInfoRow('Cost Center', asset.costCenter ?? '-'),
                    _buildInfoRow('Remarks', asset.remarks?.isNotEmpty == true ? asset.remarks! : '-'),
                    _buildInfoRow('Photos Count', asset.photosCount?.toString() ?? '0'),
                  ]),

                  const SizedBox(height: 16),

                  // Status Summary
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(7),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Status Summary',
                          style: TextStyle(
                            fontFamily: 'Maison Bold',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF405189),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatusCard(
                                'Available', 
                                asset.available ?? (asset.status.toLowerCase() == 'available' ? 1 : 0), 
                                Colors.green
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatusCard(
                                'Broken', 
                                asset.broken ?? (asset.status.toLowerCase() == 'broken' || asset.status.toLowerCase() == 'damaged' ? 1 : 0), 
                                Colors.orange
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatusCard(
                                'Lost', 
                                asset.lost ?? (asset.status.toLowerCase() == 'lost' ? 1 : 0), 
                                Colors.red
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Asset Photo
                  if (asset.primaryPhoto != null && asset.primaryPhoto!.fileUrl.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(7),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Asset Photo',
                            style: TextStyle(
                              fontFamily: 'Maison Bold',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF405189),
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => _showFullImage(context, asset.primaryPhoto!.fileUrl),
                            child: Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(7),
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
                          const SizedBox(height: 8),
                          Text(
                            'Tap to view full image',
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
                    const SizedBox(height: 16),
                  ] else if (asset.imagePath != null && asset.imagePath!.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(7),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Asset Photo',
                            style: TextStyle(
                              fontFamily: 'Maison Bold',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF405189),
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => _showFullImage(context, asset.imagePath!),
                            child: Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(7),
                                child: Image.network(
                                  asset.imagePath!,
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
                          const SizedBox(height: 8),
                          Text(
                            'Tap to view full image',
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
                    const SizedBox(height: 16),
                  ],

                  if (widget.showUploadPhotoButton)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        label: const Text(
                          'Upload Foto Asset',
                          style: TextStyle(
                            fontFamily: 'Maison Bold',
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF405189),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        onPressed: () => _showUploadPhotoDialog(context),
                      ),
                    ),

                  // Close Button
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF405189),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          fontFamily: 'Maison Bold',
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Maison Bold',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF405189),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
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
              style: const TextStyle(
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
      padding: const EdgeInsets.all(12),
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
          const SizedBox(height: 4),
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
      case 'available':
      case 'active':
        return Colors.green;
      case 'damaged':
      case 'broken':
      case 'inactive':
        return Colors.orange;
      case 'lost':
      case 'disposed':
        return Colors.red;
      case 'maintenance':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}