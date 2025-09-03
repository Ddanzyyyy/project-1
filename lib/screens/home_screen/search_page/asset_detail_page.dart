import 'package:flutter/material.dart';
import 'asset_model.dart';

class AssetDetailPage extends StatelessWidget {
  final AssetModel asset;

  const AssetDetailPage({Key? key, required this.asset}) : super(key: key);

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'registered': return Colors.green;
      case 'unscanned': return Colors.orange;
      case 'damage': return Colors.red;
      case 'lost': return Colors.grey;
      default: return Colors.blueGrey;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'registered': return Icons.check_circle;
      case 'unscanned': return Icons.qr_code_scanner;
      case 'damage': return Icons.warning_rounded;
      case 'lost': return Icons.help_outline;
      default: return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(asset.name),
        backgroundColor: getStatusColor(asset.status),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                asset.imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(asset.imageUrl, height: 120, width: 120, fit: BoxFit.cover))
                  : Icon(Icons.inventory_2_rounded, color: getStatusColor(asset.status), size: 80),
                const SizedBox(height: 16),
                Text(asset.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text(asset.code, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 20, color: Colors.blueGrey),
                    const SizedBox(width: 6),
                    Text(asset.location, style: TextStyle(fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 6),
                if (asset.category != null)
                  Text('Category: ${asset.category}', style: TextStyle(fontSize: 14)),
                if (asset.division.isNotEmpty)
                  Text('Division: ${asset.division}', style: TextStyle(fontSize: 14)),
                if (asset.pic != null)
                  Text('PIC: ${asset.pic}', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(getStatusIcon(asset.status), color: getStatusColor(asset.status), size: 28),
                    const SizedBox(width: 8),
                    Text(asset.status.toUpperCase(), style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: getStatusColor(asset.status),
                      fontSize: 18,
                    )),
                  ],
                ),
                if (asset.description != null && asset.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top:12),
                    child: Text(asset.description!, style: TextStyle(fontSize: 14)),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}