import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../service/activity_service.dart';
import 'activity_detail_card.dart';
import 'package:Simba/screens/welcome_page/welcome_page.dart';
import 'package:Simba/screens/scan_assets/scan_asset_page/recent_assets_scan/screen/scan_asset_page.dart';
import 'package:Simba/screens/setting_screen/settings_page.dart';

class AppBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const AppBottomNavBar({required this.selectedIndex, required this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(context, Icons.home_rounded, "Home", 0),
            _buildNavItem(context, Icons.timeline_rounded, "Activity", 1),
            _buildNavItem(context, Icons.qr_code_scanner_rounded, "Scan Asset", 2),
            _buildNavItem(context, Icons.settings_rounded, "Setting", 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index) {
    final selected = index == selectedIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Icon(icon, color: selected ? Color(0xFF405189) : Colors.grey, size: 28),
          const SizedBox(height: 4),
          Text(label,
            style: TextStyle(
              fontFamily: 'Maison Bold',
              color: selected ? Color(0xFF405189) : Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}


class ActivityPage extends StatefulWidget {
  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  List<ActivityLog> activities = [];
  bool isLoading = true;

  String userId = '1';
  String userName = '';
  String currentUser = 'User';
  bool isLoadingUserInfo = true;
  late ActivityService activityService;

  @override
  void initState() {
    super.initState();
    activityService = ActivityService(baseUrl: 'http://192.168.1.4:8000');
    _loadUserData();
  }

  String getCurrentWibTime() {
    final nowUtc = DateTime.now().toUtc();
    final wibTime = nowUtc.add(const Duration(hours: 7));
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(wibTime);
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final username = prefs.getString('username') ?? 'caccarehana';
      final fullName = prefs.getString('full_name') ?? prefs.getString('name') ?? 'User';
      final firstName = prefs.getString('first_name') ?? '';
      final lastName = prefs.getString('last_name') ?? '';

      String displayName = fullName;
      if (displayName == 'User' && firstName.isNotEmpty) {
        displayName = lastName.isNotEmpty ? '$firstName $lastName' : firstName;
      }

      setState(() {
        userName = displayName;
        currentUser = username;
        userId = prefs.getString('user_id') ?? '1';
        isLoadingUserInfo = false;
      });

      await fetchActivities();
    } catch (e) {
      setState(() {
        userName = 'User';
        currentUser = 'User';
        userId = '1';
        isLoadingUserInfo = false;
      });
      await fetchActivities();
    }
  }

  Future<void> fetchActivities() async {
    setState(() {
      isLoading = true;
    });
    try {
      final result = await activityService.fetchActivities(userId: userId);
      setState(() {
        activities = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildShimmerActivityCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 12,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 11,
                        width: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 12,
                    width: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerActivitiesList() {
    return ListView.builder(
      itemCount: 8,
      itemBuilder: (context, index) => _buildShimmerActivityCard(),
    );
  }

  Widget _buildShimmerHeader() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.3),
      highlightColor: Colors.white.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 16,
            width: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 12,
            width: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  void _onNavTap(int index) {
    if (index == 0) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => WelcomePage()));
    }
    if (index == 1) {
    }
    if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => ScanAssetPage()));
    }
    if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF405189),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Activity',
              style: TextStyle(
                fontFamily: 'Maison Bold',
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF405189),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isLoadingUserInfo)
                  _buildShimmerHeader()
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, ${userName.isNotEmpty ? userName : 'User'}!',
                        style: const TextStyle(
                          fontFamily: 'Maison Bold',
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        activities.isNotEmpty
                            ? 'Last activity: ${_formatWibDate(activities.first.activityTime)}'
                            : 'No activity yet',
                        style: const TextStyle(
                          fontFamily: 'Maison Book',
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Current Time: ${getCurrentWibTime()}',
                        style: const TextStyle(
                          fontFamily: 'Maison Book',
                          color: Colors.white60,
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Activities',
                        style: TextStyle(
                          fontFamily: 'Maison Bold',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF405189),
                        ),
                      ),
                      if (!isLoading && activities.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF405189).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${activities.length} activities',
                            style: const TextStyle(
                              fontFamily: 'Maison Book',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF405189),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: fetchActivities,
                      color: Color(0xFF405189),
                      child: isLoading
                          ? _buildShimmerActivitiesList()
                          : activities.isEmpty
                              ? _buildEmptyState()
                              : ListView.builder(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  itemCount: activities.length,
                                  itemBuilder: (context, idx) {
                                    final act = activities[idx];
                                    return _buildActivityCard(act);
                                  },
                                ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: 1,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timeline_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No activities found',
            style: TextStyle(
              fontFamily: 'Maison Bold',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start scanning assets to view activities',
            style: TextStyle(
              fontFamily: 'Maison Book',
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => fetchActivities(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF405189),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text(
              'Refresh',
              style: TextStyle(
                fontFamily: 'Maison Bold',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(ActivityLog activity) {
    return InkWell(
      onTap: () async {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (context) => ActivityDetailCard(asset: activity.assetDetail),
        );
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 11),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _colorForType(activity.activityType).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: _iconForType(activity.activityType),
              ),
            ),
            const SizedBox(width: 12),
            // Container(
            //   width: 40,
            //   height: 40,
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(5),
            //     color: Colors.grey[200],
            //   ),
            //   // child: ClipRRect(
            //   //   borderRadius: BorderRadius.circular(5),
            //   //   child: activity.assetDetail.imageUrl != null && activity.assetDetail.imageUrl!.isNotEmpty
            //   //       ? Image.network(
            //   //           activity.assetDetail.imageUrl!,
            //   //           fit: BoxFit.cover,
            //   //           errorBuilder: (context, error, stackTrace) {
            //   //             return Icon(
            //   //               Icons.image_not_supported,
            //   //               size: 20,
            //   //               color: Colors.grey[400],
            //   //             );
            //   //           },
            //   //           loadingBuilder: (context, child, loadingProgress) {
            //   //             if (loadingProgress == null) return child;
            //   //             return Center(
            //   //               child: SizedBox(
            //   //                 width: 16,
            //   //                 height: 16,
            //   //                 child: CircularProgressIndicator(
            //   //                   value: loadingProgress.expectedTotalBytes != null
            //   //                       ? loadingProgress.cumulativeBytesLoaded /
            //   //                           loadingProgress.expectedTotalBytes!
            //   //                       : null,
            //   //                   strokeWidth: 2,
            //   //                   color: const Color(0xFF405189),
            //   //                 ),
            //   //               ),
            //   //             );
            //   //           },
            //   //         )
            //   //       : Icon(
            //   //           Icons.image_not_supported,
            //   //           size: 20,
            //   //           color: Colors.grey[400],
            //   //         ),
            //   // ),
            // ),
            // const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          _titleForType(activity.activityType),
                          style: const TextStyle(
                            fontFamily: 'Maison Bold',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatWibDate(activity.activityTime),
                        style: TextStyle(
                          fontFamily: 'Maison Book',
                          fontSize: 10,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity.description.isNotEmpty
                        ? activity.description
                        : activity.assetCode,
                    style: TextStyle(
                      fontFamily: 'Maison Book',
                      fontSize: 11,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF405189).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      activity.assetCode,
                      style: const TextStyle(
                        fontFamily: 'Maison Bold',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF405189),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

Widget _iconForType(String type) {
  String iconPath;
  switch (type) {
    case 'scan_asset':
      iconPath = 'assets/images/icons/activity_page/scan.png';
      break;
    case 'upload_photo':
      iconPath = 'assets/images/icons/activity_page/image.png';
      break;
    case 'update_status':
      iconPath = 'assets/images/icons/activity_page/status.png';
      break;
    case 'import_assets':
      iconPath = 'assets/images/icons/BOX.png';
      break;
    case 'search_asset':
      iconPath = 'assets/images/icons/activity_page/searching.png';
      break;
    case 'view_photos':
      iconPath = 'assets/images/icons/activity_page/view.png';
      break;
    default:
      iconPath = 'assets/images/icons/activity_page/alert.png';
      break;
  }
  return Image.asset(
    iconPath,
    width: 20,
    height: 20,
    fit: BoxFit.contain,
  );
}

String _titleForType(String type) {
  switch (type) {
    case 'scan_asset':
      return 'Asset Scanned';
    case 'upload_photo':
      return 'Photo Uploaded';
    case 'update_status':
      return 'Status Updated';
    case 'import_assets':
      return 'Assets Imported';
    case 'search_asset':
      return 'Asset Searched';
    case 'view_photos':
      return 'Photos Viewed';
    default:
      return 'Other Activity';
  }
}

Color _colorForType(String type) {
  switch (type) {
    case 'scan_asset':
      return Colors.green;
    case 'upload_photo':
      return Colors.blue;
    case 'update_status':
      return Colors.orange;
    case 'import_assets':
      return const Color(0xFF405189);
    case 'search_asset':
      return Colors.grey;
    case 'view_photos':
      return Colors.purple;
    default:
      return Colors.black54;
  }
}

  String _formatWibDate(DateTime dt) {
    DateTime wib = dt.toUtc().add(const Duration(hours: 7));
    return '${wib.hour.toString().padLeft(2, '0')}:${wib.minute.toString().padLeft(2, '0')} / ${wib.day.toString().padLeft(2, '0')}-${wib.month.toString().padLeft(2, '0')}-${wib.year}';
  }
}