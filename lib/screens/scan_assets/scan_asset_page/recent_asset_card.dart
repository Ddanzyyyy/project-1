import 'package:flutter/material.dart';
import 'package:Simba/screens/scan_assets/scan_asset_page/recent_assets_scan/recent_asset_model.dart';
import 'package:Simba/screens/scan_assets/scan_asset_page/recent_assets_scan/recent_asset_detail_widget.dart';
import 'package:intl/intl.dart';

class RecentAssetCard extends StatelessWidget {
  final RecentAsset asset;

  const RecentAssetCard({required this.asset, Key? key}) : super(key: key);

  String formatUpdatedTimeWIB(DateTime? updatedAt) {
    if (updatedAt == null) return "-";
    try {
      final dt = updatedAt.toUtc().add(const Duration(hours: 7));
      return DateFormat('HH:mm').format(dt);
    } catch (e) {
      return "-";
    }
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;

    switch ((asset.status ?? '').toLowerCase()) {
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
        leading: Icon(Icons.inventory, color: statusColor, size: 32),
        title: Text(
          asset.assetNo,
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
            Text('${asset.title ?? '-'} · ${asset.category ?? '-'}'),
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
                    children: [
                      Icon(statusIcon, size: 10, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        (asset.status ?? 'UNKNOWN').toUpperCase(),
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
                if (asset.photosCount > 0) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.photo, size: 12, color: Colors.blue),
                  const SizedBox(width: 2),
                  Text(
                    '${asset.photosCount} Foto',
                    style: TextStyle(
                      fontFamily: 'Maison Book',
                      fontSize: 9,
                      color: Colors.blue,
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                Icon(Icons.access_time, size: 10, color: Colors.grey[500]),
                const SizedBox(width: 2),
                Text(
                  formatUpdatedTimeWIB(asset.scannedAt),
                  style: TextStyle(
                    fontFamily: 'Maison Book',
                    fontSize: 9,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecentAssetDetailWidget(recentAsset: asset),
            ),
          );
        },
      ),
    );
  }
}