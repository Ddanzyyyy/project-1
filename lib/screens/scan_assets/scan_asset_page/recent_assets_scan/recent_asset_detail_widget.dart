import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'recent_asset_model.dart';

class RecentAssetDetailWidget extends StatelessWidget {
  final RecentAsset recentAsset;

  const RecentAssetDetailWidget({Key? key, required this.recentAsset}) : super(key: key);

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
    // Modal: tidak fullscreen, 90% tinggi layar, bulat atas, tidak layar hitam
    // Jangan pakai Scaffold di modal!
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle & Header
          Padding(
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

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
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
                                recentAsset.assetNo.length > 10
                                    ? recentAsset.assetNo.substring(0, 10)
                                    : recentAsset.assetNo,
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
                                color: _getStatusColor(recentAsset.status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Text(
                                recentAsset.status ?? 'UNKNOWN',
                                style: TextStyle(
                                  fontFamily: 'Maison Bold',
                                  fontSize: 12,
                                  color: _getStatusColor(recentAsset.status),
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          recentAsset.title ?? recentAsset.assetNo,
                          style: const TextStyle(
                            fontFamily: 'Maison Bold',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          recentAsset.assetSpecification ?? '',
                          style: TextStyle(
                            fontFamily: 'Maison Book',
                            fontSize: 14,
                            color: Colors.grey[600],
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Photos info
                        if (recentAsset.photosCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              '${recentAsset.photosCount} foto tersimpan',
                              style: TextStyle(
                                fontFamily: 'Maison Bold',
                                color: Colors.blue[800],
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Full Information
                  _buildInfoCard('Full Information', [
                    _buildInfoRow('Title', recentAsset.title),
                    _buildInfoRow('Asset No', recentAsset.assetNo),
                    _buildInfoRow('General Account', recentAsset.generalAccount),
                    _buildInfoRow('Category', recentAsset.category),
                    _buildInfoRow('Sub Category', recentAsset.subCategory),
                    _buildInfoRow('Subsidiary Account', recentAsset.subsidiaryAccount),
                    _buildInfoRow('Asset Specification', recentAsset.assetSpecification),
                    _buildInfoRow(
                        'Acquisition Date',
                        recentAsset.acquisitionDate != null
                            ? DateFormat('dd MMM yyyy').format(recentAsset.acquisitionDate!)
                            : '-'),
                    _buildInfoRow('Aging', recentAsset.aging),
                    _buildInfoRow('Quantity', recentAsset.quantity?.toString()),
                    _buildInfoRow('Department', recentAsset.department),
                    _buildInfoRow('Control Department', recentAsset.controlDepartment),
                    _buildInfoRow('Cost Center', recentAsset.costCenter),
                    _buildInfoRow('Remarks', recentAsset.remarks?.isNotEmpty == true ? recentAsset.remarks! : '-'),
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
                              child: _buildStatusCard('Available', recentAsset.available ?? 0, Colors.green),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatusCard('Broken', recentAsset.broken ?? 0, Colors.orange),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatusCard('Lost', recentAsset.lost ?? 0, Colors.red),
                            ),
                          ],
                        ),
                      ],
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
                          decoration: TextDecoration.none,
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

  Widget _buildInfoRow(String label, String? value) {
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
                decoration: TextDecoration.none,
              ),
            ),
          ),
          Text(
            ': ',
            style: TextStyle(
              fontFamily: 'Maison Book',
              fontSize: 13,
              color: Colors.grey[600],
              decoration: TextDecoration.none,
            ),
          ),
          Expanded(
            child: Text(
              value?.isNotEmpty == true ? value! : '-',
              style: TextStyle(
                fontFamily: 'Maison Book',
                fontSize: 13,
                color: Colors.grey[600],
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String label, int? count, Color color) {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: (count ?? 0) == 1
                ? Icon(Icons.done, color: color, size: 24)
                : Text(
                    (count ?? 0).toString(),
                    style: TextStyle(
                      fontFamily: 'Maison Bold',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: color,
                      decoration: TextDecoration.none,
                    ),
                  ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Maison Bold',
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.none,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    String cleanStatus = status.trim().toLowerCase();
    switch (cleanStatus) {
      case 'available':
        return Colors.green;
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
      case 'fully depreciation':
      case 'fully_depreciation':
      case 'fully-depreciation':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}