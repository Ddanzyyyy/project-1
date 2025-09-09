import 'package:flutter/material.dart';
import 'package:Simba/screens/home_screen/damaged_assets/damage_report_model.dart';
import 'package:Simba/screens/home_screen/damaged_assets/damage_report_service.dart';

class DamageStatusForm extends StatefulWidget {
  final DamageReport report;
  const DamageStatusForm({required this.report, Key? key}) : super(key: key);

  @override
  State<DamageStatusForm> createState() => _DamageStatusFormState();
}

class _DamageStatusFormState extends State<DamageStatusForm> {
  String status = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    status = widget.report.status;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 20,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFF405189).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.edit, color: Color(0xFF405189), size: 26),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Update Status Kerusakan',
                      style: TextStyle(
                        fontFamily: 'Maison Bold',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF405189),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: status,
                items: [
                  DropdownMenuItem(value: 'rusak ringan', child: Text('Rusak Ringan', style: TextStyle(fontFamily: 'Maison Book'))),
                  DropdownMenuItem(value: 'rusak berat', child: Text('Rusak Berat', style: TextStyle(fontFamily: 'Maison Book'))),
                  DropdownMenuItem(value: 'butuh perbaikan', child: Text('Butuh Perbaikan', style: TextStyle(fontFamily: 'Maison Book'))),
                ],
                onChanged: (val) => setState(() => status = val ?? status),
                decoration: InputDecoration(
                  labelText: 'Status Kerusakan',
                  labelStyle: TextStyle(fontFamily: 'Maison Bold', fontWeight: FontWeight.w600, color: Color(0xFF405189)),
                  fillColor: Color(0xFFF6F7FB),
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('Batal', style: TextStyle(fontFamily: 'Maison Bold', fontWeight: FontWeight.w700, color: Colors.grey[600])),
                  ),
                  SizedBox(width: 14),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            setState(() => isLoading = true);
                            await DamageReportService.updateDamageReportStatus(widget.report.id, status);
                            setState(() => isLoading = false);
                            Navigator.pop(context, true);
                          },
                    child: isLoading
                        ? SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            child: Text('Update', style: TextStyle(fontFamily: 'Maison Bold', fontWeight: FontWeight.w700, fontSize: 15)),
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF405189),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
}