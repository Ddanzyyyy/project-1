import 'package:flutter/material.dart';

class StatusAndNotesCard extends StatelessWidget {
  final String selectedStatus;
  final List<Map<String, dynamic>> statusOptions;
  final TextEditingController notesController;
  final Function(String) onStatusChanged;

  const StatusAndNotesCard({
    super.key,
    required this.selectedStatus,
    required this.statusOptions,
    required this.notesController,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment_outlined, color: Color(0xFF405189), size: 20),
              SizedBox(width: 8),
              Text('Status & Catatan Sementara', style: TextStyle(fontFamily: 'MaisonBold', fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF405189))),
            ],
          ),
          SizedBox(height: 8),
          Text('Isi status dan catatan, lalu scan asset untuk menyimpan ke database', style: TextStyle(fontFamily: 'MaisonBook', fontSize: 12, color: Colors.grey[600])),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedStatus,
                isExpanded: true,
                items: statusOptions.map((status) {
                  return DropdownMenuItem<String>(
                    value: status['value'],
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(color: status['color'], shape: BoxShape.circle),
                        ),
                        SizedBox(width: 8),
                        Text(status['label'], style: TextStyle(fontFamily: 'MaisonBook', fontSize: 14, color: Colors.grey[800])),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) onStatusChanged(newValue);
                },
              ),
            ),
          ),
          SizedBox(height: 16),
          Text('Catatan', style: TextStyle(fontFamily: 'MaisonBold', fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF405189))),
          SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
            child: TextField(
              controller: notesController,
              maxLines: 3,
              style: TextStyle(fontFamily: 'MaisonBook', fontSize: 14, color: Colors.grey[800]),
              decoration: InputDecoration(
                hintText: 'Tambahkan catatan untuk asset ini...',
                hintStyle: TextStyle(fontFamily: 'MaisonBook', fontSize: 14, color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}