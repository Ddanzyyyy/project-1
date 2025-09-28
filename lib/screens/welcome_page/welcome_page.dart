import 'package:Simba/screens/activity_screen/screen/activity_page.dart';
import 'package:Simba/screens/home_screen/analytic_logistic/screen/logistic_asset_analytics_page.dart';
import 'package:Simba/screens/home_screen/learn_page/learn_page.dart';
import 'package:Simba/screens/home_screen/logistic_asset/screen/logistic_asset_page.dart';
import 'package:Simba/screens/home_screen/logistic_asset_scan_menu/screen/logistic_asset_scan_menu.dart';
// import 'package:Simba/screens/home_screen/lost_assets/lost_asset.dart';
import 'package:Simba/screens/home_screen/profile/edit_profile_page.dart';
// import 'package:Simba/screens/home_screen/damaged_assets/damaged_asset.dart';
// import 'package:Simba/screens/home_screen/unscanned_assets/unscanned_assets.dart';
import 'package:Simba/screens/NoImplementedHere/registered_page/asset_service.dart'
    as registered_asset_service;
import 'package:Simba/screens/scan_assets/scan_asset_page/recent_assets_scan/screen/scan_asset_page.dart';
import 'package:Simba/screens/setting_screen/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Simba/screens/NoImplementedHere/unscanned_assets/unscanned_asset_service.dart';
import 'package:shimmer/shimmer.dart';

class AppBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const AppBottomNavBar(
      {required this.selectedIndex, required this.onTap, Key? key})
      : super(key: key);

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
          Text(
            label,
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

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  String currentUserName = "Loading...";
  String currentUsername = "Loading...";
  bool isProfileLoading = true;
  int assetCount = 0;
  bool isAssetLoading = true;
  int unscannedAssetCount = 0;
  bool isUnscannedLoading = true;
  List<dynamic> assets = [];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    fetchAssetCount();
    fetchUnscannedAssetCount();
  }

  Future<void> _loadProfileData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        currentUserName = prefs.getString('name') ?? 'No Name';
        currentUsername = prefs.getString('username') ?? 'username';
        isProfileLoading = false;
      });
    } catch (e) {
      setState(() {
        currentUserName = 'Error loading';
        currentUsername = 'username';
        isProfileLoading = false;
      });
    }
  }

  void _updateUserProfile(String name, String username) {
    setState(() {
      currentUserName = name;
      currentUsername = username;
    });
  }

  Future<void> fetchAssetCount() async {
    try {
      final fetchedAssets = await registered_asset_service.AssetService.getAssets();
      setState(() {
        assets = fetchedAssets;
        assetCount = assets.length;
        isAssetLoading = false;
      });
    } catch (e) {
      setState(() {
        isAssetLoading = false;
      });
    }
  }

  Future<void> fetchUnscannedAssetCount() async {
    try {
      final auditId = '1';
      final assets = await UnscannedAssetService.fetchUnscannedAssets(auditId: auditId);
      setState(() {
        unscannedAssetCount = assets.length;
        isUnscannedLoading = false;
      });
    } catch (e) {
      setState(() {
        isUnscannedLoading = false;
      });
    }
  }

  Future<void> _refreshPage() async {
    setState(() {
      isProfileLoading = true;
      isAssetLoading = true;
      isUnscannedLoading = true;
    });

    await Future.wait([
      _loadProfileData(),
      fetchAssetCount(),
      fetchUnscannedAssetCount(),
    ]);
  }

  void _onNavTap(int index) {
    if (index == 0) return; // Home
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => ActivityPage()));
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
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // Background header (solid color, no gradient)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenSize.height * 0.35,
              decoration: const BoxDecoration(
                color: Color(0xFF405189),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset(
                            'assets/images/SIMAP.png',
                            width: 120,
                            height: 40,
                            fit: BoxFit.contain,
                          ),
                          // Indocement logo (no box)
                          Image.asset(
                            'assets/images/indocement_logo.png',
                            width: 40,
                            height: 40,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Profile Card
                      _buildProfileCard(),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),

                // Content Section
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: RefreshIndicator(
                        onRefresh: _refreshPage,
                        child: isAssetLoading && isUnscannedLoading
                            ? _buildShimmerLoading()
                            : ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  // Welcome message
                                  _buildWelcomeMessage(),
                                  const SizedBox(height: 24),
                                  
                                  // // Quick Actions (only Scan Asset now)
                                  // _buildQuickActions(),
                                  // const SizedBox(height: 2),
                                  
                                  // Core Logistic Assets (with Analytics added)
                                  _buildSectionHeader("Core Asset Logistic", "Manage your logistics Assets"),
                                  const SizedBox(height: 16),
                                  _buildLogisticAssetsGrid(),
                                  
                                  const SizedBox(height: 28),
                                  
                                  // // Asset Summary
                                  // _buildSectionHeader("Asset Summary", "Track and monitor asset status"),
                                  // const SizedBox(height: 16),
                                  // _buildAssetSummaryGrid(),
                                  
                                  // const SizedBox(height: 120), // Bottom spacing
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: 0,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildProfileCard() {
    if (isProfileLoading) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 120, height: 16, color: Colors.grey),
                    const SizedBox(height: 4),
                    Container(width: 80, height: 14, color: Colors.grey),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () async {
        try {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditProfilePage(
                initialName: currentUserName,
                initialUsername: currentUsername,
                onProfileUpdated: _updateUserProfile,
              ),
            ),
          );
          if (result != null && result is Map<String, String>) {
            setState(() {
              currentUserName = result['name'] ?? currentUserName;
              currentUsername = result['username'] ?? currentUsername;
            });
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF405189),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF405189).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentUserName,
                    style: const TextStyle(
                      fontFamily: 'Maison Bold',
                      color: Color(0xFF1A1A1A),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '@$currentUsername',
                    style: TextStyle(
                      fontFamily: 'Maison Book',
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF405189).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF405189).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.waving_hand,
            color: const Color(0xFF405189),
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, ${currentUserName.split(' ').first}!',
                  style: const TextStyle(
                    fontFamily: 'Maison Bold',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF405189),
                  ),
                ),
                // const SizedBox(height: 2),
                Text(
                  'Ready to manage your assets today?',
                  style: TextStyle(
                    fontFamily: 'Maison Book',
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildQuickActions() {
  //   return _buildQuickActionCard(
  //     'Scan Asset',
  //     Icons.qr_code_scanner,
  //     const Color(0xFF10B981),
  //     () => Navigator.push(context, MaterialPageRoute(builder: (_) => ScanAssetPage())),
  //   );
  // }

  // Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Container(
  //       width: double.infinity,
  //       padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
  //       decoration: BoxDecoration(
  //         color: color.withOpacity(0.1),
  //         borderRadius: BorderRadius.circular(12),
  //         border: Border.all(color: color.withOpacity(0.2)),
  //       ),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Icon(icon, color: color, size: 24),
  //           const SizedBox(width: 12),
  //           Text(
  //             title,
  //             style: TextStyle(
  //               fontFamily: 'Maison Bold',
  //               fontSize: 16,
  //               fontWeight: FontWeight.w600,
  //               color: color,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Maison Bold',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontFamily: 'Maison Book',
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildLogisticAssetsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AssetCardMinimalist(
                title: 'Logistic Assets',
                image: Image.asset('assets/images/icons/activity_page/product.png', width: 28, height: 28),
                count: '∞',
                description: 'Import & manage',
                color: const Color(0xFF6B46C1),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LogisticAssetPage())),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AssetCardMinimalist(
                title: 'Scan Assets',
                image: Image.asset('assets/images/icons/activity_page/research.png', width: 28, height: 28),
                count: '∞',
                description: 'Scan barcodes',
                color: const Color(0xFF0085FF),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LogisticAssetScanMenuPage())),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Analytics moved here and full width
        AssetCardMinimalist(
          title: 'Analytics Asset',
          image: Image.asset('assets/images/icons/welcome_page/analytic.png', width: 28, height: 28),
          count: '∞',
          description: 'Asset analytics & reports',
          color: const Color(0xFF8B5CF6),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LogisticAssetAnalyticsPage())),
        ),
        const SizedBox(height: 12),
        AssetCardMinimalist(
          title: 'How To Use This App',
          image: Image.asset('assets/images/icons/welcome_page/learn.png', width: 28, height: 28),
          count: '∞',
          description: 'Learn how to use SIMAP',
          color: const Color.fromARGB(255, 100, 246, 92),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LearnPage())),
        ),
        const SizedBox(height: 12),
        
        // Search Assets (goes to LogisticAssetPage with search focus)
        // AssetCardMinimalist(
        //   title: 'Search Assets',
        //   image: Icon(Icons.search, color: const Color(0xFF3B82F6), size: 28),
        //   count: '∞',
        //   description: 'Find assets quickly',
        //   color: const Color(0xFF3B82F6),
        //   onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LogisticAssetPage())),
        // ),
      ],
    );
  }

  // Widget _buildAssetSummaryGrid() {
  //   return Column(
  //     children: [
  //       AssetCardMinimalist(
  //         title: 'Unscanned Assets',
  //         image: Image.asset('assets/images/icons/welcome_page/unscanned_asset.png', width: 28, height: 28),
  //         count: isUnscannedLoading ? '...' : unscannedAssetCount.toString(),
  //         description: 'Pending scans',
  //         color: const Color(0xFFF59E0B),
  //         onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UnscannedAssetsPage(auditId: '1'))),
  //       ),
  //       const SizedBox(height: 12),
  //       Row(
  //         children: [
  //           Expanded(
  //             child: AssetCardMinimalist(
  //               title: 'Damaged',
  //               image: Image.asset('assets/images/icons/welcome_page/damage_asset.png', width: 28, height: 28),
  //               count: isAssetLoading ? '...' : assets.where((a) => a.status == 'damaged').length.toString(),
  //               description: 'Need repair',
  //               color: const Color(0xFFEF4444),
  //               onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DamagedAssetPage())),
  //             ),
  //           ),
  //           const SizedBox(width: 12),
  //           Expanded(
  //             child: AssetCardMinimalist(
  //               title: 'Lost Assets',
  //               image: Image.asset('assets/images/icons/welcome_page/lost_asset.png', width: 28, height: 28),
  //               count: isAssetLoading ? '...' : assets.where((a) => a.status == 'lost').length.toString(),
  //               description: 'Missing items',
  //               color: const Color(0xFF6B7280),
  //               onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LostAssetPage())),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  Widget _buildShimmerLoading() {
    return Column(
      children: List.generate(4, (index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }),
    );
  }
}

class AssetCardMinimalist extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget? image;
  final String count;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const AssetCardMinimalist({
    Key? key,
    required this.title,
    this.icon,
    this.image,
    required this.count,
    required this.description,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: image ?? (icon != null ? Icon(icon, color: color, size: 20) : null),
                  ),
                  const Spacer(),
                  Text(
                    count,
                    style: TextStyle(
                      fontFamily: 'Maison Bold',
                      fontWeight: FontWeight.w700,
                      color: color,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Maison Bold',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontFamily: 'Maison Book',
                  color: Colors.grey[600],
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}