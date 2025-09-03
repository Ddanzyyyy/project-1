import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'asset_model.dart';
import 'asset_service.dart';

class AddEditAssetDialog extends StatefulWidget {
  final Asset? asset;
  final Function(Asset) onSave;
  final List<String> categories;

  const AddEditAssetDialog({
    Key? key,
    this.asset,
    required this.onSave,
    required this.categories,
  }) : super(key: key);

  @override
  _AddEditAssetDialogState createState() => _AddEditAssetDialogState();
}

class _AddEditAssetDialogState extends State<AddEditAssetDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _assetCodeController;
  late TextEditingController _locationController;
  late TextEditingController _picController;
  String _selectedCategory = '';
  String _status = 'registered';
  File? _pickedImage;
  bool _isUploading = false;

  // Improved color scheme
  static const Color primaryColor = Color(0xFF2B4C7E);
  static const Color secondaryColor = Color(0xFFF8FAFC);
  static const Color accentColor = Color(0xFFE2E8F0);
  static const Color successColor = Color(0xFF059669);
  static const Color errorColor = Color(0xFFDC2626);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color cardBackground = Color(0xFFFFFFFF);

  final List<Map<String, dynamic>> statusOptions = [
    {'value': 'registered', 'label': 'Registered', 'color': successColor},
    {'value': 'unscanned', 'label': 'Unscanned', 'color': Color(0xFFF59E0B)},
    {'value': 'damaged', 'label': 'Damaged', 'color': Color(0xFFEF4444)},
    {'value': 'lost', 'label': 'Lost', 'color': errorColor},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.asset?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.asset?.description ?? '');
    _assetCodeController =
        TextEditingController(text: widget.asset?.assetCode ?? '');
    _locationController =
        TextEditingController(text: widget.asset?.location ?? '');
    _picController = TextEditingController(text: widget.asset?.pic ?? '');
    _status = widget.asset?.status ?? 'registered';

    if (widget.asset?.category != null &&
        widget.categories.contains(widget.asset!.category)) {
      _selectedCategory = widget.asset!.category;
    } else {
      _selectedCategory =
          widget.categories.isNotEmpty ? widget.categories.first : '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _assetCodeController.dispose();
    _locationController.dispose();
    _picController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
        source: ImageSource.gallery, maxWidth: 800, maxHeight: 800);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  void _saveAsset() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isUploading = true);

      final asset = Asset(
        id: widget.asset?.id ?? '',
        name: _nameController.text.trim(),
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
        imagePath: widget.asset?.imagePath ?? '',
        dateAdded: widget.asset?.dateAdded ?? DateTime.now().toIso8601String(),
        assetCode: _assetCodeController.text.trim(),
        location: _locationController.text.trim(),
        pic: _picController.text.trim(),
        status: _status,
      );

      try {
        Asset newAsset;
        if (widget.asset == null) {
          newAsset =
              await AssetService.addAsset(asset, imageFile: _pickedImage);
        } else {
          newAsset =
              await AssetService.updateAsset(asset, imageFile: _pickedImage);
        }
        widget.onSave(newAsset);
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: successColor,
            content: Text(
              widget.asset == null
                  ? 'Aset berhasil ditambahkan'
                  : 'Aset berhasil diperbarui',
              style:
                  TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
            ),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: errorColor,
              content: Text(
                'Gagal menyimpan aset: $e',
                style:
                    TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          maxWidth: MediaQuery.of(context).size.width * 0.95,
        ),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImagePicker(),
                      SizedBox(height: 24),
                      _buildFormFields(),
                      SizedBox(height: 24),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.asset != null ? 'Edit Aset' : 'Tambah Aset Baru',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  widget.asset != null
                      ? 'Perbarui informasi aset yang sudah ada'
                      : 'Masukkan detail aset yang akan ditambahkan',
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
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: textSecondary),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 2),
              ),
              child: _pickedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(_pickedImage!, fit: BoxFit.cover),
                    )
                  : widget.asset?.imagePath != null &&
                          widget.asset!.imagePath.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(widget.asset!.imagePath,
                              fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.add,
                                  color: primaryColor, size: 23), // plus icon
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tambah Foto',
                              style: TextStyle(
                                color: textSecondary,
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
            ),
          ),
          if (_isUploading)
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  color: primaryColor,
                  strokeWidth: 3,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        _buildTextField(
          controller: _nameController,
          label: 'Nama Aset',
          hint: 'Masukkan nama aset',
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Nama aset wajib diisi'
              : null,
        ),
        SizedBox(height: 16),
        _buildTextField(
          controller: _assetCodeController,
          label: 'Kode Aset',
          hint: 'Masukkan kode aset atau QR code',
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Kode aset wajib diisi'
              : null,
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _locationController,
                label: 'Lokasi',
                hint: 'Lokasi aset',
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Lokasi wajib diisi'
                    : null,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _picController,
                label: 'PIC',
                hint: 'Nama PIC',
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'PIC wajib diisi'
                    : null,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        // <-- Ubah bagian ini jadi Column
        Column(
          children: [
            _buildStatusDropdown(),
            SizedBox(height: 16),
            _buildCategoryDropdown(),
          ],
        ),
        SizedBox(height: 16),
        _buildTextField(
          controller: _descriptionController,
          label: 'Deskripsi',
          hint: 'Masukkan deskripsi aset',
          maxLines: 3,
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Deskripsi wajib diisi'
              : null,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
          decoration: _buildInputDecoration(hint),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildStatusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _status,
          decoration: _buildInputDecoration('Pilih status'),
          items: statusOptions.map<DropdownMenuItem<String>>((status) {
            return DropdownMenuItem<String>(
              value: status['value'] as String,
              child: Text(
                status['label'],
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textPrimary,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) => setState(() => _status = value!),
          validator: (value) =>
              value == null || value.isEmpty ? 'Status wajib dipilih' : null,
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _selectedCategory.isEmpty ? null : _selectedCategory,
          decoration: _buildInputDecoration('Pilih kategori'),
          items: widget.categories.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(
                category,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textPrimary,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedCategory = value!),
          validator: (value) =>
              value == null || value.isEmpty ? 'Kategori wajib dipilih' : null,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: _isUploading ? null : () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: textSecondary,
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: borderColor),
              ),
            ),
            child: Text(
              'Batal',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _isUploading ? null : _saveAsset,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: _isUploading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Menyimpan...',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  )
                : Text(
                    widget.asset != null ? 'Perbarui Aset' : 'Tambah Aset',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
      ),
      filled: true,
      fillColor: secondaryColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: errorColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: errorColor, width: 1.5),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      isDense: true,
    );
  }
}
