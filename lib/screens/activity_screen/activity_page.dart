import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'activity_service.dart';
import 'activity_detail_card.dart';

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
    activityService = ActivityService(baseUrl: 'http://192.168.1.8:8000');
    _loadUserData();
  }

  // Get current formatted time (UTC) - Real-time function
  String getCurrentTime() {
    return '2025-09-03 14:15:27'; // Current date/time as provided
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load comprehensive user data
      final username = prefs.getString('username') ?? 'caccarehana';
      final fullName = prefs.getString('full_name') ?? prefs.getString('name') ?? 'User';
      final firstName = prefs.getString('first_name') ?? '';
      final lastName = prefs.getString('last_name') ?? '';
      
      // Build display name
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
      
      print('Activity Page - User session loaded:');
      print('   - Username: $currentUser');
      print('   - Display Name: $userName');
      print('   - User ID: $userId');
      print('   - Current Time: ${getCurrentTime()}');
      
      await fetchActivities();
    } catch (e) {
      print('Error loading user session: $e');
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
      print('Loaded ${result.length} activities successfully');
    } catch (e) {
      print('Error loading activities: $e');
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
            // Activity type icon placeholder
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
            
            // Text content placeholder
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

  // Build shimmer loading for activities list
  Widget _buildShimmerActivitiesList() {
    return ListView.builder(
      itemCount: 8,
      itemBuilder: (context, index) => _buildShimmerActivityCard(),
    );
  }

  // Build shimmer for header info
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
        title: const Text(
          'Activity',
          style: TextStyle(
            fontFamily: 'Maison Bold',
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white, size: 22),
            onPressed: () {
              fetchActivities();
              _loadUserData();
            },
            tooltip: 'Refresh Activities',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with user info
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
                // User greeting with loading state
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
                            ? 'Last activity: ${_formatDate(activities.first.activityTime)}'
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
                        'Current Time: ${getCurrentTime()}',
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

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  
                  // Section header with activity count
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
                  
                  // Activities list with shimmer loading
                  Expanded(
                    child: isLoading
                        ? _buildShimmerActivitiesList()
                        : activities.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                itemCount: activities.length,
                                itemBuilder: (context, idx) {
                                  final act = activities[idx];
                                  return _buildActivityCard(act);
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _bottomBar(context),
    );
  }

  // Enhanced empty state
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
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start scanning assets to view activities',
            style: TextStyle(
              fontFamily: 'Inter',
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
                fontFamily: 'Inter',
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
          builder: (context) => AssetDetailCard(asset: activity.assetDetail),
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
            // Activity type icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _colorForType(activity.activityType).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  _iconForType(activity.activityType),
                  color: _colorForType(activity.activityType),
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Asset image
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: activity.assetDetail.imageUrl != null && activity.assetDetail.imageUrl!.isNotEmpty
                    ? Image.network(
                        activity.assetDetail.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.image_not_supported,
                            size: 20,
                            color: Colors.grey[400],
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                                color: const Color(0xFF405189),
                              ),
                            ),
                          );
                        },
                      )
                    : Icon(
                        Icons.image_not_supported,
                        size: 20,
                        color: Colors.grey[400],
                      ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Activity info
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
                        _formatDate(activity.activityTime),
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
                  
                  // Asset code badge
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
            
            // Arrow indicator
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

  Widget _bottomBar(BuildContext context) {
    return Container(
      height: 70,
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
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          NavItem(
            icon: Icons.home_rounded,
            label: 'Home',
            selected: false,
            onTap: () {
              Navigator.pushReplacementNamed(context, '/welcome');
            },
          ),
          NavItem(
            icon: Icons.timeline_rounded,
            label: 'Activity',
            selected: true,
            onTap: () {},
          ),
          NavItem(
            icon: Icons.qr_code_scanner_rounded,
            label: 'Scan Asset',
            selected: false,
            onTap: () {
              Navigator.pushReplacementNamed(context, '/scan-assets');
            },
          ),
          NavItem(
            icon: Icons.settings_rounded,
            label: 'Setting',
            selected: false,
            onTap: () {
              Navigator.pushReplacementNamed(context, '/settings');
            },
          ),
        ],
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'scan':
        return Icons.qr_code_scanner;
      case 'register':
        return Icons.add_box;
      case 'update':
        return Icons.edit;
      case 'damage':
        return Icons.warning_amber_rounded;
      case 'lost':
        return Icons.location_off;
      case 'search':
        return Icons.search;
      case 'delete':
        return Icons.delete_forever;
      default:
        return Icons.info_outline;
    }
  }

  String _titleForType(String type) {
    switch (type) {
      case 'scan':
        return 'Asset Scanned';
      case 'register':
        return 'New Asset Registered';
      case 'update':
        return 'Asset Updated';
      case 'damage':
        return 'Damaged Asset Reported';
      case 'lost':
        return 'Lost Asset Reported';
      case 'search':
        return 'Asset Search';
      case 'delete':
        return 'Asset Deleted';
      default:
        return 'Other Activity';
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'scan':
        return Colors.green;
      case 'register':
        return const Color(0xFF405189);
      case 'update':
        return Colors.blue;
      case 'damage':
        return Colors.orange;
      case 'lost':
        return Colors.red;
      case 'search':
        return Colors.grey;
      case 'delete':
        return Colors.redAccent;
      default:
        return Colors.black54;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} / ${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }
}

class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const NavItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.selected,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Icon(
            icon,
            color: selected ? const Color(0xFF405189) : Colors.grey,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Maison Book',
              color: selected ? const Color(0xFF405189) : Colors.grey,
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