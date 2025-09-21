import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:Simba/screens/NoImplementedHere/damaged_assets/damage_report_service.dart';

class DamageReportForm extends StatefulWidget {
  final String assetId;
  const DamageReportForm({required this.assetId, Key? key}) : super(key: key);

  @override
  State<DamageReportForm> createState() => _DamageReportFormState();
}

class _DamageReportFormState extends State<DamageReportForm> {
  final descController = TextEditingController();
  String status = 'rusak ringan';
  XFile? imageFile;
  bool isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => imageFile = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 410),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.09),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 22),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF405189).withOpacity(0.08),
                        Color(0xFF405189).withOpacity(0.04),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Color(0xFF405189).withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/icons/damaged_page/warning.png',
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Form Laporan Kerusakan',
                              style: TextStyle(
                                fontFamily: 'Maison Bold',
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Color(0xFF405189),
                                letterSpacing: 0.2,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Laporkan kerusakan asset dengan detail',
                              style: TextStyle(
                                fontFamily: 'Maison Book',
                                fontSize: 12,
                                color: Color(0xFF405189).withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Status Dropdown
                const Text(
                  'Status Kerusakan',
                  style: TextStyle(
                    fontFamily: 'Maison Bold',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF405189),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField<String>(
                    value: status,
                    items: [
                      DropdownMenuItem(
                        value: 'rusak ringan',
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text('Rusak Ringan',
                                style: TextStyle(fontFamily: 'Maison Book')),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'rusak berat',
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text('Rusak Berat',
                                style: TextStyle(fontFamily: 'Maison Book')),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'butuh perbaikan',
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text('Butuh Perbaikan',
                                style: TextStyle(fontFamily: 'Maison Book')),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (val) =>
                        setState(() => status = val ?? 'rusak ringan'),
                    decoration: InputDecoration(
                      fillColor: Color(0xFFF8F9FA),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Color(0xFF405189), width: 2),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: Color(0xFF405189)),
                  ),
                ),
                const SizedBox(height: 20),

                // Deskripsi Kerusakan
                const Text(
                  'Deskripsi Kerusakan',
                  style: TextStyle(
                    fontFamily: 'Maison Bold',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF405189),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: descController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText:
                          'Jelaskan secara detail kondisi kerusakan asset yang ditemukan...',
                      hintStyle: TextStyle(
                        fontFamily: 'Maison Book',
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      fillColor: Color(0xFFF8F9FA),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Color(0xFF405189), width: 2),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    style: const TextStyle(fontFamily: 'Maison Book', fontSize: 14),
                  ),
                ),
                const SizedBox(height: 20),

                // Foto Kerusakan
                const Text(
                  'Foto Kerusakan',
                  style: TextStyle(
                    fontFamily: 'Maison Bold',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF405189),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: imageFile != null ? null : 60,
                    decoration: BoxDecoration(
                      color: Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: imageFile != null
                        ? Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color:
                                            Color(0xFF405189).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.check_circle,
                                          color: Color(0xFF405189), size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Foto berhasil dipilih',
                                      style: TextStyle(
                                        fontFamily: 'Maison Bold',
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF405189),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                                child: Image.file(
                                  File(imageFile!.path),
                                  height: 140,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/icons/damaged_page/camera.png',
                                width: 28,
                                height: 28,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Upload foto kerusakan',
                                style: TextStyle(
                                  fontFamily: 'Maison Book',
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF405189),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 32),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          // Removed boxShadow
                        ),
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text(
                            'Batal',
                            style: TextStyle(
                              fontFamily: 'Maison Bold',
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          // Removed boxShadow
                        ),
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  setState(() => isLoading = true);
                                  final imageUrl =
                                      await DamageReportService.uploadImage(
                                          imageFile);
                                  final success = await DamageReportService
                                      .createDamageReport(
                                    assetId: widget.assetId,
                                    description: descController.text,
                                    status: status,
                                    imageUrl: imageUrl,
                                  );
                                  if (!success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                            'Gagal mengirim laporan kerusakan'),
                                        backgroundColor: Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    );
                                  }
                                  setState(() => isLoading = false);
                                  Navigator.pop(context, true);
                                },
                          child: isLoading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                            Color(0xFF405189)),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    ShaderMask(
                                      shaderCallback: (Rect bounds) {
                                        return LinearGradient(
                                          colors: [Color(0xFF405189), Color(0xFF405189)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ).createShader(bounds);
                                      },
                                      child: const Text(
                                        'Mengirim...',
                                        style: TextStyle(
                                          fontFamily: 'Maison Bold',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: Colors.white, // This will be masked by the gradient
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    SizedBox(width: 8),
                                    Text(
                                      'Kirim Laporan',
                                      style: TextStyle(
                                        fontFamily: 'Maison Bold',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF405189),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}