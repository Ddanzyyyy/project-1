import 'package:Simba/screens/home_screen/logistic_asset/logistic_asset_model.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartLogisticAssetsPage extends StatefulWidget {
  final List<LogisticAsset> assets;
  const ChartLogisticAssetsPage({required this.assets, Key? key})
      : super(key: key);

  @override
  State<ChartLogisticAssetsPage> createState() =>
      _ChartLogisticAssetsPageState();
}

class _ChartLogisticAssetsPageState extends State<ChartLogisticAssetsPage> {
  int touchedStatusIndex = -1;
  int touchedCategoryIndex = -1;
  int touchedDepartmentIndex = -1;
  int touchedAgingIndex = -1;

  static const Color primaryColor = Color(0xFF405189);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);

  List<Color> statusColors = const [successColor, errorColor, warningColor];
  List<Color> chartColors = const [
    Color(0xFF4F46E5),
    Color(0xFF059669),
    Color(0xFFDB2777),
    Color(0xFFDC2626),
    Color(0xFFD97706),
    Color(0xFF7C3AED),
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
      final category =
          asset.category.isNotEmpty ? asset.category : 'Uncategorized';
      categoryCount[category] = (categoryCount[category] ?? 0) + asset.quantity;
    }
    return Map.fromEntries(categoryCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)));
  }

  Map<String, int> get departmentAnalytics {
    Map<String, int> deptCount = {};
    for (var asset in widget.assets) {
      final department =
          asset.department.isNotEmpty ? asset.department : 'Unassigned';
      deptCount[department] = (deptCount[department] ?? 0) + asset.quantity;
    }
    return Map.fromEntries(
        deptCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));
  }

  Map<String, int> get agingAnalytics {
    Map<String, int> agingCount = {};
    for (var asset in widget.assets) {
      String agingKey = asset.aging.isEmpty ? 'Unknown' : asset.aging;
      agingCount[agingKey] = (agingCount[agingKey] ?? 0) + asset.quantity;
    }
    return Map.fromEntries(
        agingCount.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
  }

  double get averageAging {
    final data = agingAnalytics;
    int totalQty = 0;
    double totalAging = 0;
    for (var e in data.entries) {
      double? agingValue =
          double.tryParse(e.key.replaceAll(RegExp("[^0-9.]"), ""));
      if (agingValue != null) {
        totalAging += agingValue * e.value;
        totalQty += e.value;
      }
    }
    return totalQty == 0 ? 0 : totalAging / totalQty;
  }

  List<FlSpot> get assetTrendData {
    final categories = categoryAnalytics.entries.take(6).toList();
    return List.generate(categories.length, (index) {
      return FlSpot(index.toDouble(), categories[index].value.toDouble());
    });
  }

  Widget _buildPieChart() {
    final data = statusAnalytics;
    final total = data.values.fold(0, (sum, value) => sum + value);
    final entries = data.entries.toList();

    if (total == 0) {
      return Container(
        height: 120,
        child: Center(
            child: Text('No data available',
                style: TextStyle(color: Colors.grey[500]))),
      );
    }

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status Distribution',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
              fontFamily: 'Maison Bold',
            ),
          ),
          SizedBox(height: 14),
          SizedBox(
            height: 120,
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
                            touchedStatusIndex = pieTouchResponse
                                .touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 2,
                      centerSpaceRadius: 25,
                      sections: List.generate(entries.length, (i) {
                        final isTouched = i == touchedStatusIndex;
                        final percentage = (entries[i].value / total) * 100;
                        return PieChartSectionData(
                          color: statusColors[i % statusColors.length],
                          value: entries[i].value.toDouble(),
                          title: percentage > 5
                              ? '${percentage.toStringAsFixed(0)}%'
                              : '',
                          radius: isTouched ? 30 : 30,
                          titleStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          borderSide: isTouched
                              ? BorderSide(color: Colors.white, width: 3)
                              : BorderSide.none,
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
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: statusColors[i % statusColors.length],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${entries[i].key}: ${entries[i].value} (${percentage.toStringAsFixed(1)}%)',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[700],
                                ),
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
        ],
      ),
    );
  }

  Widget _buildBarChart(Map<String, int> data, String title) {
    if (data.isEmpty) {
      return Container(
        height: 250,
        child: Center(
            child: Text('No data available',
                style: TextStyle(color: Colors.grey[500]))),
      );
    }

    // Batasi jumlah bar
    List<MapEntry<String, int>> entries = data.entries.toList();
    List<MapEntry<String, int>> visibleEntries = entries.take(7).toList();
    int othersSum = entries.skip(7).fold(0, (sum, e) => sum + e.value);
    if (entries.length > 7 && othersSum > 0) {
      visibleEntries.add(MapEntry('Others', othersSum));
    }
    final maxValue = visibleEntries.isNotEmpty
        ? visibleEntries.map((e) => e.value).reduce((a, b) => a > b ? a : b)
        : 1;

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
              fontFamily: 'Maison Bold',
            ),
          ),
          if (entries.length > 7)
            Padding(
              padding: const EdgeInsets.only(top: 6.0, bottom: 6.0),
              child: Text(
                'Hanya 7 data teratas yang ditampilkan. Sisanya digabung sebagai "Others".',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxValue.toDouble() * 1.15,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 55, // Lebih besar agar label miring muat
                      getTitlesWidget: (double value, TitleMeta meta) {
                        if (value.toInt() >= visibleEntries.length)
                          return SizedBox.shrink();
                        String text = visibleEntries[value.toInt()].key;
                        // Potong jika terlalu panjang
                        text = text.length > 10
                            ? '${text.substring(0, 10)}...'
                            : text;
                        return Transform.rotate(
                          angle: -0.7, // Rotasi 45°
                          child: Container(
                            width: 55,
                            alignment: Alignment.topCenter,
                            child: Text(
                              text,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
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
                      interval:
                          maxValue > 10 ? (maxValue / 5).ceilToDouble() : 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          value.toInt().toString(),
                          style:
                              TextStyle(fontSize: 10, color: Colors.grey[600]),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval:
                      maxValue > 10 ? (maxValue / 5).ceilToDouble() : 1,
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
                        width:
                            20, // Lebar bar disesuaikan agar tidak keluar box
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(7),
                          topRight: Radius.circular(7),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    final spots = assetTrendData;
    if (spots.isEmpty) {
      return Container(
        height: 250,
        child: Center(
            child: Text('No data available',
                style: TextStyle(color: Colors.grey[500]))),
      );
    }

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Asset Distribution Trend',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
              fontFamily: 'Maison Bold',
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: Colors.grey[100]!, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final categories =
                            categoryAnalytics.keys.take(6).toList();
                        if (value.toInt() >= categories.length)
                          return SizedBox.shrink();
                        String text = categories[value.toInt()];
                        return Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            text.length > 6
                                ? '${text.substring(0, 6)}...'
                                : text,
                            style: TextStyle(
                                fontSize: 10, color: Colors.grey[600]),
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
                          style:
                              TextStyle(fontSize: 10, color: Colors.grey[600]),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: spots.length.toDouble() - 1,
                minY: 0,
                maxY: spots
                        .map((spot) => spot.y)
                        .reduce((a, b) => a > b ? a : b) *
                    1.2,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: primaryColor,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                        radius: 4,
                        color: primaryColor,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: primaryColor.withOpacity(0.1),
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

  Widget _buildAgingDistributionDepartmentChart() {
    Map<String, List<double>> deptAgingMap = {};
    for (var asset in widget.assets) {
      final department =
          asset.department.isNotEmpty ? asset.department : 'Unassigned';
      double? agingValue =
          double.tryParse(asset.aging.replaceAll(RegExp("[^0-9.]"), ""));
      if (agingValue != null) {
        deptAgingMap.putIfAbsent(department, () => []).add(agingValue);
      }
    }
    Map<String, double> deptAgingAvg = {};
    deptAgingMap.forEach((key, value) {
      deptAgingAvg[key] =
          value.isEmpty ? 0 : value.reduce((a, b) => a + b) / value.length;
    });

    if (deptAgingAvg.isEmpty) {
      return Container(
        height: 170,
        child: Center(
            child: Text('No aging department data available',
                style: TextStyle(color: Colors.grey[500]))),
      );
    }

    List<MapEntry<String, double>> entries = deptAgingAvg.entries.toList();
    List<MapEntry<String, double>> visibleEntries = entries.take(8).toList();
    int othersCount = entries.length - visibleEntries.length;
    if (entries.length > 8) {
      double sumOthers = entries.skip(8).fold(0, (sum, e) => sum + e.value);
      double avgOthers = othersCount > 0 ? sumOthers / othersCount : 0;
      visibleEntries.add(MapEntry('Others', avgOthers));
    }
    // final maxValue = visibleEntries.isNotEmpty ? visibleEntries.first.value : 1;

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(20),
      
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Asset Analytics',
          style: TextStyle(
            fontFamily: 'Maison Bold',
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPieChart(),
            _buildLineChart(),
            _buildBarChart(categoryAnalytics, 'Category Distribution'),
            _buildBarChart(departmentAnalytics, 'Department Distribution'),
            _buildBarChart(agingAnalytics, 'Aging Distribution'),
            _buildAgingDistributionDepartmentChart(),
          ],
        ),
      ),
    );
  }
}
