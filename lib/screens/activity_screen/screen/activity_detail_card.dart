import 'package:Simba/screens/activity_screen/service/activity_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


const Color primaryColor = Color(0xFF405189);
String parseAndFormatToWIB(String raw) {
  if (raw.isEmpty) return '-';
  try {
    DateTime dt = DateTime.parse(raw);
    final dtWib = dt.toUtc().add(const Duration(hours: 7));
    return '${dtWib.day.toString().padLeft(2, '0')}/${dtWib.month.toString().padLeft(2, '0')}/${dtWib.year} '
        '${dtWib.hour.toString().padLeft(2, '0')}:${dtWib.minute.toString().padLeft(2, '0')} WIB';
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
  String currentUser = 'User';
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
      final username = prefs.getString('username') ?? 'User';
      final fullName = prefs.getString('full_name') ?? prefs.getString('name') ?? 'User';
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

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'available':
        return const Color(0xFF059669);
      case 'broken':
        return const Color(0xFFDC2626);
      case 'lost':
        return const Color(0xFFDC2626);
      case 'maintenance':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getActivityType() {
    String activityType = widget.asset.activityType ?? 'scan_asset';
    String description = widget.asset.description ?? '';
    
    switch (activityType.toLowerCase()) {
      case 'scan_asset':
        return 'Asset Scanning';
      case 'create_asset':
        return 'Asset Creation';
      case 'update_asset':
        return 'Asset Update';
      case 'delete_asset':
        return 'Asset Deletion';
      case 'photo_upload':
        return 'Photo Upload';
      case 'photo_delete':
        return 'Photo Deletion';
      case 'status_change':
        return 'Status Change';
      default:
        if (description.toLowerCase().contains('scan')) {
          return 'Asset Scanning';
        } else if (description.toLowerCase().contains('photo')) {
          return 'Photo Management';
        } else if (description.toLowerCase().contains('update')) {
          return 'Asset Update';
        }
        return 'Asset Activity';
    }
  }

  String _getActivityDescription() {
    String description = widget.asset.description ?? '';
    String assetCode = widget.asset.assetCode;
    String activityType = _getActivityType();
    
    if (description.isNotEmpty) {
      return description;
    }
    
    switch (activityType) {
      case 'Asset Scanning':
        return 'Scan asset: $assetCode';
      case 'Asset Creation':
        return 'Created new asset: $assetCode';
      case 'Asset Update':
        return 'Updated asset information: $assetCode';
      case 'Photo Upload':
        return 'Uploaded photo for asset: $assetCode';
      case 'Photo Deletion':
        return 'Deleted photo from asset: $assetCode';
      case 'Status Change':
        return 'Changed status for asset: $assetCode';
      default:
        return 'Activity performed on asset: $assetCode';
    }
  }

  IconData _getActivityIcon() {
    String activityType = _getActivityType();
    
    switch (activityType) {
      case 'Asset Scanning':
        return Icons.qr_code_scanner;
      case 'Asset Creation':
        return Icons.add_circle_outline;
      case 'Asset Update':
        return Icons.edit_outlined;
      case 'Asset Deletion':
        return Icons.delete_outline;
      case 'Photo Upload':
        return Icons.camera_alt_outlined;
      case 'Photo Deletion':
        return Icons.photo_library_outlined;
      case 'Status Change':
        return Icons.swap_horiz;
      default:
        return Icons.inventory_outlined;
    }
  }

  Color _getActivityColor() {
    String activityType = _getActivityType();
    
    switch (activityType) {
      case 'Asset Scanning':
        return const Color(0xFF059669);
      case 'Asset Creation':
        return const Color(0xFF3B82F6);
      case 'Asset Update':
        return const Color(0xFFD97706);
      case 'Asset Deletion':
        return const Color(0xFFDC2626);
      case 'Photo Upload':
        return const Color(0xFF8B5CF6);
      case 'Photo Deletion':
        return const Color(0xFF6B7280);
      case 'Status Change':
        return const Color(0xFF0891B2);
      default:
        return const Color(0xFF405189);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFA),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle Bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Activity Details',
                    style: const TextStyle(
                      fontFamily: 'Maison Bold',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFF6B7280),
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Activity Information Card
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFFF3F4F6), width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _getActivityColor().withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  _getActivityIcon(),
                                  color: _getActivityColor(),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getActivityType(),
                                      style: const TextStyle(
                                        fontFamily: 'Maison Bold',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      getCurrentTimeFromActivity(),
                                      style: const TextStyle(
                                        fontFamily: 'Maison Book',
                                        fontSize: 12,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFF3F4F6)),
                            ),
                            child: Text(
                              _getActivityDescription(),
                              style: const TextStyle(
                                fontFamily: 'Maison Book',
                                fontSize: 13,
                                color: Color(0xFF374151),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Asset Info Card
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFFF3F4F6), width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Asset Information',
                            style: TextStyle(
                              fontFamily: 'Maison Bold',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.asset.assetName,
                                  style: const TextStyle(
                                    fontFamily: 'Maison Bold',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF000000),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF405189).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.asset.assetCode,
                              style: const TextStyle(
                                fontFamily: 'Maison Book',
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF405189),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildSimpleInfoRow('Category', widget.asset.category ?? '-'),
                          _buildSimpleInfoRow('Department', widget.asset.department ?? '-'),
                          _buildSimpleInfoRow('Status', widget.asset.assetStatus ?? '-', 
                            valueColor: _getStatusColor(widget.asset.assetStatus), isLast: true),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Status Summary
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFFF3F4F6), width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status Summary',
                            style: TextStyle(
                              fontFamily: 'Maison Bold',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildStatusCard('Available', widget.asset.available ?? 0, const Color(0xFF059669)),
                              const SizedBox(width: 12),
                              _buildStatusCard('Broken', widget.asset.broken ?? 0, const Color(0xFFDC2626)),
                              const SizedBox(width: 12),
                              _buildStatusCard('Lost', widget.asset.lost ?? 0, const Color(0xFF6B7280)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // User & Timing Details
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFFF3F4F6), width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'User & Timing',
                            style: TextStyle(
                              fontFamily: 'Maison Bold',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildSimpleInfoRow('Performed By', isLoadingUserInfo ? 'Loading...' : currentUserName),
                          _buildSimpleInfoRow('Activity Time', getCurrentTimeFromActivity()),
                          _buildSimpleInfoRow('Created At', getAssetCreatedTimeWIB()),
                          // _buildSimpleInfoRow('Updated At', getAssetUpdatedTimeWIB(), isLast: true),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleInfoRow(String label, String value, {Color? valueColor, bool isLast = false}) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Maison Book',
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontFamily: 'Maison Bold',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? const Color(0xFF111827),
                ),
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFF3F4F6), height: 1),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildStatusCard(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontFamily: 'Maison Bold',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Maison Book',
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}