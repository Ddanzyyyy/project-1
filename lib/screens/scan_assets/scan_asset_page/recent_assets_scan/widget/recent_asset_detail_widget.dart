import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/recent_asset_model.dart';

class RecentAssetDetailWidget extends StatelessWidget {
  final RecentAsset recentAsset;

  const RecentAssetDetailWidget({Key? key, required this.recentAsset}) : super(key: key);

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
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Color(0xFF405189),
        elevation: 0,
        title: Text(
          'Asset Detail',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            fontFamily: 'Maison Bold',
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(7),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
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
                          recentAsset.assetNo.length > 10 ? recentAsset.assetNo.substring(0, 10) : recentAsset.assetNo,
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
                          color: _getStatusColor(recentAsset.status ?? '').withOpacity(0.1),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          recentAsset.status ?? 'UNKNOWN',
                          style: TextStyle(
                            fontFamily: 'Maison Bold',
                            fontSize: 12,
                            color: _getStatusColor(recentAsset.status ?? ''),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    recentAsset.title ?? recentAsset.assetNo,
                    style: TextStyle(
                      fontFamily: 'Maison Bold',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    recentAsset.assetSpecification ?? '',
                    style: TextStyle(
                      fontFamily: 'Maison Book',
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  // Photos count info
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Basic Information
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
                    : '-',
              ),
              _buildInfoRow('Aging', recentAsset.aging),
              _buildInfoRow('Quantity', recentAsset.quantity?.toString() ?? '1'),
              _buildInfoRow('Department', recentAsset.department),
              _buildInfoRow('Control Department', recentAsset.controlDepartment),
              _buildInfoRow('Cost Center', recentAsset.costCenter),
              _buildInfoRow('Asset Status', recentAsset.status),
              _buildInfoRow('Remarks', recentAsset.remarks?.isNotEmpty == true ? recentAsset.remarks! : '-'),
            ]),

            SizedBox(height: 16),

            // Status Summary
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(7),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
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
                        child: _buildStatusCard('Available', recentAsset.available, Colors.green),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildStatusCard('Broken', recentAsset.broken , Colors.orange),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildStatusCard('Lost', recentAsset.lost , Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Remarks
            // You can uncomment and display remarks in a separate section if you want.
            // if (recentAsset.remarks?.isNotEmpty == true)
            //   Container(
            //     width: double.infinity,
            //     padding: EdgeInsets.all(20),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Text(
            //           'Remarks',
            //           style: TextStyle(
            //             fontFamily: 'Maison Bold',
            //             fontSize: 16,
            //             fontWeight: FontWeight.w700,
            //             color: Color(0xFF405189),
            //           ),
            //         ),
            //         SizedBox(height: 12),
            //         Container(
            //           width: double.infinity,
            //           padding: EdgeInsets.all(12),
            //           decoration: BoxDecoration(
            //             color: Colors.grey[50],
            //             borderRadius: BorderRadius.circular(7),
            //             border: Border.all(color: Colors.grey[200]!),
            //           ),
            //           child: Text(
            //             recentAsset.remarks!,
            //             style: TextStyle(
            //               fontFamily: 'Maison Book',
            //               fontSize: 14,
            //               color: Colors.grey[700],
            //               height: 1.5,
            //             ),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
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

  Widget _buildInfoRow(String label, String? value) {
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
              value?.isNotEmpty == true ? value! : '-',
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
}