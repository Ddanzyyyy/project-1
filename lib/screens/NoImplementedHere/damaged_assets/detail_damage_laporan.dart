import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Simba/screens/NoImplementedHere/damaged_assets/damage_report_model.dart';
import 'package:Simba/screens/NoImplementedHere/damaged_assets/damage_report_service.dart';

class DetailLaporanDamagePage extends StatefulWidget {
  final DamageReport report;

  const DetailLaporanDamagePage({
    Key? key,
    required this.report,
  }) : super(key: key);

  @override
  State<DetailLaporanDamagePage> createState() => _DetailLaporanDamagePageState();
}

class _DetailLaporanDamagePageState extends State<DetailLaporanDamagePage> {
  late DamageReport report;
  List<XFile> selectedImages = [];
  bool isLoading = false;
  bool isRefreshing = false;
  final notesController = TextEditingController();

  int _carouselIndex = 0;

  @override
  void initState() {
    super.initState();
    report = widget.report;
  }

  Future<void> _pickMultipleImages() async {
    final picker = ImagePicker();
    final pickedList = await picker.pickMultiImage();
    if (pickedList.isNotEmpty) {
      setState(() {
        selectedImages.addAll(pickedList);
      });
    }
  }

  void _showFullScreenImage(String imageUrl, List<String> allImages) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            PageView.builder(
              itemCount: allImages.length,
              controller: PageController(initialPage: allImages.indexOf(imageUrl)),
              itemBuilder: (context, index) {
                return Center(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 3.0,
                    child: Image.network(
                      allImages[index],
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image_outlined, size: 64, color: Colors.grey[400]),
                            SizedBox(height: 16),
                            Text('Gambar tidak dapat dimuat', style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Maison Book')),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 50,
              right: 20,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.5),
                  shape: CircleBorder(),
                ),
              ),
            ),
            if (allImages.length > 1)
              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: allImages.asMap().entries.map((entry) {
                    return Container(
                      width: 8,
                      height: 8,
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshReport() async {
    setState(() => isRefreshing = true);
    try {
      final latestReports = await DamageReportService.getDamageReports(assetId: report.assetId.toString());
      final found = latestReports.firstWhere((r) => r.id == report.id, orElse: () => report);
      setState(() {
        report = found;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal refresh laporan', style: TextStyle(fontFamily: 'Maison Book')),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
    setState(() => isRefreshing = false);
  }

  Future<void> _submitAdditionalImages() async {
    setState(() => isLoading = true);
    List<String> urls = [];
    for (var img in selectedImages) {
      final url = await DamageReportService.uploadImage(img);
      if (url != null && url.isNotEmpty) {
        urls.add(url);
      }
    }
    final success = await DamageReportService.addImagesToDamageReport(
      report.id,
      urls,
      notesController.text,
    );
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Foto tambahan berhasil diunggah', style: TextStyle(fontFamily: 'Maison Book')),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      setState(() {
        selectedImages.clear();
        notesController.clear();
      });
      await _refreshReport();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal upload foto tambahan', style: TextStyle(fontFamily: 'Maison Book')),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
    setState(() => isLoading = false);
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card Shimmer
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            SizedBox(height: 24),
            // Title Shimmer
            Container(
              width: 120,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: 16),
            // Image Carousel Shimmer
            Container(
              width: double.infinity,
              height: 280,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            SizedBox(height: 32),
            // Add Photos Section Shimmer
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> allImages = [
      if (report.imageUrl != null && report.imageUrl!.isNotEmpty) report.imageUrl!,
      ...report.additionalImages,
    ];

    final bool isPlaceholder = allImages.isEmpty;
    final List<String> displayImages = allImages.isNotEmpty
        ? allImages
        : ['assets/placeholder.png'];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF405189),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Detail Laporan Kerusakan',
          style: TextStyle(
            fontFamily: 'Maison Bold',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: const Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        iconTheme: IconThemeData(color: const Color.fromARGB(255, 255, 255, 255)),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            child: IconButton(
              icon: isRefreshing 
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(Icons.refresh_rounded, size: 24),
              onPressed: isRefreshing ? null : _refreshReport,
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF405189),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
      body: isRefreshing 
          ? _buildShimmerEffect()
          : RefreshIndicator(
              onRefresh: _refreshReport,
              color: Color(0xFF405189),
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status Badge
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _colorStatus(report.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _colorStatus(report.status).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _colorStatus(report.status),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  report.status.toUpperCase(),
                                  style: TextStyle(
                                    fontFamily: 'Maison Bold',
                                    color: _colorStatus(report.status),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                          // Description
                          Text(
                            'Deskripsi Kerusakan',
                            style: TextStyle(
                              fontFamily: 'Maison Bold',
                              fontSize: 14,
                              color: const Color(0xFF405189),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            report.description,
                            style: TextStyle(
                              fontFamily: 'Maison Book',
                              fontSize: 16,
                              color: Colors.grey[900],
                              fontWeight: FontWeight.w400,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: 16),
                          // Date
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.access_time_rounded, size: 16, color: Colors.grey[600]),
                                SizedBox(width: 6),
                                Text(
                                  'Dilaporkan ${report.dateReported}',
                                  style: TextStyle(
                                    fontFamily: 'Maison Book',
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    Text(
                      'Dokumentasi',
                      style: TextStyle(
                        fontFamily: 'Maison Bold',
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: const Color(0xFF405189),
                      ),
                    ),
                    SizedBox(height: 16),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          children: [
                            CarouselSlider(
                              items: displayImages.map(
                                (url) {
                                  if (isPlaceholder) {
                                    return Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(vertical: 24),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            url,
                                            height: 120,
                                            width: 120,
                                            fit: BoxFit.contain,
                                          ),
                                          SizedBox(height: 16),
                                          Text(
                                            'Belum ada dokumentasi gambar',
                                            style: TextStyle(
                                              fontFamily: 'Maison Bold',
                                              fontSize: 16,
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Silahkan upload gambar kerusakan',
                                            style: TextStyle(
                                              fontFamily: 'Maison Book',
                                              fontSize: 13,
                                              color: Colors.grey[400],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    return GestureDetector(
                                      onTap: () => _showFullScreenImage(url, displayImages),
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(16),
                                          child: Image.network(
                                            url,
                                            height: 280,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return Shimmer.fromColors(
                                                baseColor: Colors.grey[300]!,
                                                highlightColor: Colors.grey[100]!,
                                                child: Container(
                                                  height: 280,
                                                  color: Colors.white,
                                                ),
                                              );
                                            },
                                            errorBuilder: (context, error, stackTrace) => Container(
                                              height: 280,
                                              color: Colors.grey[100],
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.broken_image_outlined, size: 48, color: Colors.grey[400]),
                                                  SizedBox(height: 8),
                                                  Text('Gambar tidak dapat dimuat', style: TextStyle(color: Colors.grey[500], fontSize: 14, fontFamily: 'Maison Book')),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ).toList(),
                              options: CarouselOptions(
                                height: 280,
                                enlargeCenterPage: true,
                                enableInfiniteScroll: !isPlaceholder && displayImages.length > 1,
                                viewportFraction: 0.9,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    _carouselIndex = index;
                                  });
                                },
                              ),
                            ),
                            // Indicator bullets
                            if (!isPlaceholder && displayImages.length > 1)
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    displayImages.length,
                                    (idx) => AnimatedContainer(
                                      duration: Duration(milliseconds: 200),
                                      width: idx == _carouselIndex ? 24 : 8,
                                      height: 8,
                                      margin: EdgeInsets.symmetric(horizontal: 3),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: idx == _carouselIndex
                                            ? Color(0xFF405189)
                                            : Colors.grey[300],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            // CATATAN DOKUMENTASI
                            if (!isPlaceholder && report.additionalImagesNotes.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.only(top: 10, left: 6, right: 6, bottom: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Catatan Dokumentasi:',
                                      style: TextStyle(
                                        fontFamily: 'Maison Bold',
                                        color: Color(0xFF405189),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    ...report.additionalImagesNotes.map((note) => Padding(
                                          padding: const EdgeInsets.only(bottom: 5),
                                          child: Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                            decoration: BoxDecoration(
                                              color: Color(0xFF405189).withOpacity(0.05),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              note,
                                              style: TextStyle(
                                                fontFamily: 'Maison Book',
                                                fontSize: 13,
                                                color: Colors.grey[900],
                                              ),
                                            ),
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 32),

                    // Add Photos Section
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Color(0xFF405189).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.add_photo_alternate_outlined,
                                  color: Color(0xFF405189),
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tambah Dokumentasi',
                                      style: TextStyle(
                                        fontFamily: 'Maison Bold',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: const Color(0xFF405189),
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Upload foto kerusakan tambahan',
                                      style: TextStyle(
                                        fontFamily: 'Maison Book',
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          // Image Picker Button
                          GestureDetector(
                            onTap: _pickMultipleImages,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: selectedImages.isEmpty ? Colors.grey[300]! : Color(0xFF405189),
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                color: selectedImages.isEmpty ? Colors.grey[50] : Color(0xFF405189).withOpacity(0.05),
                              ),
                              child: Column(
                                children: [
                                  selectedImages.isEmpty
                                      ? Image.asset(
                                          'assets/images/icons/damaged_page/upload.png',
                                          width: 32,
                                          height: 32,
                                          fit: BoxFit.contain,
                                        )
                                      : 
                                  SizedBox(height: 8),
                                  Text(
                                    selectedImages.isEmpty
                                        ? 'Ketuk untuk pilih foto'
                                        : '${selectedImages.length} foto dipilih',
                                    style: TextStyle(
                                      fontFamily: 'Maison Book',
                                      fontSize: 14,
                                      color: selectedImages.isEmpty ? Colors.grey[600] : Color(0xFF405189),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Selected Images Preview
                          if (selectedImages.isNotEmpty) ...[
                            SizedBox(height: 16),
                            SizedBox(
                              height: 80,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: selectedImages.length,
                                separatorBuilder: (context, idx) => SizedBox(width: 12),
                                itemBuilder: (context, idx) {
                                  return Stack(
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.grey[200]!, width: 1),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(11),
                                          child: Image.file(
                                            File(selectedImages[idx].path),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedImages.removeAt(idx);
                                            });
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.1),
                                                  blurRadius: 4,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Icon(Icons.close, color: Colors.red, size: 16),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                          SizedBox(height: 16),
                          // Notes Input
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!, width: 1),
                            ),
                            child: TextField(
                              controller: notesController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: 'Tambahkan catatan (opsional)',
                                hintStyle: TextStyle(
                                  fontFamily: 'Maison Book',
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(16),
                              ),
                              style: TextStyle(
                                fontFamily: 'Maison Book',
                                fontSize: 14,
                                color: Colors.grey[900],
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          // Upload Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading || selectedImages.isEmpty ? null : _submitAdditionalImages,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF405189),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.grey[300],
                                disabledForegroundColor: Colors.grey[500],
                                elevation: 0,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: isLoading
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'Mengupload...',
                                          style: TextStyle(
                                            fontFamily: 'Maison Bold',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Text(
                                      'Upload Dokumentasi',
                                      style: TextStyle(
                                        fontFamily: 'Maison Bold',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
      default:
        return Colors.grey;
    }
  }
}