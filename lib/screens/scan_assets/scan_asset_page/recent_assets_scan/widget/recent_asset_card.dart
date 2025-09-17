import 'package:flutter/material.dart';
import 'package:Simba/screens/scan_assets/scan_asset_page/recent_assets_scan/model/recent_asset_model.dart';
import 'package:Simba/screens/scan_assets/scan_asset_page/recent_assets_scan/widget/recent_asset_detail_widget.dart';
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
      margin: const EdgeInsets.only(bottom: 10, left: 4, right: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.07),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecentAssetDetailWidget(recentAsset: asset),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF405189).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/icons/welcome_page/box_icon.png',
                    width: 22,
                    height: 22,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.assetNo,
                      style: const TextStyle(
                        fontFamily: 'Maison Bold',
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF23272E),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${asset.title ?? '-'} · ${asset.category ?? '-'}',
                      style: const TextStyle(
                        fontFamily: 'Maison Book',
                        fontSize: 10,
                        color: Color(0xFF23272E),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, size: 10, color: statusColor),
                              const SizedBox(width: 3),
                              Text(
                                (asset.status ?? 'UNKNOWN').toUpperCase(),
                                style: TextStyle(
                                  fontFamily: 'Maison Bold',
                                  fontSize: 9,
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (asset.photosCount > 0) ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.photo, size: 11, color: Colors.blue),
                              const SizedBox(width: 2),
                              Text(
                                '${asset.photosCount} Foto',
                                style: const TextStyle(
                                  fontFamily: 'Maison Bold',
                                  fontSize: 9,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ],
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.access_time, size: 10, color: Colors.grey[500]),
                            const SizedBox(width: 2),
                            Text(
                              formatUpdatedTimeWIB(asset.scannedAt),
                              style: TextStyle(
                                fontFamily: 'Maison Book',
                                fontSize: 7,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}