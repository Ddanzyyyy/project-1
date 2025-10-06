import 'package:Simba/screens/home_screen/logistic_asset/model/logistic_asset_model.dart';
import 'package:Simba/screens/home_screen/logistic_asset/service/logistic_asset_service.dart';
import 'package:flutter/material.dart';
import 'chart_logistic_asset_page.dart';

class LogisticAssetAnalyticsPage extends StatefulWidget {
  @override
  State<LogisticAssetAnalyticsPage> createState() =>
      _LogisticAssetAnalyticsPageState();
}

class _LogisticAssetAnalyticsPageState extends State<LogisticAssetAnalyticsPage>
    with SingleTickerProviderStateMixin {
  List<LogisticAsset> assets = [];
  bool isLoading = true;
  String errorMessage = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadAssets();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAssets() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final data = await LogisticAssetService.getLogisticAssets();
      setState(() {
        assets = data;
        isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Gagal memuat data, silakan coba lagi.';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white, size: 18),
                SizedBox(width: 6),
                Expanded(
                    child: Text('Gagal memuat data analitik, silakan coba lagi.',
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
    }
  }

  int get totalAssets => assets.length;
  int get totalQuantity => assets.fold(0, (sum, asset) => sum + asset.quantity);
  int get totalAvailable =>
      assets.fold(0, (sum, asset) => sum + asset.available);
  int get totalBroken => assets.fold(0, (sum, asset) => sum + asset.broken);
  int get totalLost => assets.fold(0, (sum, asset) => sum + asset.lost);
  int get totalInUse =>
      totalQuantity - totalAvailable - totalBroken - totalLost;

  double get utilizationRate {
    if (totalQuantity == 0) return 0;
    return ((totalQuantity - totalAvailable) / totalQuantity) * 100;
  }

  double get availabilityRate {
    if (totalQuantity == 0) return 0;
    return (totalAvailable / totalQuantity) * 100;
  }

  double get maintenanceRate {
    if (totalQuantity == 0) return 0;
    return (totalBroken / totalQuantity) * 100;
  }

  double get lossRate {
    if (totalQuantity == 0) return 0;
    return (totalLost / totalQuantity) * 100;
  }

  String get healthStatus {
    if (maintenanceRate > 20) return 'Critical';
    if (maintenanceRate > 10) return 'Warning';
    if (lossRate > 5) return 'Attention';
    return 'Good';
  }

  Color get healthStatusColor {
    switch (healthStatus) {
      case 'Critical':
        return errorColor;
      case 'Warning':
        return warningColor;
      case 'Attention':
        return Color(0xFFFF7043);
      default:
        return successColor;
    }
  }

  static const Color primaryColor = Color(0xFF405189);
  // static const Color secondaryColor = Color(0xFF6366F1);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);
  // static const Color infoColor = Color(0xFF3B82F6);
  // static const Color purpleColor = Color(0xFF8B5CF6);

  Widget _buildCompactSummaryCard(
      String title, String value, IconData icon, Color color,
      {String? subtitle}) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
            if (subtitle != null) ...[
              SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompactHealthCard() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color: healthStatusColor.withOpacity(0.1),
          border: Border.all(color: healthStatusColor.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: healthStatusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(
                healthStatus == 'Good'
                    ? Icons.check_circle
                    : healthStatus == 'Critical'
                        ? Icons.error
                        : Icons.warning,
                color: healthStatusColor,
                size: 18,
              ),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Health Status',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  healthStatus,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: healthStatusColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactActions() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(children: [
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
                elevation: 0,
              ),
              icon: Icon(Icons.bar_chart, size: 16),
              label: Text(
                'Charts',
                style: TextStyle(fontSize: 12),
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChartLogisticAssetsPage(assets: assets),
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          // Expanded(
          //   child: ElevatedButton.icon(
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: secondaryColor,
          //       foregroundColor: Colors.white,
          //       padding: EdgeInsets.symmetric(vertical: 8),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(7),
          //       ),
          //       elevation: 0,
          //     ),
          //     icon: Icon(Icons.download, size: 16),
          //     label: Text(
          //       'Export',
          //       style: TextStyle(fontSize: 12),
          //     ),
          //     onPressed: () {
          //       ScaffoldMessenger.of(context).showSnackBar(
          //         SnackBar(
          //           content: Text('Export feature coming soon!', style: TextStyle(fontSize: 13)),
          //         ),
          //       );
          //     },
          //   ),
        ]),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.grey[400],
          ),
          SizedBox(height: 12),
          Text(
            'Gagal memuat data',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Silakan coba lagi nanti.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
            ),
            icon: Icon(Icons.refresh, size: 18),
            label: Text('Coba Lagi', style: TextStyle(fontSize: 13)),
            onPressed: _loadAssets,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(
            'Asset Analytics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          backgroundColor: primaryColor,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: primaryColor,
                strokeWidth: 2.5,
              ),
              SizedBox(height: 12),
              Text(
                'Loading analytics...',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (errorMessage.isNotEmpty && assets.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(
            'Asset Analytics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          backgroundColor: primaryColor,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: _buildErrorState(),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Asset Analytics',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white, size: 20),
            onPressed: _loadAssets,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAssets,
        color: primaryColor,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Health Status Card
              _buildCompactHealthCard(),
              SizedBox(height: 12),

              // Summary Cards Grid
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                childAspectRatio: 0.9,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: [
                  _buildCompactSummaryCard(
                    'Total Data',
                    '$totalAssets',
                    Icons.inventory_2,
                    primaryColor,
                  ),
                  // _buildCompactSummaryCard(
                  //   'Total Quantity',
                  //   '$totalQuantity',
                  //   Icons.category,
                  //   infoColor,
                  // ),
                  _buildCompactSummaryCard(
                    'Available',
                    '$totalAvailable',
                    Icons.check_circle,
                    successColor,
                    // subtitle: '${availabilityRate.toStringAsFixed(1)}%',
                  ),
                  // _buildCompactSummaryCard(
                  //   'In Use',
                  //   '$totalInUse',
                  //   Icons.work,
                  //   purpleColor,
                  //   subtitle: '${utilizationRate.toStringAsFixed(1)}%',
                  // ),
                  _buildCompactSummaryCard(
                    'Broken',
                    '$totalBroken',
                    Icons.error,
                    errorColor,
                    // subtitle: '${maintenanceRate.toStringAsFixed(1)}%',
                  ),
                  _buildCompactSummaryCard(
                    'Lost',
                    '$totalLost',
                    Icons.report_problem,
                    warningColor,
                    // subtitle: '${lossRate.toStringAsFixed(1)}%',
                  ),
                ],
              ),

              SizedBox(height: 12),

              // Quick Actions Section
              _buildCompactActions(),

              SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
