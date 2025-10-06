import 'package:Simba/screens/scan_assets/scan_asset_page/recent_assets_scan/screen/asset_content.dart';
import 'package:Simba/screens/scan_assets/scan_asset_page/recent_assets_scan/screen/scan_asset_tab_button.dart';
import 'package:Simba/screens/scan_assets/scan_asset_page/recent_assets_scan/screen/scan_content.dart';
import 'package:Simba/screens/welcome_page/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:Simba/screens/activity_screen/screen/activity_page.dart';
import 'package:Simba/screens/setting_screen/settings_page.dart';
import 'package:Simba/screens/welcome_page/welcome_page.dart' as welcome;
import 'package:Simba/screens/home_screen/logistic_asset_scan_menu/screen/asset_upload_dialog.dart';
import 'package:Simba/screens/home_screen/logistic_asset/model/logistic_asset_model.dart';
import 'package:Simba/screens/scan_assets/scan_asset_page/recent_assets_scan/model/asset.dart';
import 'package:Simba/screens/scan_assets/scan_asset_page/service/asset_api_service.dart';
import 'package:Simba/screens/scan_assets/scan_asset_page/recent_assets_scan/screen/asset_detail_modal.dart';
import 'package:Simba/screens/scan_assets/scan_asset_page/recent_assets_scan/screen/qr_scanner_page.dart';
import 'package:Simba/screens/scan_assets/scan_asset_page/service/recent_asset_service.dart';
import 'package:Simba/screens/scan_assets/scan_asset_page/recent_assets_scan/model/recent_asset_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ScanAssetPage extends StatefulWidget {
  @override
  _ScanAssetPageState createState() => _ScanAssetPageState();
}

class _ScanAssetPageState extends State<ScanAssetPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _qrController = TextEditingController();

  List<Asset> assets = [];
  List<Asset> filteredAssets = [];
  List<RecentAsset> recentScannedAssetsDb = [];
  String selectedTab = 'Scan';
  bool isLoading = false;

  String currentUser = 'User';
  String currentUserName = 'Loading...';
  String currentUserFullName = 'User';
  bool isLoadingUserInfo = true;

  @override
  void initState() {
    super.initState();
    _loadUserSession();
    _loadAssets();
    _loadRecentScannedAssetsDb();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _qrController.dispose();
    super.dispose();
  }

  Future<void> _loadUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username') ?? 'user';
      final fullName = prefs.getString('full_name') ?? 'user';

      setState(() {
        currentUser = username;
        currentUserName = fullName;
        currentUserFullName = fullName;
        isLoadingUserInfo = false;
      });
    } catch (e) {
      setState(() {
        currentUser = 'user';
        currentUserName = 'user';
        currentUserFullName = 'user';
        isLoadingUserInfo = false;
      });
    }
  }

  Future<void> _loadRecentScannedAssetsDb() async {
    try {
      final assets =
          await RecentAssetService.getRecentAssets(scannedBy: currentUser);
      setState(() {
        recentScannedAssetsDb = assets;
      });
    } catch (e) {
      print("DEBUG: Error loading recent assets: $e");
    }
  }

  Future<void> _loadAssets([String? search]) async {
    setState(() => isLoading = true);
    try {
      final loadedAssets = await AssetApiService.getAssets(search: search);
      setState(() {
        assets = loadedAssets;
        filteredAssets = loadedAssets;
      });
    } catch (e) {
      // _showErrorSnackBarSafe('Failed to load assets: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white, size: 18),
                SizedBox(width: 6),
                Expanded(
                    child: Text('Gagal memuat data, silakan coba lagi.',
                        style: TextStyle(fontSize: 13))),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            // action: SnackBarAction(
            //   label: 'Retry',
            //   textColor: Colors.white,
            //   onPressed: _loadAssets,
            // ),
          ),
        );
      }
    } finally {
      setState(() => isLoading = false);
  
    }
  }

  Future<void> _openQRScanner() async {
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QRScannerPage(
            onQRScanned: (qrCode) => _processScannedQr(qrCode),
          ),
        ),
      );
    } catch (e) {
      _showErrorSnackBarSafe(
          'Scanner temporarily unavailable. Please use manual input.');
    }
  }

  void _simulateScan() {
    if (_qrController.text.isEmpty) {
      _showErrorSnackBarSafe('Please enter QR code to scan');
      return;
    }
    _processScannedQr(_qrController.text);
  }

  Future<void> _processScannedQr(String qrCode) async {
    setState(() {
      _qrController.text = qrCode;
      isLoading = true;
    });

    try {
      Asset? foundAsset = await _searchAsset(qrCode);

      if (foundAsset != null) {
        await _handleFoundAsset(foundAsset);
      } else {
        _showAssetNotRegisteredDialog(qrCode);
        _showErrorSnackBarSafe('Asset tidak terdaftar');
      }
    } catch (e) {
      _showErrorSnackBarSafe('Scan error: ${e.toString()}');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<Asset?> _searchAsset(String qrCode) async {
    try {
      final assetByQr = await AssetApiService.getAssetByQr(qrCode);
      if (assetByQr != null) return assetByQr;
    } catch (e) {
      print("DEBUG: getAssetByQr error: $e");
    }
    try {
      final assetByCode = await AssetApiService.getAssetByAssetCode(qrCode);
      if (assetByCode != null) return assetByCode;
    } catch (e) {
      print("DEBUG: getAssetByAssetCode error: $e");
    }

    final allAssets = await AssetApiService.getAssets(search: qrCode);
    for (Asset asset in allAssets) {
      if (asset.assetCode.toLowerCase() == qrCode.toLowerCase() ||
          asset.id.toString() == qrCode ||
          asset.name.toLowerCase().contains(qrCode.toLowerCase())) {
        return asset;
      }
    }
    return null;
  }

  Future<void> _handleFoundAsset(Asset foundAsset) async {
    final saveSuccess = await RecentAssetService.saveRecentAsset(
        foundAsset.assetCode, currentUser);

    if (saveSuccess) {
      await _loadRecentScannedAssetsDb();
    }

    _showAssetDetailsModal(foundAsset);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _updatePhotosCountOnly();
    });
  }

  Future<void> _updatePhotosCountOnly() async {
    await Future.delayed(Duration(milliseconds: 300));
    if (!mounted) return;
    await _updatePhotosCount();
    _showSuccessSnackBarSafe(
        'Asset berhasil di-scan! Silakan upload foto jika diperlukan.');
  }

  Future<void> _handlePhotoUpload(Asset foundAsset) async {
    await Future.delayed(Duration(milliseconds: 300));
    if (!mounted) return;

    final logisticAsset = _assetToLogisticAsset(foundAsset);
    final uploaded = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AssetUploadDialog(asset: logisticAsset),
    );

    if (uploaded == true) {
      _showSuccessSnackBarSafe('Foto asset berhasil diupload!');
      await _updatePhotosCount();
    }
  }

  Future<void> _updatePhotosCount() async {
    await Future.delayed(Duration(milliseconds: 1000));
    if (recentScannedAssetsDb.isNotEmpty) {
      final targetRecentAsset = recentScannedAssetsDb.first;
      final updateSuccess =
          await RecentAssetService.updatePhotosCount(targetRecentAsset.id);
      if (updateSuccess) {
        await _loadRecentScannedAssetsDb();
      }
    }
  }

  LogisticAsset _assetToLogisticAsset(Asset asset) {
    return LogisticAsset(
      id: asset.id.toString(),
      title: asset.name,
      assetNo: asset.assetCode,
      generalAccount: asset.generalAccount ?? '',
      subsidiaryAccount: asset.subsidiaryAccount ?? '',
      category: asset.category,
      subCategory: asset.subCategory ?? '',
      assetSpecification: asset.assetSpecification ?? '',
      assetStatus: asset.status,
      acquisitionDate: asset.acquisitionDate ?? asset.createdAt,
      aging: asset.aging ?? '',
      quantity: asset.quantity ?? 1,
      department: asset.location,
      controlDepartment: asset.controlDepartment ?? '',
      costCenter: asset.costCenter ?? '',
      available: asset.available ??
          (asset.status.toLowerCase() == 'available' ? 1 : 0),
      broken: asset.broken ??
          (asset.status.toLowerCase() == 'broken' ||
                  asset.status.toLowerCase() == 'damaged'
              ? 1
              : 0),
      lost: asset.lost ?? (asset.status.toLowerCase() == 'lost' ? 1 : 0),
      remarks: asset.remarks ?? asset.description,
      createdAt: asset.createdAt ?? DateTime.now(),
      updatedAt: asset.updatedAt ?? DateTime.now(),
      photos: asset.photos,
      primaryPhoto: asset.primaryPhoto,
    );
  }

  String getCurrentTime() {
    final nowUtc = DateTime.now().toUtc();
    final nowWib = nowUtc.add(const Duration(hours: 7));
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(nowWib);
  }

  String formatUpdatedTimeWIB(DateTime? updatedAt) {
    if (updatedAt == null) return "-";
    try {
      final dt = updatedAt.toUtc().add(const Duration(hours: 7));
      return DateFormat('HH:mm').format(dt);
    } catch (e) {
      return "-";
    }
  }

  void _filterAssets(String query) {
    if (query.isEmpty) {
      _loadAssets();
    } else {
      _loadAssets(query);
    }
  }

  void _onNavTap(int index) {
    switch (index) {
      case 0:
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => WelcomePage()));
        break;
      case 1:
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => ActivityPage()));
        break;
      case 2:
        break;
      case 3:
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => SettingsPage()));
        break;
    }
  }

  void _showAssetDetailsModal(Asset asset) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      enableDrag: true,
      builder: (context) => AssetDetailModal(
        asset: asset,
        showUploadPhotoButton: true,
        onPhotoUploaded: () async {
          await _updatePhotosCount();
        },
      ),
    );
  }

  void _showAssetNotRegisteredDialog(String qrCode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Asset Tidak Terdaftar'),
          content:
              Text('Asset dengan kode $qrCode tidak ditemukan dalam sistem.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _qrController.clear();
                setState(() {});
              },
              child: Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorSnackBarSafe(String message) {
    if (mounted) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _showErrorSnackBar(message);
      });
    }
  }

  void _showSuccessSnackBarSafe(String message) {
    if (mounted) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _showSuccessSnackBar(message);
      });
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(message,
                      style: TextStyle(fontFamily: 'Maison Book'))),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
              const Icon(Icons.check_circle_outline,
                  color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(message,
                      style: TextStyle(fontFamily: 'Maison Book'))),
            ],
          ),
          backgroundColor: const Color(0xFF405189),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Widget _buildTabButton(String label, IconData icon) {
    final bool isSelected = selectedTab == label;
    return ScanAssetTabButton(
      label: label,
      icon: icon,
      isSelected: isSelected,
      onTap: () => setState(() => selectedTab = label),
    );
  }

  List<Asset> get unscannedAssets {
    final scannedAssetNos = recentScannedAssetsDb.map((e) => e.assetNo).toSet();
    return assets.where((a) => !scannedAssetNos.contains(a.assetCode)).toList();
  }

  Widget _buildTabContent() {
    switch (selectedTab) {
      case 'Scan':
        return ScanContent(
          qrController: _qrController,
          recentAssets: recentScannedAssetsDb,
          isLoading: isLoading,
          totalAssets: assets.length,
          onOpenQRScanner: _openQRScanner,
          onSimulateScan: _simulateScan,
          onViewAllAssets: () => setState(() => selectedTab = 'Assets'),
          onQRCodeChanged: (value) => setState(() {}),
        );
      case 'Assets':
        final scannedAssetNos =
            recentScannedAssetsDb.map((e) => e.assetNo).toSet();

        return AssetsContent(
          searchController: _searchController,
          scannedAssets: filteredAssets
              .where((a) => scannedAssetNos.contains(a.assetCode))
              .toList(),
          unscannedAssets: filteredAssets
              .where((a) => !scannedAssetNos.contains(a.assetCode))
              .toList(),
          recentScannedAssets: recentScannedAssetsDb, 
          isLoading: isLoading,
          onFilterAssets: _filterAssets,
          formatUpdatedTimeWIB: formatUpdatedTimeWIB,
        );
      default:
        return ScanContent(
          qrController: _qrController,
          recentAssets: recentScannedAssetsDb,
          isLoading: isLoading,
          totalAssets: assets.length,
          onOpenQRScanner: _openQRScanner,
          onSimulateScan: _simulateScan,
          onViewAllAssets: () => setState(() => selectedTab = 'Assets'),
          onQRCodeChanged: (value) => setState(() {}),
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Scan Assets',
              style: TextStyle(
                fontFamily: 'Maison Bold',
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadAssets();
          await _loadUserSession();
          await _loadRecentScannedAssetsDb();
        },
        child: Column(
          children: [
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
                  Row(
                    children: [
                      Expanded(
                          child:
                              _buildTabButton('Scan', Icons.qr_code_scanner)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _buildTabButton('Assets', Icons.inventory)),
                    ],
                  ),
                  const SizedBox(height: 15),
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
                                  strokeWidth: 2, color: Colors.white70),
                            ),
                            const SizedBox(width: 8),
                          ],
                          // Text(
                          //   isLoadingUserInfo
                          //       ? 'Loading user...'
                          //       : 'Logged in as: $currentUserName',
                          //   style: const TextStyle(
                          //     fontFamily: 'Maison Book',
                          //     color: Colors.white70,
                          //     fontSize: 11,
                          //     fontWeight: FontWeight.w400,
                          //   ),
                          // ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      // Text(
                      //   'Current Time: ${getCurrentTime()}',
                      //   style: const TextStyle(
                      //     fontFamily: 'Maison Book',
                      //     color: Colors.white70,
                      //     fontSize: 10,
                      //     fontWeight: FontWeight.w400,
                      //   ),
                      // ),
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
      ),
      bottomNavigationBar: welcome.AppBottomNavBar(
        selectedIndex: 2,
        onTap: _onNavTap,
      ),
    );
  }
}
