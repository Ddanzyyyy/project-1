import 'package:Simba/screens/activity_screen/activity_page.dart';
import 'package:Simba/screens/home_screen/lost_assets/lost_asset.dart';
import 'package:Simba/screens/home_screen/profile/edit_profile_page.dart';
import 'package:Simba/screens/home_screen/damaged_assets/damaged_asset.dart';
import 'package:Simba/screens/home_screen/unscanned_assets/unscanned_assets.dart';
import 'package:Simba/screens/home_screen/search_page.dart';
import 'package:Simba/screens/registered_page/asset_list_page.dart';
import 'package:Simba/screens/registered_page/asset_service.dart';
import 'package:Simba/screens/scan_assets/scan_asset_page.dart';
import 'package:Simba/screens/setting_screen/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    fetchAssetCount();
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
      final assets = await AssetService.getAssets();
      setState(() {
        assetCount = assets.length;
        isAssetLoading = false;
      });
    } catch (e) {
      setState(() {
        isAssetLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // HEADER & PROFILE CARD (TIDAK DIUBAH)
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

                // PROFILE CARD (TIDAK DIUBAH)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
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
                            content: Text(
                              'Error: ${e.toString()}',
                              style: TextStyle(fontFamily: 'Inter'),
                            ),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                          // Profile Picture
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

                          // Profile Info
                          Expanded(
                            child: isProfileLoading
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 120,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Container(
                                      width: 80,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currentUserName,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
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
                                        fontFamily: 'Inter',
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

                          // Arrow Icon
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

                // SEARCH BAR (DIPERBARUI AGAR MINIMALIS)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage()));
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
                                fontFamily: 'Inter',
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

                // ASSET CARDS (DIPERBARUI AGAR MINIMALIS)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListView(
                      children: [
                        AssetCardMinimalist(
                          title: 'Registered Assets',
                          icon: Icons.inventory_2_rounded,
                          count: isAssetLoading ? '...' : assetCount.toString(),
                          description: 'Has been registered',
                          color: Color(0xFF405189),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => AssetListPage()));
                          },
                        ),
                        const SizedBox(height: 10),
                        AssetCardMinimalist(
                          title: 'Unscanned Assets',
                          icon: Icons.qr_code_2_rounded,
                          count: '98',
                          description: 'Have not been scanned',
                          color: Colors.orange,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => UnscannedAssetsPage()));
                          },
                        ),
                        const SizedBox(height: 10),
                        AssetCardMinimalist(
                          title: 'Damaged Assets',
                          icon: Icons.warning_amber_rounded,
                          count: '12',
                          description: 'Already Damaged',
                          color: Colors.red,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => DamagedAsset()));
                          },
                        ),
                        const SizedBox(height: 10),
                        AssetCardMinimalist(
                          title: 'Lost Assets',
                          icon: Icons.error_outline_rounded,
                          count: '4',
                          description: 'Assets that are missing',
                          color: Colors.grey,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => LostAsset()));
                          },
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // NAVBAR (TIDAK DIUBAH)
      bottomNavigationBar: Container(
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
              selected: true,
              onTap: () {},
            ),
            NavItem(
              icon: Icons.timeline_rounded,
              label: 'Activity',
              selected: false,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ActivityPage()));
              },
            ),
            NavItem(
              icon: Icons.qr_code_scanner_rounded,
              label: 'Scan Asset',
              selected: false,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ScanAssetPage()));
              },
            ),
            NavItem(
              icon: Icons.settings_rounded,
              label: 'Setting',
              selected: false,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
              },
            ),
          ],
        ),
      ),
    );
  }
}

// AssetCardMinimalist: Card asset lebih simple dan segar
class AssetCardMinimalist extends StatelessWidget {
  final String title;
  final IconData icon;
  final String count;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const AssetCardMinimalist({
    Key? key,
    required this.title,
    required this.icon,
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
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
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
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        description,
                        style: TextStyle(
                          fontFamily: 'Inter',
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
                    fontFamily: 'Inter',
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

// NavItem (TIDAK DIUBAH)
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
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
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