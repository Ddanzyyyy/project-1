import 'package:Simba/screens/registered_page/asset_list_page.dart';
import 'package:Simba/screens/registered_page/unscanned_assets.dart';
import 'package:Simba/screens/search_page.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
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
                // SIMBA Logo
                Center(
                  child: Image.asset(
                    'assets/images/SIMBA.png',
                    width: 150,
                    height: 50,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),

                // Profile Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: const Color(0xFF405189),
                          child:
                              Icon(Icons.person, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'dummy',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: const Color(0xFF405189),
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 0),
                            Text(
                              'Citeureup',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: const Color(0xFF405189),
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SearchPage()),
                      );
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: const Color(0xFF405189),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 15),
                            child: Icon(Icons.search, color: Color(0xFF405189)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Find Place, Division, or Assets',
                              style: TextStyle(
                                fontFamily: 'Poppins',
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
                const SizedBox(height: 20),

                // Asset Cards
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListView(
                      children: [
                        AssetCard(
                          title: 'Registered Assets',
                          icon: Icons.add_box,
                          iconColor: const Color.fromARGB(255, 30, 255, 0),
                          count: '1.250',
                          description: 'Has been registered',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AssetListPage()),
                            );
                          },
                        ),
                        AssetCard(
                          title: 'Unscanned Assets',
                          icon: Icons.qr_code_2,
                          iconColor: const Color(0xFF405189),
                          count: '98',
                          description: 'Have not been scanned',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => UnscannedAssetsPage()),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        // AssetCard(
                        //   title: 'Unscanned Assets',
                        //   icon: Icons.qr_code_2,
                        //   iconColor: const Color(0xFF405189),
                        //   count: '98',
                        //   description: 'Have not been scanned',
                        // ),
                        // const SizedBox(height: 16),
                        // AssetCard(
                        //   title: 'Damaged Assets',
                        //   icon: Icons.warning_amber_rounded,
                        //   iconColor: const Color(0xFFFFD700),
                        //   count: '12',
                        //   description: 'Already damaged',
                        // ),
                        // AssetCard(
                        //   title: 'Lost Assets',
                        //   icon: Icons.location_off,
                        //   iconColor: const Color.fromARGB(255, 255, 0, 0),
                        //   count: '0',
                        //   description: 'Assets Losses',
                        // ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
            ),
            NavItem(
              icon: Icons.timeline_rounded,
              label: 'Activity',
              selected: false,
            ),
            NavItem(
              icon: Icons.qr_code_scanner_rounded,
              label: 'Scan Asset',
              selected: false,
            ),
            NavItem(
              icon: Icons.settings_rounded,
              label: 'Setting',
              selected: false,
            ),
          ],
        ),
      ),
    );
  }
}

class AssetCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final String count;
  final String description;
  final VoidCallback onTap;

  AssetCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.count,
    required this.description,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Bubble decorations
            Positioned(
              right: 10,
              top: -5,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF27519D), // biru full
                      const Color.fromARGB(255, 144, 160, 190), //
                      const Color(0x00C4C4C4), //
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: 30,
              bottom: -10,
              child: Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF27519D), // biru full
                      const Color.fromARGB(255, 144, 160, 190), //
                      const Color(0x00C4C4C4), //
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Positioned(
            //   left: 10,
            //   bottom: -5,
            //   child: Container(
            //     width: 20,
            //     height: 20,
            //     decoration: BoxDecoration(
            //       gradient: LinearGradient(
            //         begin: Alignment.topLeft,
            //         end: Alignment.bottomRight,
            //         colors: [
            //           const Color(0xFF27519D), // biru full
            //           const Color.fromARGB(255, 144, 160, 190), //
            //           const Color(0x00C4C4C4), //
            //         ],
            //       ),
            //       shape: BoxShape.circle,
            //     ),
            //   ),
            // ),
            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: iconColor, size: 22),
                    const SizedBox(width: 10),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF405189),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      count,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        'Assets',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: const Color(0xFF405189),
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const NavItem({
    required this.icon,
    required this.label,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
            fontFamily: 'Poppins',
            color: selected ? const Color(0xFF405189) : Colors.grey,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
