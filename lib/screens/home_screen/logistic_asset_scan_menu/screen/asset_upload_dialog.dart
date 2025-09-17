import 'dart:io';
import 'package:Simba/screens/home_screen/lost_assets/compact_lost_asset_card.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Simba/screens/home_screen/logistic_asset/service/logistic_asset_service.dart';
import 'package:Simba/screens/home_screen/logistic_asset/model/logistic_asset_model.dart';

class AssetUploadDialog extends StatefulWidget {
  final LogisticAsset asset;

  const AssetUploadDialog({
    Key? key,
    required this.asset,
  }) : super(key: key);

  @override
  State<AssetUploadDialog> createState() => _AssetUploadDialogState();
}

class _AssetUploadDialogState extends State<AssetUploadDialog> {
  final TextEditingController _captionController = TextEditingController();
  List<File> _selectedImages = [];
  bool _isUploading = false;
  String _uploadStatus = '';
  bool _setPrimaryForFirst = true;
  List<AssetPhoto> _uploadedPhotos = [];

  @override
  void initState() {
    super.initState();
    _fetchUploadedPhotos();
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _fetchUploadedPhotos() async {
    final photos =
        await LogisticAssetService.getAssetPhotos(widget.asset.assetNo);
    setState(() {
      _uploadedPhotos = photos;
    });
  }

  Future<void> _pickImages({bool fromCamera = false}) async {
    final picker = ImagePicker();
    List<File> validFiles = [];

    if (fromCamera) {
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        maxHeight: 1080,
        maxWidth: 1080,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final fileSize = await file.length();
        if (fileSize <= 4 * 1024 * 1024) {
          validFiles.add(file);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File terlalu besar (max 2MB)')),
          );
        }
      }
    } else {
      List<XFile> pickedFiles = await picker.pickMultiImage(
        maxHeight: 1080,
        maxWidth: 1080,
        imageQuality: 85,
      );
      for (XFile xFile in pickedFiles) {
        final file = File(xFile.path);
        final fileSize = await file.length();
        if (fileSize <= 4 * 1024 * 1024) {
          validFiles.add(file);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('File ${xFile.name} terlalu besar (max 2MB)')),
          );
        }
      }
    }

    if (validFiles.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(validFiles);
        _uploadStatus = '${_selectedImages.length} foto dipilih';
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
      _uploadStatus = _selectedImages.isEmpty
          ? ''
          : '${_selectedImages.length} foto dipilih';
    });
  }

  Future<void> _uploadPhotos() async {
    if (_selectedImages.isEmpty) {
      setState(() {
        _uploadStatus = 'Pilih foto terlebih dahulu';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadStatus = 'Mengunggah foto...';
    });

    int successCount = 0;
    int failCount = 0;

    for (int i = 0; i < _selectedImages.length; i++) {
      final file = _selectedImages[i];
      final isPrimary = _setPrimaryForFirst && i == 0;

      setState(() {
        _uploadStatus =
            'Mengunggah foto ${i + 1} dari ${_selectedImages.length}...';
      });

      try {
        final result = await LogisticAssetService.uploadPhotoDio(
          assetNo: widget.asset.assetNo,
          file: file,
          isPrimary: isPrimary,
          caption: _captionController.text.trim().isEmpty
              ? 'Upload foto asset ${widget.asset.title}'
              : _captionController.text.trim(),
        );

        if (result != null) {
          successCount++;
        } else {
          failCount++;
        }
      } catch (e) {
        failCount++;
        print('Upload error for image ${i + 1}: $e');
      }
    }

    setState(() {
      _isUploading = false;
      if (failCount == 0) {
        _uploadStatus = 'Berhasil mengupload $successCount foto!';
      } else if (successCount == 0) {
        _uploadStatus = 'Gagal mengupload semua foto';
      } else {
        _uploadStatus =
            'Upload selesai: $successCount berhasil, $failCount gagal';
      }
      _selectedImages.clear();
    });

    if (successCount > 0) {
      await _fetchUploadedPhotos();
      await Future.delayed(Duration(seconds: 2));
      Navigator.pop(context, true);
    }
  }

  void _showFullScreenImage(String imageUrl) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      pageBuilder: (context, anim1, anim2) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
            child: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 30,
                  child: Icon(Icons.close, color: Colors.white, size: 32),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUploadedPhotosCard() {
    if (_uploadedPhotos.isEmpty) {
      return SizedBox();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Foto Asset Di Database',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
            fontFamily: 'Maison Bold',
          ),
        ),
        SizedBox(height: 12),
        Container(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _uploadedPhotos.length,
            itemBuilder: (context, index) {
              final photo = _uploadedPhotos[index];
              return GestureDetector(
                  onTap: () => _showFullScreenImage(photo.fileUrl),
                  child: Card(
                    elevation: 2,
                    margin: EdgeInsets.only(right: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      width: 120,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              photo.fileUrl,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) =>
                                  Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child: Icon(Icons.broken_image,
                                      color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                          if (photo.isPrimary)
                            Positioned(
                              top: 6,
                              left: 6,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: Text(
                                  'UTAMA',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          Positioned(
                            bottom: 6,
                            left: 6,
                            right: 6,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 3, horizontal: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                photo.caption ?? '-',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ));
            },
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF405189);

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(7),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(7),
                  topRight: Radius.circular(7),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upload Foto Asset',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Maison Bold',
                          ),
                        ),
                        Text(
                          widget.asset.title,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontFamily: 'Maison Book',
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Colors.grey[600], size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Asset No: ${widget.asset.assetNo}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                                fontFamily: 'Maison Bold',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Remarks (Optional)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                        fontFamily: 'Maison Bold',
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _captionController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Tambahkan caption untuk foto',
                        hintStyle: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Maison Book',
                            color: Colors.grey[500]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    if (_selectedImages.isNotEmpty) ...[
                      Row(
                        children: [
                          Checkbox(
                            value: _setPrimaryForFirst,
                            onChanged: (value) {
                              setState(() {
                                _setPrimaryForFirst = value ?? false;
                              });
                            },
                            activeColor: primaryColor,
                          ),
                          Expanded(
                            child: Text(
                              'Set foto pertama sebagai foto utama',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontFamily: 'Maison Book',
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              label: Text(_selectedImages.isEmpty
                                  ? 'Pilih dari Galeri'
                                  : 'Tambah Galeri'),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                side: BorderSide(color: primaryColor),
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: _isUploading
                                  ? null
                                  : () => _pickImages(fromCamera: false),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              label: Text('Foto Langsung'),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                side: BorderSide(color: primaryColor),
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: _isUploading
                                  ? null
                                  : () => _pickImages(fromCamera: true),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    if (_selectedImages.isNotEmpty) ...[
                      Text(
                        'Foto Terpilih (${_selectedImages.length})',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                          fontFamily: 'Maison Bold',
                        ),
                      ),
                      SizedBox(height: 12),
                      Container(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.only(right: 12),
                              child: Stack(
                                children: [
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border:
                                          Border.all(color: Colors.grey[300]!),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        _selectedImages[index],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  if (_setPrimaryForFirst && index == 0)
                                    Positioned(
                                      top: 4,
                                      left: 4,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(7),
                                        ),
                                        child: Text(
                                          'UTAMA',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(index),
                                      child: Container(
                                        padding: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: _isUploading
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Icon(Icons.cloud_upload),
                        label: Text(
                            _isUploading ? 'Mengupload...' : 'Upload Foto'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        onPressed: _isUploading || _selectedImages.isEmpty
                            ? null
                            : _uploadPhotos,
                      ),
                    ),
                    if (_uploadStatus.isNotEmpty) ...[
                      SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _uploadStatus.contains('Berhasil')
                              ? Colors.green[50]
                              : _uploadStatus.contains('Gagal')
                                  ? Colors.red[50]
                                  : Colors.blue[50],
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(
                            color: _uploadStatus.contains('Berhasil')
                                ? Colors.green[200]!
                                : _uploadStatus.contains('Gagal')
                                    ? Colors.red[200]!
                                    : Colors.blue[200]!,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _uploadStatus.contains('Berhasil')
                                  ? Icons.check_circle
                                  : _uploadStatus.contains('Gagal')
                                      ? Icons.error
                                      : Icons.info,
                              color: _uploadStatus.contains('Berhasil')
                                  ? Colors.green[600]
                                  : _uploadStatus.contains('Gagal')
                                      ? Colors.red[600]
                                      : Colors.blue[600],
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _uploadStatus,
                                style: TextStyle(
                                  color: _uploadStatus.contains('Berhasil')
                                      ? Colors.green[700]
                                      : _uploadStatus.contains('Gagal')
                                          ? Colors.red[700]
                                          : Colors.blue[700],
                                  fontSize: 14,
                                  fontFamily: 'Maison Book',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: 12),
                    Text(
                      'Format: JPG, JPEG, PNG (Max: 2MB per foto)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildUploadedPhotosCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
