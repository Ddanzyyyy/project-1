import 'package:Simba/screens/home_screen/lost_assets/compact_lost_asset_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:Simba/screens/home_screen/logistic_asset/logistic_asset_model.dart';
import 'asset_upload_dialog.dart';

class AssetInfoWidget extends StatelessWidget {
  final LogisticAsset asset;

  const AssetInfoWidget({
    Key? key,
    required this.asset,
  }) : super(key: key);

  void _showUploadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AssetUploadDialog(asset: asset),
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
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.black.withOpacity(0.05),
            //     blurRadius: 10,
            //     offset: Offset(0, 2),
            //   ),
            // ],
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

        // Basic Information Card
        _buildInfoCard('Basic Information', [
          _buildInfoRow('General Account', asset.generalAccount),
          _buildInfoRow('Subsidiary Account', asset.subsidiaryAccount),
          _buildInfoRow('Category', asset.category),
          _buildInfoRow('Sub Category', asset.subCategory),
          _buildInfoRow('Department', asset.department),
          _buildInfoRow('Control Department', asset.controlDepartment),
          _buildInfoRow('Cost Center', asset.costCenter),
        ]),

        SizedBox(height: 16),

        // Asset Details Card
        _buildInfoCard('Asset Details', [
          _buildInfoRow('Acquisition Date', asset.acquisitionDate != null 
              ? DateFormat('dd MMM yyyy').format(asset.acquisitionDate!) 
              : '-'),
          _buildInfoRow('Aging', asset.aging),
          _buildInfoRow('Total Quantity', asset.quantity.toString()),
        ]),

        SizedBox(height: 16),

        // Status Summary Card
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(7),
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.black.withOpacity(0.05),
            //     blurRadius: 10,
            //     offset: Offset(0, 2),
            //   ),
            // ],
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

        // Remarks
        if (asset.remarks.isNotEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(7),
              // boxShadow: [
              //   BoxShadow(
              //     color: Colors.black.withOpacity(0.05),
              //     blurRadius: 10,
              //     offset: Offset(0, 2),
              //   ),
              // ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Remarks',
                  style: TextStyle(
                    fontFamily: 'Maison Bold',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF405189),
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Text(
                    asset.remarks,
                    style: TextStyle(
                      fontFamily: 'Maison Book',
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

        if (asset.remarks.isNotEmpty) SizedBox(height: 16),

        // Upload Photo Action Card
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
            // boxShadow: [
            //   BoxShadow(
            //     color: primaryColor.withOpacity(0.3),
            //     blurRadius: 10,
            //     offset: Offset(0, 5),
            //   ),
            // ],
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
                  // icon: Icon(Icons.camera_alt),
                  label: Text('Upload Foto Asset'),
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
        borderRadius: BorderRadius.circular(12),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.05),
        //     blurRadius: 10,
        //     offset: Offset(0, 2),
        //   ),
        // ],
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
                color: Colors.grey[600],
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
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
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
        return Colors.green;
      case 'inactive':
        return Colors.orange;
      case 'disposed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}