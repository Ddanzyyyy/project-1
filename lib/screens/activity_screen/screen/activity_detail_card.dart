import 'package:Simba/screens/activity_screen/service/activity_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

String parseAndFormatToWIB(String raw) {
  if (raw.isEmpty) return '-';
  try {
    DateTime dt = DateTime.parse(raw);
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

  String getCurrentTimeFromActivity() {
    return parseAndFormatToWIB(widget.asset.activityTime ?? '');
  }

  String getAssetCreatedTimeWIB() {
    return parseAndFormatToWIB(widget.asset.createdAt ?? '');
  }

  String getAssetUpdatedTimeWIB() {
    return parseAndFormatToWIB(widget.asset.updatedAt ?? '');
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
                  // GestureDetector(
                  //   onTap: () => _showFullScreenImage(context),
                  //   child: _buildPlaceholderImage(),
                  // ),
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
                    icon: Icons.business_outlined,
                    label: 'Department',
                    value: widget.asset.department ?? '-',
                    iconColor: const Color(0xFF8B5CF6),
                  ),
                  const SizedBox(height: 10),
                  _buildDetailRow(
                    icon: Icons.check_circle_outline,
                    label: 'Status',
                    value: widget.asset.assetStatus ?? '-',
                    iconColor: _getStatusColor(widget.asset.assetStatus),
                  ),
                  const SizedBox(height: 10),
                  _buildDetailRow(
                    icon: Icons.inventory_outlined,
                    label: 'Quantity',
                    value: widget.asset.quantity?.toString() ?? '-',
                    iconColor: const Color(0xFF10B981),
                  ),
                  const SizedBox(height: 10),
                  _buildDetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Acquisition Date',
                    value: widget.asset.acquisitionDate ?? '-',
                    iconColor: const Color(0xFF6366F1),
                  ),
                  const SizedBox(height: 10),
                  _buildDetailRow(
                    icon: Icons.schedule_outlined,
                    label: 'Aging',
                    value: widget.asset.aging ?? '-',
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
                              'Asset Status Details',
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
                        _buildInfoRow('Available', widget.asset.available?.toString() ?? '-'),
                        _buildInfoRow('Broken', widget.asset.broken?.toString() ?? '-'),
                        _buildInfoRow('Lost', widget.asset.lost?.toString() ?? '-'),
                        _buildInfoRow('Current User', isLoadingUserInfo ? 'Loading...' : currentUserName),
                        _buildInfoRow('Activity Time', getCurrentTimeFromActivity()),
                        _buildInfoRow('Created At', getAssetCreatedTimeWIB()),
                        _buildInfoRow('Updated At', getAssetUpdatedTimeWIB()),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 40,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 6),
          Text(
            'Asset Image',
            style: TextStyle(
              fontFamily: 'Maison Book',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[500],
            ),
          ),
          Text(
            'Tap to view details',
            style: TextStyle(
              fontFamily: 'Maison Book',
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: Colors.grey[400],
            ),
          ),
        ],
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
      case 'available':
        return const Color(0xFF10B981);
      case 'broken':
        return const Color(0xFFEF4444);
      case 'lost':
        return const Color(0xFFEF4444);
      case 'maintenance':
        return const Color(0xFFF59E0B);
      default:
        return Colors.grey;
    }
  }
}