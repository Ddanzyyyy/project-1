import 'package:Simba/screens/activity_screen/screen/activity_page.dart';
import 'package:Simba/screens/home_screen/analytic_logistic/logistic_asset_analytics_page.dart';
import 'package:Simba/screens/home_screen/logistic_asset/screen/logistic_asset_page.dart';
// import 'package:Simba/screens/home_screen/logistic_asset/logistic_asset_scan_page.dart';
import 'package:Simba/screens/home_screen/logistic_asset_scan_menu/screen/logistic_asset_scan_menu.dart';
import 'package:Simba/screens/home_screen/lost_assets/lost_asset.dart';
import 'package:Simba/screens/home_screen/profile/edit_profile_page.dart';
import 'package:Simba/screens/home_screen/damaged_assets/damaged_asset.dart';
import 'package:Simba/screens/home_screen/unscanned_assets/unscanned_assets.dart';
import 'package:Simba/screens/home_screen/search_page/search_page.dart';
// import 'package:Simba/screens/registered_page/asset_list_page.dart';
import 'package:Simba/screens/registered_page/asset_service.dart'
    as registered_asset_service;
import 'package:Simba/screens/scan_assets/scan_asset_page/recent_assets_scan/screen/scan_asset_page.dart';
import 'package:Simba/screens/setting_screen/settings_page.dart';
// import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Simba/screens/home_screen/unscanned_assets/unscanned_asset_service.dart';
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
            _buildNavItem(
                context, Icons.qr_code_scanner_rounded, "Scan Asset", 2),
            _buildNavItem(context, Icons.settings_rounded, "Setting", 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, IconData icon, String label, int index) {
    final selected = index == selectedIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Icon(icon,
              color: selected ? Color(0xFF405189) : Colors.grey, size: 28),
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
      final fetchedAssets =
          await registered_asset_service.AssetService.getAssets();
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
      final assets =
          await UnscannedAssetService.fetchUnscannedAssets(auditId: auditId);
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

  // ==== NAVIGATION HANDLER ====
  void _onNavTap(int index) {
    if (index == 0) return; // Home
    if (index == 1) {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => ActivityPage()));
    }
    if (index == 2) {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => ScanAssetPage()));
    }
    if (index == 3) {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => SettingsPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenSize.height * 0.32,
              decoration: BoxDecoration(
                color: const Color(0xFF405189),
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
                const SizedBox(height: 18),
                Center(
                  child: Image.asset(
                    'assets/images/SIMBA.png',
                    width: 150,
                    height: 50,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: isProfileLoading
                      ? Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF405189),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 120,
                                        height: 16,
                                        color: Colors.grey[300],
                                      ),
                                      SizedBox(height: 4),
                                      Container(
                                        width: 80,
                                        height: 14,
                                        color: Colors.grey[300],
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey[400],
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        )
                      : GestureDetector(
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
                              if (result != null &&
                                  result is Map<String, String>) {
                                setState(() {
                                  currentUserName =
                                      result['name'] ?? currentUserName;
                                  currentUsername =
                                      result['username'] ?? currentUsername;
                                });
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Error: ${e.toString()}',
                                    style: TextStyle(fontFamily: 'Maison Bold'),
                                  ),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  margin: EdgeInsets.all(16),
                                ),
                              );
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF405189),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        currentUserName,
                                        style: TextStyle(
                                          fontFamily: 'Maison Bold',
                                          color: const Color(0xFF405189),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '@$currentUsername',
                                        style: TextStyle(
                                          fontFamily: 'Maison Book',
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w400,
                                          fontSize: 13,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey[400],
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                // SEARCH BAR (TIDAK DIUBAH)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SearchPage()));
                    },
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 14),
                            child: Icon(Icons.search, color: Color(0xFF405189)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Find Place, Division, or Assets',
                              style: TextStyle(
                                fontFamily: 'Maison Book',
                                color: Colors.grey[500],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                // ASSET CARDS (SHIMMER LOADING on assets)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: RefreshIndicator(
                      onRefresh: _refreshPage,
                      child: isAssetLoading && isUnscannedLoading
                          ? Column(
                              children: List.generate(5, (index) {
                                return Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Container(
                                      width: double.infinity,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            )
                          : ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                 Text(
                                  "Const Asset Logistic",
                                  style: const TextStyle(
                                    fontFamily: 'Maison Bold',
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                AssetCardMinimalist(
                                  title: 'Logistic Assets',
                                  image: Image.asset(
                                    'assets/images/icons/activity_page/product.png',
                                    width: 28,
                                    height: 28,
                                  ),
                                  count: '∞',
                                  description: 'Import & scan logistics',
                                  color: Color(0xFF6B46C1),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            LogisticAssetPage(),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 10),
                               
                                AssetCardMinimalist(
                                  title: 'Scan Logistic Asset',
                                  image: Image.asset(
                                    'assets/images/icons/activity_page/research.png',
                                    width: 28,
                                    height: 28,
                                  ),
                                  count: '∞',
                                  description: 'Scan Barcode asset logistik',
                                  color: const Color(0xFF0085FF),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            LogisticAssetScanMenuPage(), 
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 10),
                                AssetCardMinimalist(
                                  title: 'Analytic Asset',
                                  image: Image.asset(
                                    'assets/images/icons/welcome_page/analytic.png',
                                    width: 28,
                                    height: 28,
                                  ),
                                  count: '∞',
                                  description: 'Scan Barcode asset logistik',
                                  color: const Color.fromRGBO(234, 0, 255, 1),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            LogisticAssetAnalyticsPage(), 
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 10),
                                Title(
                                  color: Colors.black,
                                  // title: 'Asset Summary',
                                  child: Divider(
                                    color: Colors.grey[300],
                                    thickness: 1,
                                  ),
                                ),
                                const SizedBox(height: 10), 
                                Text(
                                  "Implemented Design UIX Summary",
                                  style: const TextStyle(
                                    fontFamily: 'Maison Bold',
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 10),                             
                                // AssetCardMinimalist(
                                //   title: 'Registered Assets',
                                //   image: Image.asset(
                                //     'assets/images/icons/welcome_page/registered_asset.png',
                                //     width: 28,
                                //     height: 28,
                                //   ),
                                //   count: isAssetLoading
                                //       ? '...'
                                //       : assetCount.toString(),
                                //   description: 'Has been registered',
                                //   color: Color(0xFF2F9022),
                                //   onTap: () {
                                //     Navigator.push(
                                //         context,
                                //         MaterialPageRoute(
                                //             builder: (context) =>
                                //                 AssetListPage()));
                                //   },
                                // ),
                                // const SizedBox(height: 10),
                                AssetCardMinimalist(
                                  title: 'Unscanned Assets',
                                  image: Image.asset(
                                    'assets/images/icons/welcome_page/unscanned_asset.png',
                                    width: 28,
                                    height: 28,
                                  ),
                                  count: isUnscannedLoading
                                      ? '...'
                                      : unscannedAssetCount.toString(),
                                  description: 'Have not been scanned',
                                  color: Colors.orange,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            UnscannedAssetsPage(auditId: '1'),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 10),
                                AssetCardMinimalist(
                                  title: 'Damaged Assets',
                                  image: Image.asset(
                                    'assets/images/icons/welcome_page/damage_asset.png',
                                    width: 28,
                                    height: 28,
                                  ),
                                  count: isAssetLoading
                                      ? '...'
                                      : assets
                                          .where((a) => a.status == 'damaged')
                                          .length
                                          .toString(),
                                  description: 'Already Damaged',
                                  color: Colors.red,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DamagedAssetPage(),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 10),
                                AssetCardMinimalist(
                                  title: 'Lost Assets',
                                  image: Image.asset(
                                    'assets/images/icons/welcome_page/lost_asset.png',
                                    width: 28,
                                    height: 28,
                                  ),
                                  count: isAssetLoading
                                      ? '...'
                                      : assets
                                          .where((a) => a.status == 'lost')
                                          .length
                                          .toString(),
                                  description: 'Assets that are missing',
                                  color: Colors.grey,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LostAssetPage(),
                                      ),
                                    );
                                  },
                                ),
                              ],
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
    final Color cardBg = Colors.grey[50]!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: image ??
                      (icon != null
                          ? Icon(icon, color: color, size: 28)
                          : null),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Maison Bold',
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        description,
                        style: TextStyle(
                          fontFamily: 'Maison Book',
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  count,
                  style: TextStyle(
                    fontFamily: 'Maison Bold',
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
