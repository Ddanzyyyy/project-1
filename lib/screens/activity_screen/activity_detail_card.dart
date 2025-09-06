import 'package:Simba/screens/activity_screen/activity_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

String parseAndFormatToWIB(String raw) {
  if (raw.isEmpty) return '-';
  try {
    DateTime dt = DateTime.parse(raw); // Assume UTC
    final dtWib = dt.toUtc().add(const Duration(hours: 7));
    return '${dtWib.year}-${dtWib.month.toString().padLeft(2, '0')}-${dtWib.day.toString().padLeft(2, '0')} '
        '${dtWib.hour.toString().padLeft(2, '0')}:${dtWib.minute.toString().padLeft(2, '0')}:${dtWib.second.toString().padLeft(2, '0')}';
  } catch (e) {
    return '-';
  }
}
  

class ActivityDetailCard extends StatefulWidget {
  final AssetDetail asset;

  const ActivityDetailCard({Key? key, required this.asset}) : super(key: key);

  @override
  _ActivityDetailCardState createState() => _ActivityDetailCardState();
}

class _ActivityDetailCardState extends State<ActivityDetailCard> {
  String currentUser = 'caccarehana';
  String currentUserName = 'Loading...';
  bool isLoadingUserInfo = true;

  @override
  void initState() {
    super.initState();
    _loadUserSession();
  }

  Future<void> _loadUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username') ?? 'caccarehana';
      final fullName = prefs.getString('full_name') ?? prefs.getString('name') ?? 'Caccarehana';
      setState(() {
        currentUser = username;
        currentUserName = fullName;
        isLoadingUserInfo = false;
      });
    } catch (e) {
      setState(() {
        currentUser = 'user';
        currentUserName = 'user';
        isLoadingUserInfo = false;
      });
    }
  }

  /// Ambil waktu activity (current time dari database) dan format ke WIB
  String getCurrentTimeFromActivity() {
    return parseAndFormatToWIB(widget.asset.activityTime ?? '');
  }

  /// Ambil waktu created_at dari database dan format ke WIB
  String getAssetCreatedTimeWIB() {
    return parseAndFormatToWIB(widget.asset.createdAt ?? '');
  }

  /// Ambil waktu updated_at dari database dan format ke WIB
  String getAssetUpdatedTimeWIB() {
    return parseAndFormatToWIB(widget.asset.updatedAt ?? '');
  }

  void _showFullScreenImage(BuildContext context) {
    if (widget.asset.imageUrl == null) return;
    showDialog(
      context: context,
      builder: (context) => FullScreenImageDialog(imageUrl: widget.asset.imageUrl!),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF405189);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 3,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Activity Details',
                  style: TextStyle(
                    fontFamily: 'Maison Bold',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => _showFullScreenImage(context),
                    child: Container(
                      width: double.infinity,
                      height: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: widget.asset.imageUrl != null
                              ? Image.network(
                                  widget.asset.imageUrl!,
                                  width: double.infinity,
                                  height: 160,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildPlaceholderImage();
                                  },
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return _buildLoadingImage();
                                  },
                                )
                              : _buildPlaceholderImage(),
                          ),
                          if (widget.asset.imageUrl != null)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.fullscreen,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.asset.assetName,
                    style: const TextStyle(
                      fontFamily: 'Maison Bold',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.asset.assetCode,
                      style: TextStyle(
                        fontFamily: 'Maison Book',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Information',
                    style: TextStyle(
                      fontFamily: 'Maison Bold',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    icon: Icons.category_outlined,
                    label: 'Category',
                    value: widget.asset.category ?? '-',
                    iconColor: const Color(0xFF3B82F6),
                  ),
                  const SizedBox(height: 10),
                  _buildDetailRow(
                    icon: Icons.location_on_outlined,
                    label: 'Location',
                    value: widget.asset.location ?? '-',
                    iconColor: const Color(0xFF8B5CF6),
                  ),
                  const SizedBox(height: 10),
                  _buildDetailRow(
                    icon: Icons.check_circle_outline,
                    label: 'Status',
                    value: widget.asset.status ?? '-',
                    iconColor: _getStatusColor(widget.asset.status),
                  ),
                  const SizedBox(height: 10),
                  _buildDetailRow(
                    icon: Icons.access_time_outlined,
                    label: 'Created At',
                    value: getAssetCreatedTimeWIB(),
                    iconColor: const Color(0xFF6366F1),
                  ),
                  const SizedBox(height: 10),
                  _buildDetailRow(
                    icon: Icons.update_outlined,
                    label: 'Updated At',
                    value: getAssetUpdatedTimeWIB(),
                    iconColor: const Color(0xFFF59E0B),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(10),
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
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.info_outlined,
                                size: 14,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'System Information',
                              style: TextStyle(
                                fontFamily: 'Maison Bold',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow('Current User', isLoadingUserInfo ? 'Loading...' : currentUserName),
                        _buildInfoRow('Current Time (Activity)', getCurrentTimeFromActivity()),
                        _buildInfoRow('Created At', getAssetCreatedTimeWIB()),
                        _buildInfoRow('Updated At', getAssetUpdatedTimeWIB()),
                        _buildInfoRow('Action', 'View Asset Details'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 40,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 6),
          Text(
            'No Image Available',
            style: TextStyle(
              fontFamily: 'Maison Book',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingImage() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF405189),
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey[100]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Maison Bold',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Maison Book',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Maison Bold',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Maison Book',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
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
}

class FullScreenImageDialog extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageDialog({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black87,
            ),
          ),
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.white70,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Failed to load image',
                          style: TextStyle(
                            fontFamily: 'Maison Bold',
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 12,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Pinch to zoom • Tap to close',
                  style: TextStyle(
                    fontFamily: 'Maison Bold',
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}