import 'package:Simba/screens/home_screen/damaged_assets/damaged_report_card.dart';
import 'package:flutter/material.dart';
import 'package:Simba/screens/home_screen/damaged_assets/damage_report_model.dart';


class DamageReportList extends StatelessWidget {
  final String assetId;
  final List<DamageReport> damageReports;
  final bool isLoadingReport;
  final Future<void> Function() reloadReports;

  const DamageReportList({
    Key? key,
    required this.assetId,
    required this.damageReports,
    required this.isLoadingReport,
    required this.reloadReports,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Laporan Kerusakan',
            style: TextStyle(
              fontFamily: 'Maison Bold',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF405189),
            ),
          ),
          SizedBox(height: 10),
          isLoadingReport
              ? Center(child: CircularProgressIndicator(color: Color(0xFF405189)))
              : damageReports.isEmpty
                  ? _emptyReport(context)
                  : Column(
                      children: [
                        for (int i = 0; i < damageReports.length; i++) ...[
                          DamageReportCard(
                            report: damageReports[i],
                            onEdit: reloadReports,
                            onDelete: reloadReports,
                          ),
                          if (i < damageReports.length - 1)
                            Divider(thickness: 1, color: Color(0xFFE7E9F0)),
                        ]
                      ],
                    ),
        ],
      ),
    );
  }

  Widget _emptyReport(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Image.asset(
              'assets/images/icons/damaged_page/warning_mail.png',
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 10),
            Text(
              'Tidak ada laporan kerusakan',
              style: TextStyle(
                fontFamily: 'Maison Bold',
                fontSize: 15,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Klik kanan atas untuk menambah laporan kerusakan',
              style: TextStyle(
                fontFamily: 'Maison Book',
                fontSize: 10,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}