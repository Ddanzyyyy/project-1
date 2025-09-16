import 'package:flutter/material.dart';
import 'package:Simba/screens/scan_assets/asset.dart';
import 'package:Simba/screens/scan_assets/asset_detail_modal.dart';

class AssetCard extends StatelessWidget {
  final Asset asset;
  final String Function(DateTime?) formatUpdatedTimeWIB;
  final bool showScanTime;

  const AssetCard({
    required this.asset,
    required this.formatUpdatedTimeWIB,
    this.showScanTime = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;

    switch (asset.status.toLowerCase()) {
      case 'available':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'damaged':
      case 'broken':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      case 'lost':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'maintenance':
        statusColor = Colors.orange;
        statusIcon = Icons.build_circle;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF405189).withOpacity(0.1),
                const Color(0xFF405189).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: asset.primaryPhoto != null &&
                    asset.primaryPhoto!.fileUrl.isNotEmpty
                ? Image.network(
                    asset.primaryPhoto!.fileUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.inventory,
                        color: Color(0xFF405189),
                        size: 22,
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          strokeWidth: 2,
                          color: const Color(0xFF405189),
                        ),
                      );
                    },
                  )
                : asset.imagePath != null && asset.imagePath!.isNotEmpty
                    ? Image.network(
                        asset.imagePath!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.inventory,
                            color: Color(0xFF405189),
                            size: 22,
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                              color: const Color(0xFF405189),
                            ),
                          );
                        },
                      )
                    : const Icon(
                        Icons.inventory,
                        color: Color(0xFF405189),
                        size: 22,
                      ),
          ),
        ),
        title: Text(
          asset.name,
          style: const TextStyle(
            fontFamily: 'Maison Bold',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 3),
            Text(
              '${asset.assetCode} • ${asset.category}',
              style: TextStyle(
                fontFamily: 'Maison Book',
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 10, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        asset.status.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Maison Book',
                          fontSize: 9,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (showScanTime && asset.lastScannedAt != null) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.access_time, size: 10, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    'Scanned: ${formatUpdatedTimeWIB(asset.lastScannedAt)}',
                    style: TextStyle(
                      fontFamily: 'Maison Book',
                      fontSize: 9,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
                if (showScanTime && asset.scannedBy != null) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.person, size: 10, color: Colors.grey[500]),
                  const SizedBox(width: 2),
                  Text(
                    asset.scannedBy!,
                    style: TextStyle(
                      fontFamily: 'Maison Book',
                      fontSize: 9,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            useRootNavigator: true,
            enableDrag: true,
            builder: (context) => AssetDetailModal(asset: asset),
          );
        },
      ),
    );
  }
}