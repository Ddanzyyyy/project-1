import 'package:Simba/screens/home_screen/lost_assets/lost_asset_detail.dart';
import 'package:Simba/screens/home_screen/lost_assets/lost_asset_form.dart';
import 'package:Simba/screens/home_screen/lost_assets/lost_asset_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'lost_asset_service.dart';
// import 'lost_asset_form.dart';
// import 'lost_asset_detail.dart';

const primaryColor = Color(0xFF405189);
const secondaryColor = Color(0xFFF8F9FA);
const accentColor = Color(0xFFE9ECEF);

class LostAssetPage extends StatefulWidget {
  @override
  State<LostAssetPage> createState() => _LostAssetPageState();
}

class _LostAssetPageState extends State<LostAssetPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<Map<String, dynamic>> lostAssets = [];
  bool loading = true;
  final service = LostAssetService();
  String currentUser = 'Unknown';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _loadCurrentUser();
    fetchLostAssets();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUser = prefs.getString('username') ?? 'Unknown';
    });
  }

  Future<void> fetchLostAssets() async {
    setState(() => loading = true);
    try {
      final data = await service.fetchLostAssets();
      setState(() {
        lostAssets = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal mengambil data aset hilang: $e',
              style: TextStyle(fontFamily: 'Inter'))));
    }
  }

  void openReportForm() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => ReportLostAssetForm(
        service: service,
        currentUser: currentUser,
        onAssetReported: () {
          fetchLostAssets();
        },
      ),
    );
  }

  Future<void> _refreshAssets() async {
    await fetchLostAssets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        toolbarHeight: 56,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Lost Assets',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
            fontFamily: 'Inter',
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 12, top: 8, bottom: 8),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${lostAssets.length}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Header Section
            Container(
              color: primaryColor,
              child: Padding(
                padding: EdgeInsets.fromLTRB(12, 8, 12, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Daftar Aset Hilang',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.add_circle_outline,
                          size: 16, color: primaryColor),
                      label: Text('Laporkan',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: primaryColor)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: primaryColor,
                        padding:
                            EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: openReportForm,
                    ),
                  ],
                ),
              ),
            ),
            // Lost Asset List
            Expanded(
              child: RefreshIndicator(
                color: primaryColor,
                onRefresh: _refreshAssets,
                child: loading
                    ? ListView.builder(
                        padding: EdgeInsets.all(12),
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              height: 70,
                              width: double.infinity,
                            ),
                          );
                        },
                      )
                    : lostAssets.isEmpty
                        ? ListView(
                            physics: AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(height: 100),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.inventory_2_outlined,
                                        size: 48, color: Colors.grey[400]),
                                    SizedBox(height: 12),
                                    Text(
                                      'No lost assets found',
                                      style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'Try reporting lost assets!',
                                      style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 13,
                                          color: Colors.grey[500]),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            physics: AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.all(12),
                            itemCount: lostAssets.length,
                            itemBuilder: (context, index) {
                              final asset = lostAssets[index];
                              return Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: CompactLostAssetCard(
                                  asset: asset,
                                  onTap: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LostAssetDetailPage(
                                          asset: asset,
                                          service: service,
                                          currentUser: currentUser,
                                        ),
                                      ),
                                    );
                                    if (result == 'found') {
                                      await fetchLostAssets();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Aset berhasil dipindahkan ke daftar aktif.',
                                            style: TextStyle(fontFamily: 'Inter'),
                                          ),
                                          backgroundColor: Colors.blue,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: ElevatedButton.icon(
        icon: Icon(Icons.add, size: 18),
        label: Text('Laporkan Hilang',
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
        ),
        onPressed: openReportForm,
      ),
    );
  }
}

class CompactLostAssetCard extends StatelessWidget {
  final Map asset;
  final VoidCallback onTap;

  const CompactLostAssetCard({
    Key? key,
    required this.asset,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String assetImageUrl = (asset['image_path'] != null &&
            asset['image_path'].toString().isNotEmpty)
        ? (asset['image_path'].toString().startsWith('http')
            ? asset['image_path']
            : 'http://192.168.8.138:8000/storage/' + asset['image_path'])
        : '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              // Lost Asset Image (Dari Registered Asset)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: assetImageUrl.isNotEmpty
                      ? Image.network(
                          assetImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.inventory_2_outlined,
                              color: primaryColor,
                              size: 24,
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                color: primaryColor,
                                strokeWidth: 2,
                              ),
                            );
                          },
                        )
                      : Icon(
                          Icons.inventory_2_outlined,
                          color: primaryColor,
                          size: 24,
                        ),
                ),
              ),
              SizedBox(width: 12),

              // Asset Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset['name'] ?? '-',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        asset['category'] ?? "-",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          color: primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      asset['location'] ?? '-',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.grey[600],
                        fontSize: 11,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Date & Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    asset['lost_date'] != null
                        ? _formatDate(asset['lost_date'])
                        : '-',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: Colors.red.shade400,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Lost',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          color: Colors.red[700],
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}