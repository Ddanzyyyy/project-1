import 'package:flutter/material.dart';
import 'package:Simba/screens/scan_assets/scan_asset_page/recent_assets_scan/model/recent_asset_model.dart';
import 'package:Simba/screens/scan_assets/scan_asset_page/recent_assets_scan/widget/recent_asset_detail_widget.dart';
import 'package:Simba/screens/home_screen/logistic_asset/service/logistic_asset_service.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AssetImageCacheDb {
  static Database? _db;
  static const String tableName = "asset_image_cache";

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await openDatabase(
      join(await getDatabasesPath(), "asset_image_cache.db"),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            asset_no TEXT PRIMARY KEY,
            file_url TEXT
          )
        ''');
      },
    );
    return _db!;
  }

  static Future<void> cacheImage(String assetNo, String fileUrl) async {
    final database = await db;
    await database.insert(
      tableName,
      {'asset_no': assetNo, 'file_url': fileUrl},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<String?> getImage(String assetNo) async {
    final database = await db;
    final result = await database.query(
      tableName,
      where: 'asset_no = ?',
      whereArgs: [assetNo],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return result.first['file_url'] as String?;
    }
    return null;
  }

  static Future<void> removeImage(String assetNo) async {
    final database = await db;
    await database.delete(
      tableName,
      where: 'asset_no = ?',
      whereArgs: [assetNo],
    );
  }
}

class RecentAssetCard extends StatefulWidget {
  final RecentAsset asset;

  const RecentAssetCard({required this.asset, Key? key}) : super(key: key);

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

  // Fungsi refresh foto utama, update cache SQLite dan UI
  Future<void> refreshPhoto() async {
    setState(() {
      loadingPhoto = true;
    });

    await AssetImageCacheDb.removeImage(widget.asset.assetNo);

    final photos = await LogisticAssetService.getAssetPhotos(widget.asset.assetNo);
    String? url;
    if (photos.isNotEmpty) {
      final primary = photos.firstWhere(
        (p) => p.isPrimary == true,
        orElse: () => photos.first,
      );
      url = primary.fileUrl;
    }
    if (url != null) {
      await AssetImageCacheDb.cacheImage(widget.asset.assetNo, url);
    }
    if (mounted) {
      setState(() {
        photoUrl = url;
        loadingPhoto = false;
      });
    }
  }

  Future<void> _loadPhoto() async {
    String? cachedUrl = await AssetImageCacheDb.getImage(widget.asset.assetNo);
    if (cachedUrl != null) {
      if (mounted) {
        setState(() {
          photoUrl = cachedUrl;
          loadingPhoto = false;
        });
      }
      return;
    }

    if (widget.asset.photosCount > 0) {
      if (mounted) {
        setState(() {
          loadingPhoto = true;
        });
      }
      final photos = await LogisticAssetService.getAssetPhotos(widget.asset.assetNo);
      String? url;
      if (photos.isNotEmpty) {
        final primary = photos.firstWhere(
          (p) => p.isPrimary == true,
          orElse: () => photos.first,
        );
        url = primary.fileUrl;
      }
      if (url != null) {
        await AssetImageCacheDb.cacheImage(widget.asset.assetNo, url);
      }
      if (mounted) {
        setState(() {
          photoUrl = url;
          loadingPhoto = false;
        });
      }
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
      case 'active':
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

    // Image size
    const double imageSize = 44; 

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
        onTap: () async {
          final changed = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecentAssetDetailWidget(recentAsset: widget.asset),
            ),
          );
          if (changed == true) {
            await refreshPhoto();
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (loadingPhoto)
                Container(
                  width: imageSize,
                  height: imageSize,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.11),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
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
                        width: imageSize,
                        height: imageSize,
                        fit: BoxFit.cover,
                        errorBuilder: (context, _, __) => Container(
                          width: imageSize,
                          height: imageSize,
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              else
                Container(
                  width: imageSize,
                  height: imageSize,
                  decoration: BoxDecoration(
                    color: const Color(0xFF405189).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/icons/welcome_page/box_icon.png',
                      width: 28,
                      height: 28,
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