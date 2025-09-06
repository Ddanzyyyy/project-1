import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  String? scanTime;
  Asset? updatedAsset;

  @override
  void initState() {
    super.initState();
    updatedAsset = widget.asset;
    _initializeScanTime();
  }

  void _initializeScanTime() {
    if (widget.isNewScan) {
      scanTime = _formatCurrentTime();

      final now = DateTime.now();
      updatedAsset = widget.asset.copyWith(
        lastScannedAt: now,
        status: 'registered',
      );

      widget.onUpdate(updatedAsset!);
    } else {
      scanTime = _getScanTimeFromDatabase();
    }
  }

  String _formatCurrentTime() {
    final now = DateTime.now();
    return DateFormat('dd MMM yyyy HH:mm').format(now) + ' WIB';
  }

  String? _getScanTimeFromDatabase() {
    if (updatedAsset?.lastScannedAt != null) {
      final scanDateTime = updatedAsset!.lastScannedAt!;
      return DateFormat('dd MMM yyyy HH:mm').format(scanDateTime) + ' WIB';
    }
    return null;
  }

  String _getDisplayScanTime() {
    if (widget.isNewScan) {
      return scanTime ?? _formatCurrentTime();
    } else {
      return scanTime ?? '-';
    }
  }

  String _getScannedByText() {
    if (widget.isNewScan) {
      return widget.currentUser;
    } else {
      if (widget.asset.lastScannedAt != null) {
        return widget.currentUser;
      } else {
        return '-';
      }
    }
  }

  // Tambahan: Format dateAdded agar tampil dengan WIB dan tanpa "T00:00:00.000000Z"
  String _getFormattedDateAdded(String dateAdded) {
    try {
      // Coba parse ISO string
      DateTime dt = DateTime.parse(dateAdded);
      return DateFormat('dd MMM yyyy').format(dt) + ' WIB';
    } catch (_) {
      // Jika bukan ISO, tampilkan apa adanya
      return dateAdded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayAsset = updatedAsset ?? widget.asset;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
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
                            fontFamily: 'Maison Book',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF405189),
                          ),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
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

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
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
                        child: displayAsset.imagePath != null &&
                                displayAsset.imagePath!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(11),
                                child: Image.network(
                                  displayAsset.imagePath!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildAssetIcon();
                                  },
                                ),
                              )
                            : _buildAssetIcon(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayAsset.name,
                              style: const TextStyle(
                                fontFamily: 'Maison Bold',
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                displayAsset.assetCode,
                                style: TextStyle(
                                  fontFamily: 'Maison Book',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                _buildStatusIndicator(displayAsset.status),
                                const SizedBox(width: 6),
                                Text(
                                  _getStatusText(displayAsset.status),
                                  style: TextStyle(
                                    fontFamily: 'Maison Book',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _getStatusColor(displayAsset.status),
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

                  _buildDetailRow('Category', displayAsset.category),
                  _buildDetailRow('Location', displayAsset.location),
                  _buildDetailRow('Description', displayAsset.description),

                  const SizedBox(height: 24),

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
                                fontFamily: 'Maison Bold',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey[900],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow('Asset Code', displayAsset.assetCode),
                        // Ubah di sini agar format dateAdded rapi dan WIB
                        _buildInfoRow(
                          'Date Added',
                          _getFormattedDateAdded(displayAsset.dateAdded),
                        ),
                        _buildInfoRow('Person in Charge', displayAsset.pic),
                        _buildInfoRow('Scanned By', _getScannedByText()),
                        _buildInfoRow('Scan Time', _getDisplayScanTime()),
                        if (displayAsset.id != 0)
                          _buildInfoRow('Database ID', displayAsset.id.toString()),
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
              fontFamily: 'Maison Bold',
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
                fontFamily: 'Maison Book',
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
                fontFamily: 'Maison Bold',
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
                fontFamily: 'Maison Book',
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