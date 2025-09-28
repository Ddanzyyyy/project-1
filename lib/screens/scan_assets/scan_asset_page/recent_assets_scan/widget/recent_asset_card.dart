import 'package:flutter/material.dart';
import 'package:Simba/screens/scan_assets/scan_asset_page/recent_assets_scan/model/recent_asset_model.dart';
import 'package:Simba/screens/scan_assets/scan_asset_page/recent_assets_scan/widget/recent_asset_detail_widget.dart';
import 'package:Simba/screens/home_screen/logistic_asset/service/logistic_asset_service.dart';
import 'package:intl/intl.dart';

class RecentAssetCardList extends StatefulWidget {
  final List<RecentAsset> assets;

  const RecentAssetCardList({required this.assets, Key? key}) : super(key: key);

  @override
  State<RecentAssetCardList> createState() => _RecentAssetCardListState();
}

class _RecentAssetCardListState extends State<RecentAssetCardList> {
  // Local cache for assetNo -> photoUrl
  final Map<String, String?> _photoCache = {};

  @override
  Widget build(BuildContext context) {
    final limitedAssets = widget.assets.take(5).toList();
    return Column(
      children: [
        for (final asset in limitedAssets)
          RecentAssetCard(
            asset: asset,
            photoCache: _photoCache,
          ),
      ],
    );
  }
}

class RecentAssetCard extends StatefulWidget {
  final RecentAsset asset;
  final Map<String, String?> photoCache; // In-memory cache

  const RecentAssetCard({required this.asset, required this.photoCache, Key? key}) : super(key: key);

  @override
  State<RecentAssetCard> createState() => _RecentAssetCardState();
}

class _RecentAssetCardState extends State<RecentAssetCard> {
  String? photoUrl;
  bool loadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _loadPhoto();
  }

  Future<void> _loadPhoto() async {
    // Cek cache dulu
    if (widget.photoCache.containsKey(widget.asset.assetNo)) {
      setState(() {
        photoUrl = widget.photoCache[widget.asset.assetNo];
        loadingPhoto = false;
      });
      return;
    }

    // Jika belum ada di cache, fetch dari network
    if (widget.asset.photosCount > 0) {
      setState(() {
        loadingPhoto = true;
      });
      final photos = await LogisticAssetService.getAssetPhotos(widget.asset.assetNo);
      String? url;
      if (photos.isNotEmpty) {
        final primary = photos.firstWhere(
          (p) => p.isPrimary == true,
          orElse: () => photos.first,
        );
        url = primary.fileUrl;
      }
      widget.photoCache[widget.asset.assetNo] = url;
      setState(() {
        photoUrl = url;
        loadingPhoto = false;
      });
    }
  }

  String formatUpdatedTimeWIB(DateTime? updatedAt) {
    if (updatedAt == null) return "-";
    try {
      final dt = updatedAt.toUtc().add(const Duration(hours: 7));
      return DateFormat('HH:mm').format(dt);
    } catch (e) {
      return "-";
    }
  }

  void showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.93),
      builder: (_) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Stack(
          children: [
            Center(
              child: Hero(
                tag: imageUrl,
                child: InteractiveViewer(
                  child: Image.network(imageUrl, fit: BoxFit.contain),
                ),
              ),
            ),
            Positioned(
              top: 36,
              right: 24,
              child: Icon(Icons.close, color: Colors.white, size: 32),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    switch ((widget.asset.status ?? '').toLowerCase()) {
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
              builder: (context) => RecentAssetDetailWidget(recentAsset: widget.asset),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // FOTO
              if (loadingPhoto)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.11),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF405189),
                      ),
                    ),
                  ),
                )
              else if (photoUrl != null)
                GestureDetector(
                  onTap: () => showFullImage(context, photoUrl!),
                  child: Hero(
                    tag: photoUrl!,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        photoUrl!,
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                        errorBuilder: (context, _, __) => Container(
                          width: 32,
                          height: 32,
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              else
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
                      widget.asset.assetNo,
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
                      '${widget.asset.title ?? '-'} · ${widget.asset.category ?? '-'}',
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
                                (widget.asset.status ?? 'UNKNOWN').toUpperCase(),
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
                        if (widget.asset.photosCount > 0) ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.photo, size: 11, color: Colors.blue),
                              const SizedBox(width: 2),
                              Text(
                                '${widget.asset.photosCount} Foto',
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
                              formatUpdatedTimeWIB(widget.asset.scannedAt),
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