import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../model/recent_asset_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecentAssetDetailWidget extends StatefulWidget {
  final RecentAsset recentAsset;

  const RecentAssetDetailWidget({Key? key, required this.recentAsset}) : super(key: key);

  @override
  State<RecentAssetDetailWidget> createState() => _RecentAssetDetailWidgetState();
}

class _RecentAssetDetailWidgetState extends State<RecentAssetDetailWidget> {
  List<AssetPhoto> uploadedPhotos = [];
  bool isLoadingPhotos = false;
  late RecentAsset recentAsset;
  int _carouselIndex = 0;

  @override
  void initState() {
    super.initState();
    recentAsset = widget.recentAsset;
    _loadRecentAssetDetail();
  }

  Future<void> _loadRecentAssetDetail() async {
    setState(() {
      isLoadingPhotos = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.7:8000/api/recent-assets/${recentAsset.id}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final assetData = data['data'];
          
          setState(() {
            recentAsset = RecentAsset.fromJson(assetData);
          });

          if (assetData['photos'] != null) {
            final List<dynamic> photosData = assetData['photos'];
            setState(() {
              uploadedPhotos = photosData.map((photo) => AssetPhoto.fromJson(photo)).toList();
            });
          }
        }
      } else {
        print('Failed to load recent asset detail: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error loading recent asset detail: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat detail asset'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoadingPhotos = false;
      });
    }
  }

  Future<void> _updatePhotosCount() async {
    try {
      final response = await http.patch(
        Uri.parse('http://192.168.8.129:8000/api/recent-assets/${recentAsset.id}/photos-count'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          setState(() {
            recentAsset = recentAsset.copyWith(
              photosCount: data['data']['photos_count']
            );
          });
        }
      }
    } catch (e) {
      print('Error updating photos count: $e');
    }
  }

  void _showFullImageGallery(BuildContext context, int initialIndex) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => _FullImageGalleryDialog(
        photos: uploadedPhotos,
        initialIndex: initialIndex,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'available':
        return Colors.green;
      case 'inactive':
      case 'broken':
      case 'damaged':
        return Colors.orange;
      case 'disposed':
      case 'lost':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Color(0xFF405189),
        elevation: 0,
        title: Text(
          'Asset Detail',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            fontFamily: 'Maison Bold',
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () async {
              await _loadRecentAssetDetail();
              await _updatePhotosCount();
            },
            tooltip: 'Refresh data',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadRecentAssetDetail();
          await _updatePhotosCount();
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(7),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Color(0xFF405189).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            recentAsset.assetNo.length > 10 
                                ? recentAsset.assetNo.substring(0, 10) 
                                : recentAsset.assetNo,
                            style: TextStyle(
                              fontFamily: 'Maison Bold',
                              fontSize: 14,
                              color: Color(0xFF405189),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(recentAsset.status ?? '').withOpacity(0.1),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            recentAsset.status ?? 'UNKNOWN',
                            style: TextStyle(
                              fontFamily: 'Maison Bold',
                              fontSize: 12,
                              color: _getStatusColor(recentAsset.status ?? ''),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      recentAsset.title ?? recentAsset.assetNo,
                      style: TextStyle(
                        fontFamily: 'Maison Bold',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      recentAsset.assetSpecification ?? '',
                      style: TextStyle(
                        fontFamily: 'Maison Book',
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            '${recentAsset.photosCount} foto tersimpan',
                            style: TextStyle(
                              fontFamily: 'Maison Bold',
                              color: Colors.blue[800],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            '${uploadedPhotos.length} foto dimuat',
                            style: TextStyle(
                              fontFamily: 'Maison Bold',
                              color: Colors.green[800],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // Uploaded Photos Section with CarouselSlider
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(7),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Foto Asset',
                          style: TextStyle(
                            fontFamily: 'Maison Bold',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF405189),
                          ),
                        ),
                        Spacer(),
                        if (isLoadingPhotos)
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF405189),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 16),

                    if (isLoadingPhotos && uploadedPhotos.isEmpty)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              CircularProgressIndicator(color: Color(0xFF405189)),
                              SizedBox(height: 16),
                              Text(
                                'Memuat foto...',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontFamily: 'Maison Book',
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (uploadedPhotos.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.photo_library_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Belum ada foto untuk asset ini',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                                fontFamily: 'Maison Bold',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Foto yang diupload akan muncul di sini',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                                fontFamily: 'Maison Book',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        children: [
                          CarouselSlider.builder(
                            itemCount: uploadedPhotos.length,
                            options: CarouselOptions(
                              height: 230,
                              viewportFraction: 0.85,
                              enlargeCenterPage: true,
                              enableInfiniteScroll: uploadedPhotos.length > 1,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _carouselIndex = index;
                                });
                              },
                            ),
                            itemBuilder: (context, index, realIdx) {
                              final photo = uploadedPhotos[index];
                              return GestureDetector(
                                onTap: () => _showFullImageGallery(context, index),
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.grey[200]!),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 6,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.network(
                                          photo.fileUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Center(
                                              child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                                            );
                                          },
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress.expectedTotalBytes != null
                                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                    : null,
                                                color: Color(0xFF405189),
                                              ),
                                            );
                                          },
                                        ),
                                        // Tidak ada fileName di gambar
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                            padding: EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.45),
                                              borderRadius: BorderRadius.vertical(
                                                bottom: Radius.circular(16),
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (photo.uploadedAt != null)
                                                  Text(
                                                    DateFormat('dd/MM/yyyy HH:mm').format(photo.uploadedAt!),
                                                    style: TextStyle(
                                                      color: Colors.white.withOpacity(0.8),
                                                      fontSize: 12,
                                                      fontFamily: 'Maison Book',
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(uploadedPhotos.length, (idx) {
                              return AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                margin: EdgeInsets.symmetric(horizontal: 4),
                                width: _carouselIndex == idx ? 18 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _carouselIndex == idx ? Color(0xFF405189) : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              );
                            }),
                          ),
                          SizedBox(height: 4),
                          if (uploadedPhotos[_carouselIndex].description != null &&
                              uploadedPhotos[_carouselIndex].description!.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 6),
                              child: Text(
                                uploadedPhotos[_carouselIndex].description!,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Maison Book',
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              _buildInfoCard('Full Information', [
                _buildInfoRow('Title', recentAsset.title),
                _buildInfoRow('Asset No', recentAsset.assetNo),
                _buildInfoRow('General Account', recentAsset.generalAccount),
                _buildInfoRow('Category', recentAsset.category),
                _buildInfoRow('Sub Category', recentAsset.subCategory),
                _buildInfoRow('Subsidiary Account', recentAsset.subsidiaryAccount),
                _buildInfoRow('Asset Specification', recentAsset.assetSpecification),
                _buildInfoRow(
                  'Acquisition Date',
                  recentAsset.acquisitionDate != null
                      ? DateFormat('dd MMM yyyy').format(recentAsset.acquisitionDate!)
                      : '-',
                ),
                _buildInfoRow('Aging', recentAsset.aging),
                _buildInfoRow('Quantity', recentAsset.quantity?.toString() ?? '1'),
                _buildInfoRow('Department', recentAsset.department),
                _buildInfoRow('Control Department', recentAsset.controlDepartment),
                _buildInfoRow('Cost Center', recentAsset.costCenter),
                _buildInfoRow('Asset Status', recentAsset.status),
                _buildInfoRow('Remarks', recentAsset.remarks?.isNotEmpty == true ? recentAsset.remarks! : '-'),
                _buildInfoRow('Photos Count', recentAsset.photosCount.toString()),
              ]),

              SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(7),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status Summary',
                      style: TextStyle(
                        fontFamily: 'Maison Bold',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF405189),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatusCard('Available', recentAsset.available, Colors.green),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildStatusCard('Broken', recentAsset.broken, Colors.orange),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildStatusCard('Lost', recentAsset.lost, Colors.red),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Maison Bold',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF405189),
            ),
          ),
          SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Maison Bold',
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            ': ',
            style: TextStyle(
              fontFamily: 'Maison Book',
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          Expanded(
            child: Text(
              value?.isNotEmpty == true ? value! : '-',
              style: TextStyle(
                fontFamily: 'Maison Book',
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String label, int count, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          count == 1
              ? Icon(
                  Icons.done,
                  color: color,
                  size: 30,
                )
              : Text(
                  count.toString(),
                  style: TextStyle(
                    fontFamily: 'Maison Bold',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Maison Bold',
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class AssetPhoto {
  final String fileUrl;
  final String? fileName;
  final DateTime? uploadedAt;
  final String? description;

  AssetPhoto({
    required this.fileUrl,
    this.fileName,
    this.uploadedAt,
    this.description,
  });

  factory AssetPhoto.fromJson(Map<String, dynamic> json) {
    return AssetPhoto(
      fileUrl: json['file_url'] ?? json['url'] ?? '',
      fileName: json['file_name'] ?? json['name'] ?? json['filename'],
      uploadedAt: json['uploaded_at'] != null 
          ? DateTime.tryParse(json['uploaded_at'])
          : json['created_at'] != null 
              ? DateTime.tryParse(json['created_at'])
              : null,
      description: json['description'],
    );
  }
}

class _FullImageGalleryDialog extends StatefulWidget {
  final List<AssetPhoto> photos;
  final int initialIndex;

  const _FullImageGalleryDialog({
    Key? key,
    required this.photos,
    required this.initialIndex,
  }) : super(key: key);

  @override
  State<_FullImageGalleryDialog> createState() => _FullImageGalleryDialogState();
}

class _FullImageGalleryDialogState extends State<_FullImageGalleryDialog> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  void _nextImage() {
    setState(() {
      currentIndex = (currentIndex + 1) % widget.photos.length;
    });
  }

  void _prevImage() {
    setState(() {
      currentIndex = (currentIndex - 1 + widget.photos.length) % widget.photos.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AssetPhoto photo = widget.photos[currentIndex];
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ONLY zoom/pan, tap area gambar tidak mengganti gambar!
          Center(
            child: GestureDetector(
              onLongPress: () => Navigator.of(context).pop(),
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 1,
                maxScale: 6,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(
                    photo.fileUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.white,
                        height: 300,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image, size: 64, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Gagal memuat foto', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.white,
                        height: 300,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                            color: const Color(0xFF405189),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          // LEFT ARROW ONLY tapable
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 80,
              color: Colors.transparent,
              child: Center(
                child: GestureDetector(
                  onTap: _prevImage,
                  child: Icon(Icons.arrow_back_ios, color: Colors.white.withOpacity(0.7), size: 36),
                ),
              ),
            ),
          ),
          // RIGHT ARROW ONLY tapable
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 80,
              color: Colors.transparent,
              child: Center(
                child: GestureDetector(
                  onTap: _nextImage,
                  child: Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.7), size: 36),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 32,
            left: 24,
            right: 24,
            child: Column(
              children: [
                if (photo.description != null && photo.description!.isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      photo.description!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Maison Book',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (photo.uploadedAt != null)
                  Container(
                    margin: EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Uploaded: ${DateFormat('dd/MM/yyyy HH:mm').format(photo.uploadedAt!)}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                        fontFamily: 'Maison Book',
                      ),
                    ),
                  ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${currentIndex + 1} / ${widget.photos.length}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                      fontFamily: 'Maison Book',
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 36,
            right: 36,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.all(8),
                child: Icon(Icons.close, color: Colors.white, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }
}