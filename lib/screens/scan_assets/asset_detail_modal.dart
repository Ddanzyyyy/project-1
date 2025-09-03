import 'package:flutter/material.dart';
import 'asset.dart';

class AssetDetailsModal extends StatefulWidget {
  final Asset asset;
  final bool isNewScan;
  final String currentUser;
  final Function(Asset) onUpdate;
  final Function(String) onDelete;

  const AssetDetailsModal({
    Key? key,
    required this.asset,
    required this.isNewScan,
    required this.currentUser,
    required this.onUpdate,
    required this.onDelete,
  }) : super(key: key);

  @override
  _AssetDetailsModalState createState() => _AssetDetailsModalState();
}

class _AssetDetailsModalState extends State<AssetDetailsModal> {
  String getCurrentTime() {
    return '2025-09-03 04:54:19';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75, // Lebih kecil
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            width: 32,
            height: 4,
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header - Simple
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                // Status Badge
                if (widget.isNewScan)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF405189).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          size: 12,
                          color: const Color(0xFF405189),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Scanned',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF405189),
                          ),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
                // Close Button
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          // Content - Simplified
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Asset Header - Compact
                  Row(
                    children: [
                      // Asset Image - Smaller
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFF405189).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF405189).withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: widget.asset.imagePath != null && widget.asset.imagePath!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: Image.network(
                                widget.asset.imagePath!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildAssetIcon();
                                },
                              ),
                            )
                          : _buildAssetIcon(),
                      ),
                      const SizedBox(width: 12),
                      // Asset Basic Info - Compact
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.asset.name,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A1A),
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.asset.assetCode,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Status - Compact
                            Row(
                              children: [
                                _buildStatusIndicator(widget.asset.status),
                                const SizedBox(width: 6),
                                Text(
                                  _getStatusText(widget.asset.status),
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _getStatusColor(widget.asset.status),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Asset Details - Read Only
                  _buildDetailRow('Category', widget.asset.category),
                  _buildDetailRow('Location', widget.asset.location),
                  _buildDetailRow('Description', widget.asset.description),

                  const SizedBox(height: 24),

                  // Asset Information - Simplified
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outlined,
                              size: 16,
                              color: const Color(0xFF405189),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Asset Information',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey[900],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow('Asset Code', widget.asset.assetCode),
                        _buildInfoRow('Date Added', widget.asset.dateAdded),
                        _buildInfoRow('Person in Charge', widget.asset.pic),
                        _buildInfoRow('Scanned By', widget.currentUser),
                        _buildInfoRow('Scan Time', getCurrentTime()),
                        if (widget.asset.id != 0)
                          _buildInfoRow('Database ID', widget.asset.id.toString()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetIcon() {
    return Icon(
      Icons.inventory_2_outlined,
      size: 24,
      color: const Color(0xFF405189).withOpacity(0.6),
    );
  }

  Widget _buildStatusIndicator(String status) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        shape: BoxShape.circle,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'registered':
        return const Color(0xFF10B981);
      case 'damaged':
        return const Color(0xFFEF4444);
      case 'unscanned':
        return const Color(0xFFF59E0B);
      case 'lost':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'registered':
        return 'Registered';
      case 'damaged':
        return 'Damaged';
      case 'unscanned':
        return 'Unscanned';
      case 'lost':
        return 'Lost';
      default:
        return 'Unknown';
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Text(
              value.isNotEmpty ? value : '-',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}