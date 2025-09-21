import 'package:flutter/material.dart';

class SavedStatusCard extends StatelessWidget {
  final Map<String, dynamic> savedTempStatus;
  final List<Map<String, dynamic>> statusOptions;
  const SavedStatusCard({super.key, required this.savedTempStatus, required this.statusOptions});

  Color _getStatusColor(String status) {
    final statusOption = statusOptions.firstWhere((option) => option['value'] == status, orElse: () => statusOptions[0]);
    return statusOption['color'] ?? Colors.grey[600]!;
  }

  String _getStatusLabel(String status) {
    final statusOption = statusOptions.firstWhere((option) => option['value'] == status, orElse: () => statusOptions[0]);
    return statusOption['label'] ?? 'Pending';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green[600], size: 20),
              SizedBox(width: 8),
              Text('Status Tersimpan', style: TextStyle(fontFamily: 'MaisonBold', fontSize: 16, fontWeight: FontWeight.w600, color: Colors.green[700])),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: _getStatusColor(savedTempStatus['temp_status'] ?? 'pending'), shape: BoxShape.circle)),
              SizedBox(width: 8),
              Text(_getStatusLabel(savedTempStatus['temp_status'] ?? 'pending'), style: TextStyle(fontFamily: 'MaisonBold', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[800])),
            ],
          ),
          if (savedTempStatus['notes'] != null && savedTempStatus['notes'].isNotEmpty) ...[
            SizedBox(height: 8),
            Text('Catatan:', style: TextStyle(fontFamily: 'MaisonBold', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[600])),
            SizedBox(height: 4),
            Text(savedTempStatus['notes'], style: TextStyle(fontFamily: 'MaisonBook', fontSize: 12, color: Colors.grey[700], height: 1.4)),
          ],
          SizedBox(height: 8),
          Text('Disimpan pada: ${savedTempStatus['created_at'] ?? 'Unknown'}', style: TextStyle(fontFamily: 'MaisonBook', fontSize: 10, color: Colors.grey[500])),
        ],
      ),
    );
  }
}