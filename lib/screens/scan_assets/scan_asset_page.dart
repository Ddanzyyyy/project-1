import 'package:Simba/screens/activity_screen/activity_page.dart';
import 'package:Simba/screens/scan_assets/qr_scanner_page.dart';
import 'package:Simba/screens/setting_screen/settings_page.dart';
import 'package:Simba/screens/welcome_page.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'qr_scanner_page.dart';

class Asset {
  final String id;
  final String name;
  final String category;
  final String location;
  final String status;
  final String qrCode;
  final DateTime scannedDate;
  final String scannedBy;

  Asset({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.status,
    required this.qrCode,
    required this.scannedDate,
    required this.scannedBy,
  });

  Asset copyWith({
    String? id,
    String? name,
    String? category,
    String? location,
    String? status,
    String? qrCode,
    DateTime? scannedDate,
    String? scannedBy,
  }) {
    return Asset(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      location: location ?? this.location,
      status: status ?? this.status,
      qrCode: qrCode ?? this.qrCode,
      scannedDate: scannedDate ?? this.scannedDate,
      scannedBy: scannedBy ?? this.scannedBy,
    );
  }

  static fromJson(e) {}
}

class ScanAssetPage extends StatefulWidget {
  @override
  _ScanAssetPageState createState() => _ScanAssetPageState();
}

class _ScanAssetPageState extends State<ScanAssetPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _qrController = TextEditingController();

  //Dummy Dataset
  List<Asset> assets = [
    Asset(
      id: 'IT-001',
      name: 'Laptop Dell Inspiron 15',
      category: 'IT Equipment',
      location: 'Citeureup - IT Department',
      status: 'Good',
      qrCode: 'QR001IT',
      scannedDate: DateTime.parse('2025-08-20 04:02:21'),
      scannedBy: 'caccarehana',
    ),
    Asset(
      id: 'FN-045',
      name: 'Office Chair Ergonomic',
      category: 'Furniture',
      location: 'Citeureup - Finance',
      status: 'Good',
      qrCode: 'QR045FN',
      scannedDate: DateTime.parse('2025-08-20 04:00:15'),
      scannedBy: 'caccarehana',
    ),
    Asset(
      id: 'IT-023',
      name: 'Printer Canon LBP6030',
      category: 'IT Equipment',
      location: 'Citeureup - IT Department',
      status: 'Damaged',
      qrCode: 'QR023IT',
      scannedDate: DateTime.parse('2025-08-20 03:58:45'),
      scannedBy: 'caccarehana',
    ),
  ];

  List<Asset> filteredAssets = [];
  String selectedTab = 'Scan';

  @override
  void initState() {
    super.initState();
    filteredAssets = assets;
  }

  void _filterAssets(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredAssets = assets;
      } else {
        filteredAssets = assets
            .where((asset) =>
                asset.name.toLowerCase().contains(query.toLowerCase()) ||
                asset.id.toLowerCase().contains(query.toLowerCase()) ||
                asset.category.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  // Open QR Scanner - Crash-proof implementation
  Future<void> _openQRScanner() async {
    try {
      await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              QRScannerPage(
            onQRScanned: (qrCode) {
              _processScannedQr(qrCode);
            },
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(
                Tween(begin: const Offset(0.0, 1.0), end: Offset.zero),
              ),
              child: child,
            );
          },
        ),
      );
    } catch (e) {
      _showErrorSnackBar(
          'Scanner temporarily unavailable. Please use manual input.');
      print('Scanner error: $e');
    }
  }

  void _simulateScan() {
    if (_qrController.text.isEmpty) {
      _showErrorSnackBar('Please enter QR code to scan');
      return;
    }
    _processScannedQr(_qrController.text);
  }

  void _processScannedQr(String qrCode) {
    setState(() {
      _qrController.text = qrCode;
    });

    Asset foundAsset = assets.firstWhere(
      (asset) => asset.qrCode == qrCode,
      orElse: () => Asset(
        id: 'NEW-${DateTime.now().millisecondsSinceEpoch}',
        name: 'Unknown Asset',
        category: 'Unidentified',
        location: 'Unknown',
        status: 'Needs Verification',
        qrCode: qrCode,
        scannedDate: DateTime.parse('2025-08-20 04:02:21'), // Current time
        scannedBy: 'caccarehana', // Current user
      ),
    );

    _showAssetDetails(foundAsset, isNewScan: true);
  }

  void _showAssetDetails(Asset asset, {bool isNewScan = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AssetDetailsModal(
        asset: asset,
        isNewScan: isNewScan,
        onUpdate: (updatedAsset) {
          setState(() {
            final index = assets.indexWhere((a) => a.id == updatedAsset.id);
            if (index != -1) {
              assets[index] = updatedAsset;
            } else {
              assets.insert(0, updatedAsset);
            }
            _filterAssets(_searchController.text);
          });
        },
        onDelete: (assetId) {
          setState(() {
            assets.removeWhere((a) => a.id == assetId);
            _filterAssets(_searchController.text);
          });
        },
      ),
    );
  }

  void _showAddAssetForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddAssetModal(
        onAdd: (newAsset) {
          setState(() {
            assets.insert(0, newAsset);
            _filterAssets(_searchController.text);
          });
        },
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
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
          'Scan Assets',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Header with tabs - Fixed height
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
                20, 20, 20, 15), // Reduced bottom padding
            decoration: const BoxDecoration(
              color: Color(0xFF405189),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                // Tab buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildTabButton('Scan', Icons.qr_code_scanner),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTabButton('Assets', Icons.inventory),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTabButton('Add', Icons.add_circle),
                    ),
                  ],
                ),
                const SizedBox(height: 15), // Reduced spacing

                // Current user info with updated time - Compact layout
                Column(
                  children: [
                    Text(
                      'Logged in as: caccarehana', // Current user
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white70,
                        fontSize: 11, // Smaller font
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2), // Reduced spacing
                    Text(
                      'Current Time: 2025-08-20 04:02:21', // Current time
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white70,
                        fontSize: 10, // Smaller font
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                  20, 15, 20, 0), // Reduced top padding
              child: _buildTabContent(),
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
              selected: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WelcomePage()),
                );
              },
            ),
            NavItem(
              icon: Icons.timeline_rounded,
              label: 'Activity',
              selected: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ActivityPage()),
                );
              },
            ),
            NavItem(
              icon: Icons.qr_code_scanner_rounded,
              label: 'Scan Asset',
              selected: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ScanAssetPage()),
                );
              },
            ),
            NavItem(
              icon: Icons.settings_rounded,
              label: 'Setting',
              selected: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, IconData icon) {
    final bool isSelected = selectedTab == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: 10, horizontal: 14), // Reduced padding
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.white54,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF405189) : Colors.white,
              size: 16, // Reduced icon size
            ),
            const SizedBox(width: 6), // Reduced spacing
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: isSelected ? const Color(0xFF405189) : Colors.white,
                fontSize: 11, // Reduced font size
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (selectedTab) {
      case 'Scan':
        return _buildScanContent();
      case 'Assets':
        return _buildAssetsContent();
      case 'Add':
        return _buildAddContent();
      default:
        return _buildScanContent();
    }
  }

  Widget _buildScanContent() {
    return SingleChildScrollView(
      // Added scroll view to handle overflow
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Scan Asset QR Code',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF405189),
            ),
          ),
          const SizedBox(height: 12), // Reduced spacing

          // Camera Scanner Button - Reduced height
          Container(
            width: double.infinity,
            height: 170, // Reduced from 200 to 170
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  const Color(0xFF405189).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF405189), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: _openQRScanner,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 70, // Reduced size
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF405189),
                            const Color(0xFF405189).withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(35),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF405189).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner,
                        color: Colors.white,
                        size: 35, // Reduced icon size
                      ),
                    ),
                    const SizedBox(height: 12), // Reduced spacing
                    const Text(
                      'Tap to Open Camera Scanner',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15, // Reduced font size
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF405189),
                      ),
                    ),
                    const SizedBox(height: 6), // Reduced spacing
                    Text(
                      'Secure native QR code scanner',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11, // Reduced font size
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8), // Reduced spacing
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3), // Reduced padding
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Crash-Proof Scanner',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 9, // Reduced font size
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16), // Reduced spacing

          // Manual QR input
          Text(
            'Or enter QR code manually:',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13, // Reduced font size
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10), // Reduced spacing

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _qrController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.qr_code,
                    color: Color(0xFF405189), size: 20), // Reduced icon size
                hintText: 'QR001IT, QR045FN, QR023IT',
                hintStyle: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.grey[500],
                  fontSize: 13, // Reduced font size
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(14), // Reduced padding
                suffixIcon: _qrController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _qrController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.clear,
                            color: Colors.grey, size: 18), // Reduced icon size
                      )
                    : null,
              ),
              style: const TextStyle(fontSize: 14), // Reduced font size
              onChanged: (value) => setState(() {}),
            ),
          ),
          const SizedBox(height: 12), // Reduced spacing

          // Manual scan button - Reduced height
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _qrController.text.isNotEmpty ? _simulateScan : null,
              icon: const Icon(Icons.search,
                  color: Colors.white, size: 18), // Reduced icon size
              label: const Text(
                'Search Asset',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontSize: 15, // Reduced font size
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _qrController.text.isNotEmpty
                    ? const Color(0xFF405189)
                    : Colors.grey[400],
                padding:
                    const EdgeInsets.symmetric(vertical: 14), // Reduced padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20), // Reduced spacing

          // Recent scans
          Text(
            'Recent Scans',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15, // Reduced font size
              fontWeight: FontWeight.w600,
              color: const Color(0xFF405189),
            ),
          ),
          const SizedBox(height: 10), // Reduced spacing

          // Recent scans list - Limited height to prevent overflow
          SizedBox(
            height: 200, // Fixed height for recent scans
            child: ListView.builder(
              itemCount: assets.take(3).length,
              itemBuilder: (context, index) {
                final asset = assets[index];
                return _buildAssetCard(asset, showScanTime: true);
              },
            ),
          ),
          const SizedBox(height: 20), // Bottom spacing for scroll
        ],
      ),
    );
  }

  Widget _buildAssetsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar
        Container(
          height: 50, // Fixed height
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _filterAssets,
            decoration: InputDecoration(
              prefixIcon:
                  const Icon(Icons.search, color: Color(0xFF405189), size: 20),
              hintText: 'Search assets...',
              hintStyle: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.grey[500],
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
        const SizedBox(height: 15), // Reduced spacing

        // Assets count
        Text(
          'Assets (${filteredAssets.length})',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15, // Reduced font size
            fontWeight: FontWeight.w600,
            color: const Color(0xFF405189),
          ),
        ),
        const SizedBox(height: 10), // Reduced spacing

        // Assets list
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero, // Remove default padding
            itemCount: filteredAssets.length,
            itemBuilder: (context, index) {
              final asset = filteredAssets[index];
              return _buildAssetCard(asset);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddContent() {
    return SingleChildScrollView(
      // Added scroll view
      child: Container(
        height: MediaQuery.of(context).size.height * 0.5, // Fixed height
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, // Reduced size
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF405189).withOpacity(0.1),
                    const Color(0xFF405189).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.add_circle_outline,
                size: 40, // Reduced icon size
                color: Color(0xFF405189),
              ),
            ),
            const SizedBox(height: 16), // Reduced spacing
            Text(
              'Add New Asset',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18, // Reduced font size
                fontWeight: FontWeight.w600,
                color: const Color(0xFF405189),
              ),
            ),
            const SizedBox(height: 10), // Reduced spacing
            Text(
              'Register a new asset to the system',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13, // Reduced font size
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24), // Reduced spacing
            SizedBox(
              width: 180, // Reduced width
              child: ElevatedButton.icon(
                onPressed: _showAddAssetForm,
                icon: const Icon(Icons.add,
                    color: Colors.white, size: 18), // Reduced icon size
                label: const Text(
                  'Add Asset',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    fontSize: 15, // Reduced font size
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF405189),
                  padding: const EdgeInsets.symmetric(
                      vertical: 14), // Reduced padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetCard(Asset asset, {bool showScanTime = false}) {
    Color statusColor;
    switch (asset.status.toLowerCase()) {
      case 'good':
        statusColor = Colors.green;
        break;
      case 'damaged':
        statusColor = Colors.red;
        break;
      case 'needs verification':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10), // Reduced margin
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14), // Reduced padding
        leading: Container(
          width: 45, // Reduced size
          height: 45,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF405189).withOpacity(0.1),
                const Color(0xFF405189).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.inventory,
            color: Color(0xFF405189),
            size: 22, // Reduced icon size
          ),
        ),
        title: Text(
          asset.name,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13, // Reduced font size
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 3), // Reduced spacing
            Text(
              '${asset.id} • ${asset.category}',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11, // Reduced font size
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 1), // Reduced padding
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    asset.status,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 9, // Reduced font size
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (showScanTime) ...[
                  const SizedBox(width: 6), // Reduced spacing
                  Text(
                    'Scanned: ${asset.scannedDate.toString().substring(11, 16)}',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 9, // Reduced font size
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey,
          size: 14, // Reduced icon size
        ),
        onTap: () => _showAssetDetails(asset),
      ),
    );
  }
}

// NavItem class dengan reduced size
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
          const SizedBox(height: 6), // Reduced spacing
          Icon(
            icon,
            color: selected ? const Color(0xFF405189) : Colors.grey,
            size: 24, // Reduced icon size
          ),
          const SizedBox(height: 3), // Reduced spacing
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              color: selected ? const Color(0xFF405189) : Colors.grey,
              fontSize: 9, // Reduced font size
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6), // Reduced spacing
        ],
      ),
    );
  }
}

// Asset Details Modal dengan updated timestamp
class AssetDetailsModal extends StatefulWidget {
  final Asset asset;
  final bool isNewScan;
  final Function(Asset) onUpdate;
  final Function(String) onDelete;

  const AssetDetailsModal({
    Key? key,
    required this.asset,
    required this.isNewScan,
    required this.onUpdate,
    required this.onDelete,
  }) : super(key: key);

  @override
  _AssetDetailsModalState createState() => _AssetDetailsModalState();
}

class _AssetDetailsModalState extends State<AssetDetailsModal> {
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _locationController;
  late String _selectedStatus;
  bool _isEditing = false;

  final List<String> _statusOptions = [
    'Good',
    'Damaged',
    'Needs Verification',
    'Lost'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.asset.name);
    _categoryController = TextEditingController(text: widget.asset.category);
    _locationController = TextEditingController(text: widget.asset.location);
    _selectedStatus = widget.asset.status;
    _isEditing = widget.isNewScan;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Asset name cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final updatedAsset = widget.asset.copyWith(
      name: _nameController.text,
      category: _categoryController.text,
      location: _locationController.text,
      status: _selectedStatus,
      scannedDate: DateTime.parse('2025-08-20 04:02:21'), // Current time
      scannedBy: 'caccarehana', // Current user
    );

    widget.onUpdate(updatedAsset);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.isNewScan
            ? 'Asset scanned successfully!'
            : 'Asset updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deleteAsset() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Asset'),
        content: const Text('Are you sure you want to delete this asset?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.onDelete(widget.asset.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close modal
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Asset deleted successfully!'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF405189),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isNewScan ? 'Scanned Asset' : 'Asset Details',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        widget.asset.id,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = !_isEditing;
                        });
                      },
                      icon: Icon(
                        _isEditing ? Icons.close : Icons.edit,
                        color: Colors.white,
                      ),
                    ),
                    if (!widget.isNewScan)
                      IconButton(
                        onPressed: _deleteAsset,
                        icon: const Icon(Icons.delete, color: Colors.white),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailField('Asset Name', _nameController,
                      enabled: _isEditing),
                  const SizedBox(height: 16),
                  _buildDetailField('Category', _categoryController,
                      enabled: _isEditing),
                  const SizedBox(height: 16),
                  _buildDetailField('Location', _locationController,
                      enabled: _isEditing),
                  const SizedBox(height: 16),

                  // Status dropdown
                  Text(
                    'Status',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedStatus,
                        isExpanded: true,
                        onChanged: _isEditing
                            ? (value) {
                                setState(() {
                                  _selectedStatus = value!;
                                });
                              }
                            : null,
                        items: _statusOptions.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(
                              status,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                color: Color(0xFF405189),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Metadata
                  _buildMetadataCard(),

                  if (_isEditing) ...[
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF405189),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          widget.isNewScan
                              ? 'Save Scanned Asset'
                              : 'Save Changes',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailField(String label, TextEditingController controller,
      {bool enabled = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            color: Color(0xFF405189),
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF405189)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            contentPadding: const EdgeInsets.all(16),
            filled: !enabled,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Scan Information',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          _buildMetadataRow('QR Code:', widget.asset.qrCode),
          _buildMetadataRow(
              'Scanned Date:', '2025-08-20 04:02:21'), // Current time
          _buildMetadataRow('Scanned By:', 'caccarehana'), // Current user
        ],
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: Color(0xFF405189),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Add Asset Modal dengan updated timestamp
class AddAssetModal extends StatefulWidget {
  final Function(Asset) onAdd;

  const AddAssetModal({Key? key, required this.onAdd}) : super(key: key);

  @override
  _AddAssetModalState createState() => _AddAssetModalState();
}

class _AddAssetModalState extends State<AddAssetModal> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _qrCodeController = TextEditingController();
  String _selectedStatus = 'Good';

  final List<String> _statusOptions = ['Good', 'Damaged', 'Needs Verification'];

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _locationController.dispose();
    _qrCodeController.dispose();
    super.dispose();
  }

  void _addAsset() {
    if (_nameController.text.isEmpty || _qrCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Asset name and QR code are required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newAsset = Asset(
      id: 'NEW-${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text,
      category: _categoryController.text.isEmpty
          ? 'General'
          : _categoryController.text,
      location: _locationController.text.isEmpty
          ? 'Citeureup'
          : _locationController.text,
      status: _selectedStatus,
      qrCode: _qrCodeController.text,
      scannedDate: DateTime.parse('2025-08-20 04:02:21'), // Current time
      scannedBy: 'caccarehana', // Current user
    );

    widget.onAdd(newAsset);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Asset added successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF405189),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Add New Asset',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormField('Asset Name*', _nameController),
                  const SizedBox(height: 16),
                  _buildFormField('Category', _categoryController,
                      hint: 'e.g., IT Equipment'),
                  const SizedBox(height: 16),
                  _buildFormField('Location', _locationController,
                      hint: 'e.g., Citeureup - IT Department'),
                  const SizedBox(height: 16),
                  _buildFormField('QR Code*', _qrCodeController,
                      hint: 'e.g., QR001IT'),
                  const SizedBox(height: 16),

                  // Status dropdown
                  Text(
                    'Status',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedStatus,
                        isExpanded: true,
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                          });
                        },
                        items: _statusOptions.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(
                              status,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                color: Color(0xFF405189),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _addAsset,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF405189),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'Add Asset',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
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

  Widget _buildFormField(String label, TextEditingController controller,
      {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            color: Color(0xFF405189),
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Colors.grey[400],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF405189)),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }
}
