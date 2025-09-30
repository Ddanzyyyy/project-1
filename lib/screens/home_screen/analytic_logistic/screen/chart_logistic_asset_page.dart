import 'package:Simba/screens/home_screen/logistic_asset/model/logistic_asset_model.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class ChartLogisticAssetsPage extends StatefulWidget {
  final List<LogisticAsset> assets;
  const ChartLogisticAssetsPage({required this.assets, Key? key})
      : super(key: key);

  @override
  State<ChartLogisticAssetsPage> createState() => _ChartLogisticAssetsPageState();
}

class _ChartLogisticAssetsPageState extends State<ChartLogisticAssetsPage> {
  int touchedStatusIndex = -1;

  static const Color primaryColor = Color(0xFF405189);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);

  List<Color> statusColors = const [successColor, errorColor, warningColor];
  List<Color> chartColors = const [
    Color(0xFF4F46E5), // indigo
    Color(0xFF059669), // green
    Color(0xFFDB2777), // pink
    Color(0xFFDC2626), // red
    Color(0xFFD97706), // orange
    Color(0xFF7C3AED), // violet
    Color(0xFF0891B2), // cyan
    Color(0xFFE11D48), // magenta
    Color(0xFF22D3EE), // light-cyan
    Color(0xFF6366F1), // blue-violet
    Color(0xFF65A30D), // olive
    Color(0xFFCA8A04), // yellow-brown
    Color(0xFFF59E42), // soft orange
    Color(0xFF14B8A6), // teal
    Color(0xFF64748B), // muted blue
    Color(0xFF3B82F6), // blue
    Color(0xFF9333EA), // deep purple
  ];

  Map<String, int> get statusAnalytics {
    int totalAvailable = 0, totalBroken = 0, totalLost = 0;
    for (var asset in widget.assets) {
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
    for (var asset in widget.assets) {
      final category = asset.category.isNotEmpty ? asset.category : 'Uncategorized';
      categoryCount[category] = (categoryCount[category] ?? 0) + asset.quantity;
    }
    return Map.fromEntries(categoryCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)));
  }

  Map<String, int> get departmentAnalytics {
    Map<String, int> deptCount = {};
    for (var asset in widget.assets) {
      final department = asset.department.isNotEmpty ? asset.department : 'Unassigned';
      deptCount[department] = (deptCount[department] ?? 0) + asset.quantity;
    }
    return Map.fromEntries(
        deptCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));
  }

  Map<String, int> get agingAnalytics {
    Map<String, int> agingCount = {};
    for (var asset in widget.assets) {
      String agingKey = _categorizeAging(asset.aging);
      agingCount[agingKey] = (agingCount[agingKey] ?? 0) + asset.quantity;
    }
    return Map.fromEntries(
        agingCount.entries.toList()..sort((a, b) => _agingOrder[a.key]!.compareTo(_agingOrder[b.key]!)));
  }

  final Map<String, int> _agingOrder = {
    '0-1 Years': 1,
    '1-3 Years': 2,
    '3-5 Years': 3,
    '5-10 Years': 4,
    '10+ Years': 5,
    'Unknown': 6,
  };

  String _categorizeAging(String aging) {
    if (aging.isEmpty) return 'Unknown';
    double? agingValue = double.tryParse(aging.replaceAll(RegExp("[^0-9.]"), ""));
    if (agingValue == null) return 'Unknown';
    if (agingValue <= 1) return '0-1 Years';
    if (agingValue <= 3) return '1-3 Years';
    if (agingValue <= 5) return '3-5 Years';
    if (agingValue <= 10) return '5-10 Years';
    return '10+ Years';
  }

  double get averageAging {
    int totalQty = 0;
    double totalAging = 0;
    for (var asset in widget.assets) {
      double? agingValue = double.tryParse(asset.aging.replaceAll(RegExp("[^0-9.]"), ""));
      if (agingValue != null) {
        totalAging += agingValue * asset.quantity;
        totalQty += asset.quantity;
      }
    }
    return totalQty == 0 ? 0 : totalAging / totalQty;
  }

  Map<String, dynamic> get summaryStatistics {
    final status = statusAnalytics;
    final total = status.values.fold(0, (sum, value) => sum + value);
    final availabilityRate = total > 0 ? (status['Available']! / total * 100) : 0;
    final breakageRate = total > 0 ? (status['Broken']! / total * 100) : 0;
    final lossRate = total > 0 ? (status['Lost']! / total * 100) : 0;
    final topCategory = categoryAnalytics.isNotEmpty ? categoryAnalytics.entries.first : null;
    final topDepartment = departmentAnalytics.isNotEmpty ? departmentAnalytics.entries.first : null;
    final topAging = agingAnalytics.isNotEmpty ? agingAnalytics.entries.first : null;
    return {
      'totalAssets': total,
      'availabilityRate': availabilityRate,
      'breakageRate': breakageRate,
      'lossRate': lossRate,
      'averageAging': averageAging,
      'totalCategories': categoryAnalytics.length,
      'totalDepartments': departmentAnalytics.length,
      'topCategory': topCategory,
      'topDepartment': topDepartment,
      'topAging': topAging,
    };
  }

  Widget _buildPieChart() {
    final data = statusAnalytics;
    final total = data.values.fold(0, (sum, value) => sum + value);
    final entries = data.entries.toList();

    if (total == 0) {
      return _buildEmptyChart('No status data available');
    }

    return _buildChartContainer(
      title: 'Asset Status Distribution',
      subtitle: 'Total: $total assets active',
      child: SizedBox(
        height: 180,
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedStatusIndex = -1;
                          return;
                        }
                        touchedStatusIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 3,
                  centerSpaceRadius: 35,
                  sections: List.generate(entries.length, (i) {
                    final isTouched = i == touchedStatusIndex;
                    final percentage = (entries[i].value / total) * 100;
                    return PieChartSectionData(
                      color: statusColors[i % statusColors.length],
                      value: entries[i].value.toDouble(),
                      title: percentage > 3 ? '${percentage.toStringAsFixed(0)}%' : '',
                      radius: isTouched ? 45 : 40,
                      titleStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
                      ),
                      borderSide: isTouched
                          ? BorderSide(color: Colors.white, width: 4)
                          : BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
                    );
                  }),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(entries.length, (i) {
                  final percentage = (entries[i].value / total) * 100;
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColors[i % statusColors.length].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: statusColors[i % statusColors.length],
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entries[i].key,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                              Text(
                                '${entries[i].value} (${percentage.toStringAsFixed(1)}%)',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(Map<String, int> data, String title, {String? subtitle}) {
    if (data.isEmpty) {
      return _buildEmptyChart('No data available for $title');
    }

    List<MapEntry<String, int>> entries = data.entries.toList();
    List<MapEntry<String, int>> visibleEntries = entries.take(8).toList();
    int othersSum = entries.skip(8).fold(0, (sum, e) => sum + e.value);
    if (entries.length > 8 && othersSum > 0) {
      visibleEntries.add(MapEntry('Others', othersSum));
    }

    final maxValue = visibleEntries.isNotEmpty
        ? visibleEntries.map((e) => e.value).reduce((a, b) => a > b ? a : b)
        : 1;

    return _buildChartContainer(
      title: title,
      subtitle: subtitle ?? 'Top ${visibleEntries.length} entries shown',
      child: SizedBox(
        height: 220,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxValue.toDouble() * 1.2,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: Colors.blueGrey.withOpacity(0.9),
                tooltipRoundedRadius: 7,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${visibleEntries[group.x.toInt()].key}\n${rod.toY.round()} items',
                    TextStyle(color: Colors.white, fontSize: 12),
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
                  reservedSize: 60,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    if (value.toInt() >= visibleEntries.length) return SizedBox.shrink();
                    String text = visibleEntries[value.toInt()].key;
                    text = text.length > 12 ? '${text.substring(0, 12)}...' : text;
                    return Transform.rotate(
                      angle: -0.5,
                      child: Container(
                        width: 60,
                        alignment: Alignment.topCenter,
                        child: Text(
                          text,
                          style: TextStyle(
                            fontSize: 10,
                            color: chartColors[value.toInt() % chartColors.length], // Use color indicator as label color
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
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
                  reservedSize: 40,
                  interval: maxValue > 10 ? (maxValue / 5).ceilToDouble() : 1,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    return Text(
                      value.toInt().toString(),
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxValue > 10 ? (maxValue / 5).ceilToDouble() : 1,
              getDrawingHorizontalLine: (value) =>
                  FlLine(color: Colors.grey[100]!, strokeWidth: 1),
            ),
            barGroups: visibleEntries.asMap().entries.map((entry) {
              final index = entry.key;
              final dataEntry = entry.value;
              final color = chartColors[index % chartColors.length];
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: dataEntry.value.toDouble(),
                    color: color,
                    width: 24,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(7),
                      topRight: Radius.circular(7),
                    ),
                  ),
                ],
                barsSpace: 6,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildUtilizationChart() {
    final categoryData = categoryAnalytics.entries.take(6).toList();
    if (categoryData.isEmpty) return SizedBox.shrink();
    final spots = List.generate(categoryData.length, (index) {
      return FlSpot(index.toDouble(), categoryData[index].value.toDouble());
    });

    return _buildChartContainer(
      title: 'Asset Utilization Trends',
      subtitle: 'Top categories asset distribution pattern',
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: spots.isNotEmpty
                  ? spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) / 5
                  : 1,
              getDrawingHorizontalLine: (value) =>
                  FlLine(color: Colors.grey[100]!, strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 35,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    if (value.toInt() >= categoryData.length) return SizedBox.shrink();
                    String text = categoryData[value.toInt()].key;
                    return Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        text.length > 8 ? '${text.substring(0, 8)}...' : text,
                        style: TextStyle(
                          fontSize: 10,
                          color: chartColors[value.toInt() % chartColors.length],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 35,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    return Text(
                      value.toInt().toString(),
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: spots.length > 1 ? spots.length.toDouble() - 1 : 1,
            minY: 0,
            maxY: spots.isNotEmpty
                ? spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) * 1.2
                : 100,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.35,
                color: chartColors[0],
                barWidth: 4,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) =>
                      FlDotCirclePainter(
                    radius: 6,
                    color: chartColors[index % chartColors.length],
                    strokeWidth: 3,
                    strokeColor: Colors.white,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: chartColors[0].withOpacity(0.16),
                ),
                shadow: Shadow(
                  color: chartColors[0].withOpacity(0.18),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                tooltipBgColor: primaryColor.withOpacity(0.9),
                tooltipRoundedRadius: 7,
                getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                  return touchedBarSpots.map((barSpot) {
                    final category = categoryData[barSpot.x.toInt()].key;
                    return LineTooltipItem(
                      '$category\n${barSpot.y.toInt()} assets',
                      TextStyle(color: Colors.white, fontSize: 12),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartContainer({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: 'Maison Bold',
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
          SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildEmptyChart(String message) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.bar_chart, size: 48, color: Colors.grey[300]),
            SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsFooter() {
    final stats = summaryStatistics;
    final currencyFormat = NumberFormat.compactCurrency(symbol: 'Rp', decimalDigits: 0);

    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: primaryColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights, color: primaryColor, size: 20),
              SizedBox(width: 8),
              Text(
                'Key Insights',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'Maison Bold',
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _buildInsightItem(
            'Asset Availability',
            'Available: ${stats['availabilityRate'].toStringAsFixed(1)}%. Broken: ${stats['breakageRate'].toStringAsFixed(1)}%. Lost: ${stats['lossRate'].toStringAsFixed(1)}%.',
            successColor
          ),
          stats['topCategory'] != null
              ? _buildInsightItem(
                  'Top Category',
                  'Kategori terbanyak: ${stats['topCategory'].key} (${stats['topCategory'].value} assets)',
                  chartColors[0],
                )
              : SizedBox.shrink(),
          stats['topDepartment'] != null
              ? _buildInsightItem(
                  'Top Department',
                  'Departemen terbanyak: ${stats['topDepartment'].key} (${stats['topDepartment'].value} assets)',
                  chartColors[1],
                )
              : SizedBox.shrink(),
          stats['topValueCategory'] != null
              ? _buildInsightItem(
                  'Highest Value Category',
                  'Kategori nilai tertinggi: ${stats['topValueCategory'].key} (${currencyFormat.format(stats['topValueCategory'].value)})',
                  chartColors[3],
                )
              : SizedBox.shrink(),
          Text(
            'Last updated: ${DateTime.now().toString().substring(0, 16)}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(String title, String description, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
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

  /// ----- Main -----
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Asset Analytics Dashboard',
          style: TextStyle(
            fontFamily: 'Maison Bold',
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
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () => setState(() {}),
            tooltip: 'Refresh Analytics',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPieChart(),
            _buildBarChart(
              categoryAnalytics,
              'Asset Category Distribution',
              subtitle: 'Assets distributed across categories'
            ),
            _buildBarChart(
              departmentAnalytics,
              'Department Asset Distribution',
              subtitle: 'Assets allocated to departments'
            ),
            _buildBarChart(
              agingAnalytics,
              'Asset Age Distribution',
              subtitle: 'Assets grouped by age ranges'
            ),
            _buildUtilizationChart(),
            _buildAnalyticsFooter(),
          ],
        ),
      ),
    );
  }
}