// import 'package:Simba/screens/home_screen/lost_assets/lost_asset.dart';
import 'package:Simba/screens/home_screen/lost_assets/lost_asset_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ReportLostAssetForm extends StatefulWidget {
  final LostAssetService service;
  final String currentUser;
  final VoidCallback onAssetReported;

  ReportLostAssetForm({
    required this.service,
    required this.currentUser,
    required this.onAssetReported,
  });

  @override
  State<ReportLostAssetForm> createState() => _ReportLostAssetFormState();
}

class _ReportLostAssetFormState extends State<ReportLostAssetForm> {
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> reportableAssets = [];
  int? selectedAssetId;
  String penyebab = 'Dicuri', kronologi = '';
  File? bukti;
  bool loading = false;
  bool loadingAssets = true;

  // Improved color scheme
  static const Color primaryColor = Color(0xFF2B4C7E);
  static const Color secondaryColor = Color(0xFFF8FAFC);
  static const Color accentColor = Color(0xFFE2E8F0);
  static const Color successColor = Color(0xFF059669);
  static const Color errorColor = Color(0xFFDC2626);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    fetchReportableAssets();
  }

  Future fetchReportableAssets() async {
    try {
      final data = await widget.service.fetchReportableAssets();
      setState(() {
        reportableAssets = data;
        loadingAssets = false;
      });
    } catch (e) {
      setState(() => loadingAssets = false);
    }
  }

  Future pickBukti() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => bukti = File(picked.path));
  }

  Future submit() async {
    if (!_formKey.currentState!.validate() || selectedAssetId == null) return;
    setState(() => loading = true);

    final success = await widget.service.reportAssetLost(
      assetId: selectedAssetId!,
      lostCause: penyebab,
      lostChronology: kronologi,
      lostEvidence: bukti,
      reportedBy: widget.currentUser,
    );

    setState(() => loading = false);

    if (success) {
      widget.onAssetReported();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: successColor,
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Aset berhasil dilaporkan hilang',
                  style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: errorColor,
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Gagal melaporkan aset', 
                  style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12, bottom: 8),
            width: 50,
            height: 4,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          Flexible(
            child: Padding(
              padding: EdgeInsets.only(
                top: 12,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: loadingAssets
                    ? _buildLoadingState()
                    : _buildForm(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 250,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: primaryColor,
              strokeWidth: 3,
            ),
            SizedBox(height: 16),
            Text(
              'Memuat data aset...',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                color: textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 24),
          _buildAssetDropdown(),
          SizedBox(height: 16),
          _buildCauseDropdown(),
          SizedBox(height: 16),
          _buildChronologyField(),
          SizedBox(height: 16),
          _buildEvidenceUpload(),
          SizedBox(height: 24),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.report_problem_outlined,
                color: primaryColor,
                size: 24,
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lapor Kehilangan Aset',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Laporkan aset yang hilang dengan detail lengkap',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAssetDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Aset yang Hilang'),
        SizedBox(height: 8),
        DropdownButtonFormField<int>(
          decoration: _buildInputDecoration('Pilih aset yang dilaporkan hilang'),
          hint: Text(
            'Pilih aset yang hilang',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: textSecondary,
            ),
          ),
          value: selectedAssetId,
          icon: Icon(Icons.keyboard_arrow_down, color: textSecondary),
          items: reportableAssets
              .map<DropdownMenuItem<int>>(
                (asset) => DropdownMenuItem<int>(
                  value: asset['id'] as int,
                  child: Text(
                    '${asset['name']} (${asset['asset_code']})',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: textPrimary,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => selectedAssetId = v),
          validator: (v) => v == null ? 'Pilih aset terlebih dahulu' : null,
        ),
      ],
    );
  }

  Widget _buildCauseDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Penyebab Kehilangan'),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: penyebab,
          decoration: _buildInputDecoration('Pilih penyebab kehilangan aset'),
          icon: Icon(Icons.keyboard_arrow_down, color: textSecondary),
          items: [
            'Dicuri',
            'Kelalaian',
            'Tidak diketahui',
            'Bencana Alam'
          ]
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: textPrimary,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: (v) => setState(() => penyebab = v!),
        ),
      ],
    );
  }

  Widget _buildChronologyField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Kronologi Kejadian'),
        SizedBox(height: 8),
        TextFormField(
          decoration: _buildInputDecoration(
            'Jelaskan secara detail',
          ),
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: textPrimary,
          ),
          maxLines: 3,
          validator: (v) => v!.isEmpty ? 'Kronologi wajib diisi' : null,
          onChanged: (v) => kronologi = v,
        ),
      ],
    );
  }

  Widget _buildEvidenceUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Bukti Pendukung'),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: secondaryColor,
            border: Border.all(color: borderColor, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              if (bukti != null) ...[
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: successColor, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Bukti berhasil diupload',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: successColor,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() => bukti = null),
                        child: Text(
                          'Hapus',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: errorColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
              ],
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: bukti != null ? accentColor : primaryColor,
                  foregroundColor: bukti != null ? textPrimary : Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: Icon(
                  bukti != null ? Icons.refresh : Icons.upload_file,
                  size: 18,
                ),
                label: Text(
                  bukti != null ? 'Ganti Bukti' : 'Upload Bukti',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: pickBukti,
              ),
              if (bukti == null) ...[
                SizedBox(height: 8),
                Text(
                  'Format: JPG, PNG (Maks. 5MB)',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return loading
        ? Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Melaporkan...',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          )
        : SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: submit,
              child: Text(
                'Laporkan Kehilangan',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: textSecondary,
      ),
      filled: true,
      fillColor: secondaryColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: errorColor, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: errorColor, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}