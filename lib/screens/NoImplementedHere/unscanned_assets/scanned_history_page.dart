import 'package:flutter/material.dart';
import 'unscanned_asset_service.dart';
import 'asset_item.dart';

class ScannedHistoryPage extends StatefulWidget {
  final String auditId;
  const ScannedHistoryPage({Key? key, required this.auditId}) : super(key: key);

  @override
  State<ScannedHistoryPage> createState() => _ScannedHistoryPageState();
}

class _ScannedHistoryPageState extends State<ScannedHistoryPage> {
  List<AssetItem> scannedAssets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    setState(() => isLoading = true);
    try {
      scannedAssets = await UnscannedAssetService.fetchScannedHistory(auditId: widget.auditId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text('Gagal mengambil riwayat: $e'),
      ));
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Color(0xFF405189),
        title: Text('Riwayat Asset Terscan', style: TextStyle(fontFamily: 'Inter')),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF405189)))
          : scannedAssets.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 40, color: Color(0xFF405189)),
                      SizedBox(height: 12),
                      Text('Belum ada asset yang di-scan',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: Colors.grey[700])),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: scannedAssets.length,
                  itemBuilder: (context, idx) {
                    final asset = scannedAssets[idx];
                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: asset.image_path.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  asset.image_path.split(',')[0],
                                  width: 42,
                                  height: 42,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        width: 42,
                                        height: 42,
                                        color: Color(0xFF405189).withOpacity(0.1),
                                        child: Center(
                                          child: Icon(Icons.inventory_2_outlined, color: Color(0xFF405189), size: 20),
                                        ),
                                      ),
                                ),
                              )
                            : Container(
                                width: 42,
                                height: 42,
                                color: Color(0xFF405189).withOpacity(0.1),
                                child: Center(
                                  child: Icon(Icons.inventory_2_outlined, color: Color(0xFF405189), size: 20),
                                ),
                              ),
                        title: Text(asset.name, style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(asset.asset_code, style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.grey[700])),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF405189).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(asset.category, style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: Color(0xFF405189))),
                                ),
                                SizedBox(width: 8),
                                Text(asset.location, style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: Colors.grey[600])),
                              ],
                            ),
                          ],
                        ),
                        trailing: Icon(Icons.check_circle, color: Colors.green, size: 20),
                        onTap: () {
                          // Optional: buka detail asset jika perlu
                        },
                      ),
                    );
                  },
                ),
    );
  }
}