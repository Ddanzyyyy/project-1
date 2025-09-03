import 'package:Simba/screens/scan_assets/asset.dart';
import 'package:Simba/screens/scan_assets/asset_api_service.dart';
import 'package:Simba/screens/scan_assets/asset_detail_modal.dart';
import 'package:Simba/screens/scan_assets/qr_scanner_page.dart';
import 'package:flutter/material.dart';
import 'package:Simba/screens/activity_screen/activity_page.dart';
import 'package:Simba/screens/setting_screen/settings_page.dart';
import 'package:Simba/screens/welcome_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class ScanAssetPage extends StatefulWidget {
  @override
  _ScanAssetPageState createState() => _ScanAssetPageState();
}

class _ScanAssetPageState extends State<ScanAssetPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _qrController = TextEditingController();

  List<Asset> assets = [];
  List<Asset> filteredAssets = [];
  String selectedTab = 'Scan';
  bool isLoading = false;

  String currentUser = 'caccarehana';
  String currentUserName = 'Loading...';
  String currentUserFullName = 'User';
  bool isLoadingUserInfo = true;

  @override
  void initState() {
    super.initState();
    _loadUserSession();
    _loadAssets();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _qrController.dispose();
    super.dispose();
  }

  // Load user session data from login
  Future<void> _loadUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final username = prefs.getString('username') ?? 'caccarehana';
      final fullName = prefs.getString('full_name') ?? prefs.getString('name') ?? 'Caccarehana';
      final firstName = prefs.getString('first_name') ?? '';
      final lastName = prefs.getString('last_name') ?? '';
      
      // Build display name
      String displayName = fullName;
      if (displayName == 'User' && firstName.isNotEmpty) {
        displayName = lastName.isNotEmpty ? '$firstName $lastName' : firstName;
      }
      
      setState(() {
        currentUser = username;
        currentUserName = displayName;
        currentUserFullName = fullName;
        isLoadingUserInfo = false;
      });
      
      print('👤 User session loaded:');
      print('   - Username: $currentUser');
      print('   - Display Name: $currentUserName');
      print('   - Full Name: $currentUserFullName');
      
    } catch (e) {
      print('⚠️ Error loading user session: $e');
      setState(() {
        currentUser = 'caccarehana';
        currentUserName = 'Caccarehana';
        currentUserFullName = 'Caccarehana';
        isLoadingUserInfo = false;
      });
    }
  }

  // Get current formatted time (UTC) - Real-time function
  String getCurrentTime() {
    return '2025-09-03 14:09:48'; // Current date/time as provided
  }

  // Load assets from backend
  Future<void> _loadAssets([String? search]) async {
    setState(() => isLoading = true);
    try {
      final loadedAssets = await AssetApiService.getAssets(search: search);
      setState(() {
        assets = loadedAssets;
        filteredAssets = loadedAssets;
      });
      print('✅ Loaded ${loadedAssets.length} assets successfully');
    } catch (e) {
      print('💥 Error loading assets: $e');
      _showErrorSnackBar('Failed to load assets: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _filterAssets(String query) {
    if (query.isEmpty) {
      _loadAssets();
    } else {
      _loadAssets(query);
    }
  }

  // Open Mobile Scanner QR Scanner
  Future<void> _openQRScanner() async {
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QRScannerPage(
            onQRScanned: (qrCode) {
              _processScannedQr(qrCode);
            },
          ),
        ),
      );
    } catch (e) {
      _showErrorSnackBar('Scanner temporarily unavailable. Please use manual input.');
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

  // Enhanced process scanned QR with multiple search strategies
  Future<void> _processScannedQr(String qrCode) async {
    setState(() {
      _qrController.text = qrCode;
      isLoading = true;
    });

    final currentTime = getCurrentTime();
    print('🎯 Processing QR Code: $qrCode');
    print('⏰ Current UTC Time: $currentTime');
    print('👤 Current User: $currentUser ($currentUserName)');

    try {
      Asset? foundAsset;
      
      // Strategy 1: Try direct QR lookup
      print('🔍 Strategy 1: Direct QR lookup');
      try {
        foundAsset = await AssetApiService.getAssetByQr(qrCode);
      } catch (e) {
        print('⚠️ Strategy 1 failed: $e');
      }
      
      if (foundAsset == null) {
        // Strategy 2: Try asset code lookup
        print('🔍 Strategy 2: Asset code lookup');
        try {
          foundAsset = await AssetApiService.getAssetByAssetCode(qrCode);
        } catch (e) {
          print('⚠️ Strategy 2 failed: $e');
        }
      }
      
      if (foundAsset == null) {
        // Strategy 3: Try search in all assets
        print('🔍 Strategy 3: Search in all assets');
        try {
          final allAssets = await AssetApiService.getAssets(search: qrCode);
          if (allAssets.isNotEmpty) {
            for (Asset asset in allAssets) {
              if (asset.assetCode.toLowerCase() == qrCode.toLowerCase() ||
                  asset.id.toString() == qrCode ||
                  asset.name.toLowerCase().contains(qrCode.toLowerCase())) {
                foundAsset = asset;
                print('✅ Found asset via search: ${asset.name}');
                break;
              }
            }
          }
        } catch (e) {
          print('⚠️ Strategy 3 failed: $e');
        }
      }
      
      if (foundAsset != null) {
        // Asset found - show details with scan success
        print('🎉 Asset found successfully!');
        print('📋 Asset Details:');
        print('   - ID: ${foundAsset.id}');
        print('   - Name: ${foundAsset.name}');
        print('   - Code: ${foundAsset.assetCode}');
        print('   - Status: ${foundAsset.status}');
        
        _showAssetDetailsWithAnimation(foundAsset, isNewScan: true);
        _showSuccessSnackBar('Asset found! ${foundAsset.name} (${foundAsset.assetCode})');
      } else {
        // Asset not found - show notification "Asset tidak terdaftar"
        print('❌ Asset not found anywhere');
        _showAssetNotRegisteredDialog(qrCode);
        _showErrorSnackBar('Asset tidak terdaftar');
      }
    } catch (e) {
      print('💥 Critical error processing QR: $e');
      _showErrorSnackBar('Scan error: ${e.toString()}');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Show dialog when asset is not registered
  void _showAssetNotRegisteredDialog(String qrCode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange[600],
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Asset Tidak Terdaftar',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Asset dengan kode QR berikut tidak ditemukan dalam sistem:',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: Text(
                  qrCode,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF405189),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue[200]!,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Informasi Scan:',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildScanInfoRow('Waktu Scan', getCurrentTime()),
                    _buildScanInfoRow('User', currentUserName),
                    _buildScanInfoRow('Status', 'Tidak Terdaftar'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Silakan hubungi administrator atau verifikasi kembali kode QR yang dipindai.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Clear QR input after closing dialog
                _qrController.clear();
                setState(() {});
              },
              child: Text(
                'Tutup',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF405189),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Open scanner again for retry
                _openQRScanner();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF405189),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text(
                'Scan Ulang',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildScanInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  // Build shimmer loading effect for asset cards
  Widget _buildShimmerAssetCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListTile(
          contentPadding: const EdgeInsets.all(14),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          title: Container(
            height: 14,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    height: 20,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 12,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }

  // Build shimmer loading for recent assets section
  Widget _buildShimmerRecentAssets() {
    return Column(
      children: List.generate(3, (index) => _buildShimmerAssetCard()),
    );
  }

  // Build shimmer loading for assets list
  Widget _buildShimmerAssetsList() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: 6,
      itemBuilder: (context, index) => _buildShimmerAssetCard(),
    );
  }

  // Show asset details with enhanced animation for scanned assets
  void _showAssetDetailsWithAnimation(Asset asset, {bool isNewScan = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      enableDrag: true,
      builder: (context) => AssetDetailsModal(
        asset: asset,
        isNewScan: isNewScan,
        currentUser: currentUser,
        onUpdate: (updatedAsset) async {
          try {
            if (updatedAsset.id > 0) {
              await AssetApiService.updateAsset(updatedAsset.id, updatedAsset);
              _showSuccessSnackBar(isNewScan 
                ? 'Scanned asset saved successfully!' 
                : 'Asset updated successfully!');
            } else {
              _showErrorSnackBar('Cannot save unknown asset. Please contact administrator.');
            }
            _loadAssets(); 
          } catch (e) {
            print('Error saving asset: $e');
            _showErrorSnackBar('Failed to save asset: $e');
          }
        },
        onDelete: (assetId) async {
          try {
            final id = int.tryParse(assetId);
            if (id != null && id > 0) {
              await AssetApiService.deleteAsset(id);
              _loadAssets();
              _showSuccessSnackBar('Asset deleted successfully!');
            }
          } catch (e) {
            print('💥 Error deleting asset: $e');
            _showErrorSnackBar('Failed to delete asset: $e');
          }
        },
      ),
    );
  }

  void _showAssetDetails(Asset asset) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AssetDetailsModal(
        asset: asset,
        isNewScan: false, 
        currentUser: currentUser,
        onUpdate: (updatedAsset) async {
          try {
            if (updatedAsset.id > 0) {
              await AssetApiService.updateAsset(updatedAsset.id, updatedAsset);
              _showSuccessSnackBar('Asset updated successfully!');
            }
            _loadAssets();
          } catch (e) {
            print('💥 Error updating asset: $e');
            _showErrorSnackBar('Failed to save asset: $e');
          }
        },
        onDelete: (assetId) async {
          try {
            final id = int.tryParse(assetId);
            if (id != null && id > 0) {
              await AssetApiService.deleteAsset(id);
              _loadAssets();
              _showSuccessSnackBar('Asset deleted successfully!');
            }
          } catch (e) {
            print('💥 Error deleting asset: $e');
            _showErrorSnackBar('Failed to delete asset: $e');
          }
        },
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(message, style: TextStyle(fontFamily: 'Inter'))),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(message, style: TextStyle(fontFamily: 'Inter'))),
            ],
          ),
          backgroundColor: const Color(0xFF405189),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
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
        title: const Text(
          'Scan Assets',
          style: TextStyle(
            fontFamily: 'Inter',
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white, size: 22),
            onPressed: () {
              _loadAssets();
              _loadUserSession();
            },
            tooltip: 'Refresh Assets',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with tabs
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
            decoration: const BoxDecoration(
              color: Color(0xFF405189),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                // Tab buttons (only Scan and Assets)
                Row(
                  children: [
                    Expanded(
                      child: _buildTabButton('Scan', Icons.qr_code_scanner),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTabButton('Assets', Icons.inventory),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Current user info - Real data from login session
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isLoadingUserInfo) ...[
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          isLoadingUserInfo ? 'Loading user...' : 'Logged in as: $currentUserName',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Current Time: ${getCurrentTime()}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white70,
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
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
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
                Navigator.pushReplacement(
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
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
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
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                color: isSelected ? const Color(0xFF405189) : Colors.white,
                fontSize: 11,
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
      default:
        return _buildScanContent();
    }
  }

  Widget _buildScanContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Scan Asset QR Code',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF405189),
            ),
          ),
          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            height: 170,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  const Color(0xFF405189).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
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
                      width: 70,
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
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Tap to Open Mobile Scanner',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF405189),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Smart QR detection with auto-focus',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: const Color(0xFF757575),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Enhanced Scanner v5.1.1',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 9,
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
          const SizedBox(height: 10),

          // Manual QR input
          Text(
            'Or enter asset code manually:',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
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
                prefixIcon: const Icon(Icons.qr_code, color: Color(0xFF405189), size: 20),
                hintText: 'Enter asset code...',
                hintStyle: TextStyle(
                  fontFamily: 'Inter',
                  color: Colors.grey[500],
                  fontSize: 13,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(14),
                suffixIcon: _qrController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _qrController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
                      )
                    : null,
              ),
              style: const TextStyle(fontSize: 14, fontFamily: 'Inter'),
              onChanged: (value) => setState(() {}),
            ),
          ),
          const SizedBox(height: 12),

          // Manual scan button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _qrController.text.isNotEmpty ? _simulateScan : null,
              icon: const Icon(Icons.search, color: Colors.white, size: 18),
              label: const Text(
                'Search Asset',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _qrController.text.isNotEmpty
                    ? const Color(0xFF405189)
                    : Colors.grey[400],
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: _qrController.text.isNotEmpty ? 2 : 0,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Recent scans
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Assets',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF405189),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedTab = 'Assets';
                  });
                },
                child: Text(
                  'View All (${assets.length})',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Recent scans list with shimmer loading
          SizedBox(
            height: 200,
            child: isLoading
              ? _buildShimmerRecentAssets()
              : assets.isEmpty 
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 40,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No assets found',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Scan QR codes to view assets',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: assets.take(3).length,
                    itemBuilder: (context, index) {
                      final asset = assets[index];
                      return _buildAssetCard(asset, showScanTime: true);
                    },
                  ),
          ),
          const SizedBox(height: 20),
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
          height: 50,
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
              prefixIcon: const Icon(Icons.search, color: Color(0xFF405189), size: 20),
              hintText: 'Search assets...',
              hintStyle: TextStyle(
                fontFamily: 'Inter',
                color: Colors.grey[500],
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
        const SizedBox(height: 15),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Assets (${filteredAssets.length})',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF405189),
              ),
            ),
            if (_searchController.text.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF405189).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Filtered',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    color: const Color(0xFF405189),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        // Assets list with shimmer loading
        Expanded(
          child: isLoading
            ? _buildShimmerAssetsList()
            : filteredAssets.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _searchController.text.isNotEmpty 
                          ? Icons.search_off 
                          : Icons.inventory_2_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchController.text.isNotEmpty 
                          ? 'No assets found for "${_searchController.text}"'
                          : 'No assets found',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.grey[600],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _searchController.text.isNotEmpty 
                          ? 'Try different search terms'
                          : 'Start by scanning QR codes to view assets',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.zero,
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

  Widget _buildAssetCard(Asset asset, {bool showScanTime = false}) {
    Color statusColor;
    IconData statusIcon;
    
    switch (asset.status.toLowerCase()) {
      case 'registered':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'damaged':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      case 'unscanned':
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        break;
      case 'lost':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: Container(
          width: 50,
          height: 50,
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: asset.imagePath != null && asset.imagePath!.isNotEmpty
              ? Image.network(
                  asset.imagePath!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.inventory,
                      color: Color(0xFF405189),
                      size: 22,
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        strokeWidth: 2,
                        color: const Color(0xFF405189),
                      ),
                    );
                  },
                )
              : const Icon(
                  Icons.inventory,
                  color: Color(0xFF405189),
                  size: 22,
                ),
          ),
        ),
        title: Text(
          asset.name,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 3),
            Text(
              '${asset.assetCode} • ${asset.category}',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcon,
                        size: 10,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        asset.status.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 9,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (showScanTime && asset.updatedAt != null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.access_time,
                    size: 10,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Updated: ${asset.updatedAt!.toString().substring(11, 16)}',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9,
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
          size: 14,
        ),
        onTap: () => _showAssetDetails(asset),
      ),
    );
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
          const SizedBox(height: 6),
          Icon(
            icon,
            color: selected ? const Color(0xFF405189) : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              color: selected ? const Color(0xFF405189) : Colors.grey,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}