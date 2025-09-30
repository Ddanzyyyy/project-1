import 'package:flutter/material.dart';
import 'package:Simba/screens/scan_assets/scan_asset_page/recent_assets_scan/model/asset.dart';
import 'package:Simba/screens/scan_assets/scan_asset_page/recent_assets_scan/screen/asset_detail_modal.dart';

class AssetCard extends StatelessWidget {
  final Asset asset;
  final String Function(DateTime?) formatUpdatedTimeWIB;
  final bool showScanTime;
  final double imageWidth;
  final double imageHeight;

  const AssetCard({
    required this.asset,
    required this.formatUpdatedTimeWIB,
    this.showScanTime = false,
    this.imageWidth = 44,
    this.imageHeight = 44,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;

    switch (asset.status.toLowerCase()) {
      case 'active':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'fully depreciation':
        statusColor = Colors.grey;
        statusIcon = Icons.info_outline;
        break;
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
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            useRootNavigator: true,
            enableDrag: true,
            builder: (context) => AssetDetailModal(asset: asset),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Gambar
              Container(
                width: imageWidth,
                height: imageHeight,
                decoration: BoxDecoration(
                  color: const Color(0xFF405189).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: asset.primaryPhoto != null &&
                          asset.primaryPhoto!.fileUrl.isNotEmpty
                      ? Image.network(
                          asset.primaryPhoto!.fileUrl,
                          fit: BoxFit.cover,
                          width: imageWidth,
                          height: imageHeight,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.inventory,
                              color: Color(0xFF405189),
                              size: 18,
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
                              width: imageWidth,
                              height: imageHeight,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.inventory,
                                  color: Color(0xFF405189),
                                  size: 18,
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
                          : Center(
                              child: Image.asset(
                                'assets/images/icons/welcome_page/box_icon.png',
                                width: 28,
                                height: 28,
                              ),
                            ),
                ),
              ),
              const SizedBox(width: 10),
              // Konten
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.name,
                      style: const TextStyle(
                        fontFamily: 'Maison Bold',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${asset.assetCode} • ${asset.category}',
                      style: const TextStyle(
                        fontFamily: 'Maison Book',
                        fontSize: 10,
                        color: Color(0xFF23272E),
                      ),
                      maxLines: 1,
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
                                asset.status.toUpperCase(),
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
                        if (showScanTime && asset.lastScannedAt != null) ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.access_time, size: 10, color: Colors.grey[500]),
                              const SizedBox(width: 2),
                              Text(
                                formatUpdatedTimeWIB(asset.lastScannedAt),
                                style: TextStyle(
                                  fontFamily: 'Maison Book',
                                  fontSize: 7,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (showScanTime && asset.scannedBy != null) ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person, size: 8, color: Colors.grey[500]),
                              const SizedBox(width: 2),
                              Text(
                                asset.scannedBy!,
                                style: TextStyle(
                                  fontFamily: 'Maison Book',
                                  fontSize: 8,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ],
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