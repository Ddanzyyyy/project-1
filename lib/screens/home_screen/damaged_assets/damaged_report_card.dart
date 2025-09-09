import 'package:Simba/screens/home_screen/damaged_assets/damaged_status_form.dart';
import 'package:flutter/material.dart';
import 'package:Simba/screens/home_screen/damaged_assets/damage_report_model.dart';
import 'package:Simba/screens/home_screen/damaged_assets/detail_damage_laporan.dart';
import 'package:Simba/screens/home_screen/damaged_assets/damage_report_service.dart';

class DamageReportCard extends StatelessWidget {
  final DamageReport report;
  final Future<void> Function()? onEdit;
  final Future<void> Function()? onDelete;

  const DamageReportCard({
    Key? key,
    required this.report,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      elevation: 0,
      color: Colors.white,
      margin: EdgeInsets.only(bottom: 18),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailLaporanDamagePage(report: report),
            ),
          );
        },
        borderRadius: BorderRadius.circular(13),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (report.imageUrl != null && report.imageUrl!.isNotEmpty)
                    GestureDetector(
                      onTap: () => _showFullImage(context, report.imageUrl!),
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Color(0xFF405189).withOpacity(0.09),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(9),
                          child: Image.network(report.imageUrl!, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.status,
                          style: TextStyle(
                            fontFamily: 'Maison Bold',
                            color: _colorStatus(report.status),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          report.description,
                          style: TextStyle(
                            fontFamily: 'Maison Book',
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Dilaporkan: ${report.dateReported}',
                          style: TextStyle(
                            fontFamily: 'Maison Book',
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Tombol Edit & Hapus
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit_outlined, color: Color(0xFF405189), size: 22),
                        tooltip: 'Update Status',
                        onPressed: () async {
                          await showDialog(
                            context: context,
                            builder: (context) => DamageStatusForm(report: report),
                          );
                          if (onEdit != null) await onEdit!();
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.red, size: 22),
                        tooltip: 'Hapus Laporan',
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text('Hapus Laporan', style: TextStyle(fontFamily: 'Maison Bold', color: Color(0xFF405189))),
                              content: Text('Yakin ingin menghapus laporan kerusakan ini?', style: TextStyle(fontFamily: 'Maison Book')),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text('Batal', style: TextStyle(fontFamily: 'Maison Book', color: Colors.grey[600])),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: Text('Hapus', style: TextStyle(fontFamily: 'Maison Bold', color: Colors.white)),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            final success = await DamageReportService.deleteDamageReport(report.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(success ? 'Laporan berhasil dihapus' : 'Gagal menghapus laporan',
                                  style: TextStyle(fontFamily: 'Maison Book')),
                                backgroundColor: success ? Colors.green : Colors.red,
                              ),
                            );
                            if (onDelete != null) await onDelete!(); // Aman reload dari parent
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              if (report.repairHistory.isNotEmpty) ...[
                SizedBox(height: 12),
                Divider(thickness: 0.7, color: Color(0xFFE7E9F0)),
                Padding(
                  padding: EdgeInsets.only(top: 5, bottom: 6),
                  child: Text(
                    'Riwayat Perbaikan:',
                    style: TextStyle(
                      fontFamily: 'Maison Bold',
                      color: Color(0xFF405189),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                ...report.repairHistory.map((rh) => ListTile(
                      leading: rh.imageUrl != null && rh.imageUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(rh.imageUrl!, width: 32, height: 32, fit: BoxFit.cover),
                            )
                          : Icon(Icons.build, color: Color(0xFF405189)),
                      title: Text(
                        rh.action,
                        style: TextStyle(fontFamily: 'Maison Book', fontWeight: FontWeight.w500, fontSize: 13),
                      ),
                      subtitle: Text(
                        '${rh.dateRepaired}${rh.notes != null && rh.notes!.isNotEmpty ? ' - ${rh.notes}' : ''}',
                        style: TextStyle(fontFamily: 'Maison Book', fontSize: 12, color: Colors.grey[600]),
                      ),
                    )),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Color _colorStatus(String status) {
    switch (status) {
      case "rusak berat":
        return Color(0xFFD90429);
      case "rusak ringan":
        return Color(0xFFF7B801);
      case "butuh perbaikan":
        return Color(0xFF405189);
      case "damaged":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(12),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.7,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Icon(Icons.broken_image, color: Colors.white, size: 48),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}