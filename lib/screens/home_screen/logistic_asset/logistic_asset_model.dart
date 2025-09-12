class LogisticAsset {
  final String id;
  final String title;
  final String assetNo;
  final String generalAccount;
  final String subsidiaryAccount;
  final String category;
  final String subCategory;
  final String assetSpecification;
  final String assetStatus;
  final DateTime? acquisitionDate;
  final String aging;
  final int quantity;
  final String department;
  final String controlDepartment;
  final String costCenter;
  final int available;
  final int broken;
  final int lost;
  final String remarks;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<AssetPhoto>? photos;
  final AssetPhoto? primaryPhoto;

  LogisticAsset({
    required this.id,
    required this.title,
    required this.assetNo,
    required this.generalAccount,
    required this.subsidiaryAccount,
    required this.category,
    required this.subCategory,
    required this.assetSpecification,
    required this.assetStatus,
    this.acquisitionDate,
    required this.aging,
    required this.quantity,
    required this.department,
    required this.controlDepartment,
    required this.costCenter,
    required this.available,
    required this.broken,
    required this.lost,
    required this.remarks,
    required this.createdAt,
    required this.updatedAt,
    this.photos,
    this.primaryPhoto,
  });

  factory LogisticAsset.fromJson(Map<String, dynamic> json) {
    return LogisticAsset(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      assetNo: json['asset_no']?.toString() ?? '',
      generalAccount: json['general_account']?.toString() ?? '',
      subsidiaryAccount: json['subsidiary_account']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      subCategory: json['sub_category']?.toString() ?? '',
      assetSpecification: json['asset_specification']?.toString() ?? '',
      assetStatus: json['asset_status']?.toString() ?? '',
      acquisitionDate: json['acquisition_date'] != null 
          ? DateTime.tryParse(json['acquisition_date'].toString()) 
          : null,
      aging: json['aging']?.toString() ?? '',
      quantity: int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      department: json['department']?.toString() ?? '',
      controlDepartment: json['control_department']?.toString() ?? '',
      costCenter: json['cost_center']?.toString() ?? '',
      available: int.tryParse(json['available']?.toString() ?? '0') ?? 0,
      broken: int.tryParse(json['broken']?.toString() ?? '0') ?? 0,
      lost: int.tryParse(json['lost']?.toString() ?? '0') ?? 0,
      remarks: json['remarks']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
      photos: json['photos'] != null 
          ? (json['photos'] as List).map((e) => AssetPhoto.fromJson(e)).toList()
          : null,
      primaryPhoto: json['primary_photo'] != null 
          ? AssetPhoto.fromJson(json['primary_photo']) 
          : null,
    );
  }
}

class AssetPhoto {
  final String id;
  final String assetId;
  final String fileName;
  final String filePath;
  final String fileUrl;
  final bool isPrimary;
  final String? caption;
  final int? fileSize;
  final String? mimeType;
  final String uploadedBy;
  final DateTime createdAt;

  AssetPhoto({
    required this.id,
    required this.assetId,
    required this.fileName,
    required this.filePath,
    required this.fileUrl,
    required this.isPrimary,
    this.caption,
    this.fileSize,
    this.mimeType,
    required this.uploadedBy,
    required this.createdAt,
  });

  factory AssetPhoto.fromJson(Map<String, dynamic> json) {
    return AssetPhoto(
      id: json['id']?.toString() ?? '',
      assetId: json['asset_id']?.toString() ?? '',
      fileName: json['file_name']?.toString() ?? '',
      filePath: json['file_path']?.toString() ?? '',
      fileUrl: json['file_url']?.toString() ?? '',
      isPrimary: json['is_primary'] == true || json['is_primary'] == 1,
      caption: json['caption']?.toString(),
      fileSize: int.tryParse(json['file_size']?.toString() ?? ''),
      mimeType: json['mime_type']?.toString(),
      uploadedBy: json['uploaded_by']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}