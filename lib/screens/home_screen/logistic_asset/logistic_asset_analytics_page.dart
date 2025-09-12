import 'package:Simba/screens/home_screen/logistic_asset/logistic_asset_model.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'logistic_asset_service.dart';

class LogisticAssetAnalyticsPage extends StatefulWidget {
  @override
  State<LogisticAssetAnalyticsPage> createState() => _LogisticAssetAnalyticsPageState();
}

class _LogisticAssetAnalyticsPageState extends State<LogisticAssetAnalyticsPage>
    with SingleTickerProviderStateMixin {
  List<LogisticAsset> assets = [];
  bool isLoading = true;
  String selectedTab = 'Category';

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAssets();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAssets() async {
    setState(() => isLoading = true);
    try {
      final data = await LogisticAssetService.getLogisticAssets();
      setState(() {
        assets = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Map<String, int> get statusAnalytics {
    int totalAvailable = 0, totalBroken = 0, totalLost = 0;
    for (var asset in assets) {
      totalAvailable += asset.available;
      totalBroken += asset.broken;
      totalLost += asset.lost;
    }
    return {
      'Available': totalAvailable,
      'Broken': totalBroken,
      'Lost': totalLost,
    };
  }

  Map<String, int> get categoryAnalytics {
    Map<String, int> categoryCount = {};
    for (var asset in assets) {
      final category = asset.category.isNotEmpty ? asset.category : 'Uncategorized';
      categoryCount[category] = (categoryCount[category] ?? 0) + asset.quantity;
    }
    return Map.fromEntries(
      categoryCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value))
    );
  }

  Map<String, int> get departmentAnalytics {
    Map<String, int> deptCount = {};
    for (var asset in assets) {
      final department = asset.department.isNotEmpty ? asset.department : 'Unassigned';
      deptCount[department] = (deptCount[department] ?? 0) + asset.quantity;
    }
    return Map.fromEntries(
      deptCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value))
    );
  }

  Map<String, int> get agingAnalytics {
    Map<String, int> agingCount = {};
    for (var asset in assets) {
      String agingKey = asset.aging.isEmpty ? 'Unknown' : asset.aging;
      agingCount[agingKey] = (agingCount[agingKey] ?? 0) + asset.quantity;
    }
    return Map.fromEntries(
      agingCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value))
    );
  }

  static const Color primaryColor = Color(0xFF405189);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);
  static const Color infoColor = Color(0xFF2196F3);

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.07),
            blurRadius: 7,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              SizedBox(height: 6),
              FittedBox(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontFamily: 'Maison Bold',
                  ),
                ),
              ),
              SizedBox(height: 2),
              FittedBox(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontFamily: 'Maison Book',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusPieChart() {
    final data = statusAnalytics;
    final total = data.values.fold(0, (sum, value) => sum + value);

    if (total == 0) {
      return Container(
        height: 120,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pie_chart_outline, size: 36, color: Colors.grey[400]),
              SizedBox(height: 8),
              Text(
                'No data available',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                  fontFamily: 'Maison Book',
                ),
              ),
            ],
          ),
        ),
      );
    }

    final colors = [successColor, errorColor, warningColor];

    return Container(
      height: 120,
      child: PieChart(
        PieChartData(
          sectionsSpace: 1,
          centerSpaceRadius: 30,
          startDegreeOffset: -90,
          sections: data.entries.toList().asMap().entries.map((entry) {
            final index = entry.key;
            final dataEntry = entry.value;
            final percentage = (dataEntry.value / total) * 100;

            return PieChartSectionData(
              value: dataEntry.value.toDouble(),
              color: colors[index % colors.length],
              title: percentage > 3 ? '${percentage.toStringAsFixed(0)}%' : '',
              radius: 27,
              titleStyle: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              titlePositionPercentageOffset: 0.55,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBarChart(Map<String, int> data, String title) {
    if (data.isEmpty) {
      return Container(
        height: 220,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.bar_chart, size: 40, color: Colors.grey[400]),
              ),
              SizedBox(height: 12),
              Text(
                'No data available',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontFamily: 'Maison Book',
                ),
              ),
            ],
          ),
        ),
      );
    }

    final entries = data.entries.take(8).toList(); 
    final maxValue = entries.isNotEmpty ? entries.first.value : 1;

    final List<Color> barColors = [
      Color(0xFF4F46E5), 
      Color(0xFF059669), 
      Color(0xFFDB2777), 
      Color(0xFFDC2626), 
      Color(0xFFD97706), 
      Color(0xFF7C3AED), 
      Color(0xFF0891B2), 
      Color(0xFF65A30D), 
    ];

    return Container(
      height: 220,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxValue.toDouble() * 1.15,
          backgroundColor: Colors.transparent,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.black87,
              tooltipRoundedRadius: 8,
              tooltipPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              tooltipMargin: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                if (group.x.toInt() >= entries.length) return null;
                final entry = entries[group.x.toInt()];
                return BarTooltipItem(
                  '${entry.key}\n${rod.toY.round()} items',
                  TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Maison Book',
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value.toInt() >= entries.length) return SizedBox.shrink();
                  String text = entries[value.toInt()].key;
                  return Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Transform.rotate(
                      angle: -0.3, // Slight rotation for better readability
                      child: Text(
                        text.length > 10 ? '${text.substring(0, 10)}...' : text,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Maison Book',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35,
                interval: maxValue > 10 ? (maxValue / 5).ceilToDouble() : 1,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Maison Book',
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            drawHorizontalLine: true,
            horizontalInterval: maxValue > 10 ? (maxValue / 5).ceilToDouble() : 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey[100]!,
                strokeWidth: 1,
              );
            },
          ),
          barGroups: entries.asMap().entries.map((entry) {
            final index = entry.key;
            final dataEntry = entry.value;
            final color = barColors[index % barColors.length];

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: dataEntry.value.toDouble(),
                  color: color,
                  width: 16,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxValue.toDouble() * 1.15,
                    color: Colors.grey[100]!,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // Enhanced Data Table with modern card design
  Widget _buildDataTable() {
    final currentData = selectedTab == 'Category' ? categoryAnalytics :
                      selectedTab == 'Department' ? departmentAnalytics :
                      agingAnalytics;

    final sortedEntries = currentData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = currentData.values.fold(0, (sum, value) => sum + value);

    if (sortedEntries.isEmpty) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!, width: 1),
        ),
        child: Center(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.table_chart, size: 32, color: Colors.grey[400]),
              ),
              SizedBox(height: 12),
              Text(
                "No data available",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontFamily: 'Maison Book',
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Color palette for progress indicators
    final List<Color> progressColors = [
      Color(0xFF4F46E5), // Indigo
      Color(0xFF059669), // Emerald
      Color(0xFFDB2777), // Pink
      Color(0xFFDC2626), // Red
      Color(0xFFD97706), // Amber
      Color(0xFF7C3AED), // Violet
      Color(0xFF0891B2), // Cyan
      Color(0xFF65A30D), // Lime
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.analytics, color: primaryColor, size: 20),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detailed $selectedTab Distribution',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                            fontFamily: 'Maison Bold',
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Total: $total items across ${sortedEntries.length} categories',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontFamily: 'Maison Book',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Enhanced Table Content
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: sortedEntries.asMap().entries.map((entry) {
                  final index = entry.key;
                  final dataEntry = entry.value;
                  final percentage = total > 0 ? (dataEntry.value / total * 100) : 0.0;
                  final color = progressColors[index % progressColors.length];
                  
                  return Container(
                    margin: EdgeInsets.only(bottom: 16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                dataEntry.key,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                  fontFamily: 'Maison Bold',
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${dataEntry.value} items',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                  fontFamily: 'Maison Book',
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 12),
                        
                        // Progress Bar
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Distribution',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                    fontFamily: 'Maison Book',
                                  ),
                                ),
                                Text(
                                  '${percentage.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: color,
                                    fontFamily: 'Maison Book',
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: percentage / 100,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced Distribution Analysis Section
  Widget _buildDistributionAnalysisSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Distribution Analysis',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Maison Bold',
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      'Analyze your assets across different categories',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontFamily: 'Maison Book',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 16),
        
        // Enhanced Tab Bar
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: primaryColor,
            indicator: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFamily: 'Maison Bold',
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              fontFamily: 'Maison Book',
            ),
            tabs: [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon(Icons.category, size: 16),
                    SizedBox(width: 6),
                    Text('Category'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon(Icons.business, size: 16),
                    SizedBox(width: 6),
                    Text('Department'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon(Icons.schedule, size: 16),
                    SizedBox(width: 6),
                    Text('Aging'),
                  ],
                ),
              ),
            ],
            onTap: (index) {
              setState(() {
                switch (index) {
                  case 0:
                    selectedTab = 'Category';
                    break;
                  case 1:
                    selectedTab = 'Department';
                    break;
                  case 2:
                    selectedTab = 'Aging';
                    break;
                }
              });
            },
          ),
        ),
        
        SizedBox(height: 16),
        
        // Enhanced Chart Card
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!, width: 1),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.bar_chart, color: primaryColor, size: 20),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Assets by $selectedTab',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Maison Bold',
                                color: Colors.grey[800],
                              ),
                            ),
                            Text(
                              'Visual breakdown of asset distribution',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontFamily: 'Maison Book',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  _buildBarChart(
                    selectedTab == 'Category'
                        ? categoryAnalytics
                        : selectedTab == 'Department'
                            ? departmentAnalytics
                            : agingAnalytics,
                    selectedTab,
                  ),
                ],
              ),
            ),
          ),
        ),
        
        SizedBox(height: 16),
        _buildDataTable(),
      ],
    );
  }

  Widget _buildLegend() {
    final data = statusAnalytics;
    final total = data.values.fold(0, (sum, value) => sum + value);

    if (total == 0) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem('Available', successColor, data['Available']!, total),
          _buildLegendItem('Broken', errorColor, data['Broken']!, total),
          _buildLegendItem('Lost', warningColor, data['Lost']!, total),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, int value, int total) {
    final percentage = total > 0 ? (value / total * 100) : 0.0;

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'Maison Book',
                  color: Colors.grey[700],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: 2),
        FittedBox(
          child: Text(
            '$value (${percentage.toStringAsFixed(1)}%)',
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey[600],
              fontFamily: 'Maison Book',
            ),
          ),
        ),
      ],
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
            style: TextStyle(fontFamily: 'Maison Bold', color: Colors.white),
          ),
          backgroundColor: primaryColor,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: primaryColor),
              SizedBox(height: 12),
              Text(
                'Loading analytics...',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontFamily: 'Maison Book',
                ),
              ),
            ],
          ),
        ),
      );
    }

    final totalAssets = assets.length;
    final totalQuantity = assets.fold(0, (sum, asset) => sum + asset.quantity);
    final totalAvailable = assets.fold(0, (sum, asset) => sum + asset.available);
    final totalBroken = assets.fold(0, (sum, asset) => sum + asset.broken);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Asset Analytics',
          style: TextStyle(fontFamily: 'Maison Bold', color: Colors.white),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
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
              // Overview Section
              Text(
                'Overview',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Maison Bold',
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                childAspectRatio: 1.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildSummaryCard('Total Assets', '$totalAssets', Icons.inventory_2, primaryColor),
                  _buildSummaryCard('Total Quantity', '$totalQuantity', Icons.category, infoColor),
                  _buildSummaryCard('Available', '$totalAvailable', Icons.check_circle, successColor),
                  _buildSummaryCard('Broken', '$totalBroken', Icons.error, errorColor),
                ],
              ),
              SizedBox(height: 18),
              
              Text(
                'Status Distribution',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Maison Bold',
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 8),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      _buildStatusPieChart(),
                      SizedBox(height: 9),
                      _buildLegend(),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 18),
              
              // Enhanced Distribution Analysis Section
              _buildDistributionAnalysisSection(),
            ],
          ),
        ),
      ),
    );
  }
}