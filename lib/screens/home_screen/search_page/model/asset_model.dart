class AssetPhoto {
  final int id;
  final String fileName;
  final String fileUrl;
  final String? fileType;
  final int? fileSize;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AssetPhoto({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    this.fileType,
    this.fileSize,
    this.createdAt,
    this.updatedAt,
  });

  factory AssetPhoto.fromJson(Map<String, dynamic> json) {
    return AssetPhoto(
      id: json['id'] ?? 0,
      fileName: json['file_name'] ?? json['filename'] ?? '',
      fileUrl: json['file_url'] ?? json['url'] ?? '',
      fileType: json['file_type'] ?? json['mime_type'],
      fileSize: json['file_size'] != null ? int.tryParse(json['file_size'].toString()) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_name': fileName,
      'filename': fileName,
      'file_url': fileUrl,
      'url': fileUrl,
      'file_type': fileType,
      'mime_type': fileType,
      'file_size': fileSize,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class Asset {
  final int id;
  final String title;                
  final String assetNo;              
  final String subsidiaryAccount;    
  final String generalAccount;       
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

  // Tambahan untuk display
  final String? imagePath;
  final List<AssetPhoto>? photos;
  final AssetPhoto? primaryPhoto;
  final int? photosCount;

  Asset({
    required this.id,
    required this.title,
    required this.assetNo,
    required this.generalAccount,
    required this.subsidiaryAccount,
    required this.category,
    required this.subCategory,
    required this.assetSpecification,
    required this.assetStatus,
    required this.acquisitionDate,
    required this.aging,
    required this.quantity,
    required this.department,
    required this.controlDepartment,
    required this.costCenter,
    required this.available,
    required this.broken,
    required this.lost,
    required this.remarks,
    this.imagePath,
    this.photos,
    this.primaryPhoto,
    this.photosCount,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      assetNo: json['asset_no'] ?? '',
      generalAccount: json['general_account'] ?? '',
      subsidiaryAccount: json['subsidiary_account'] ?? '',
      category: json['category'] ?? '',
      subCategory: json['sub_category'] ?? '',
      assetSpecification: json['asset_specification'] ?? '',
      assetStatus: json['asset_status'] ?? '',
      acquisitionDate: json['acquisition_date'] != null 
          ? DateTime.tryParse(json['acquisition_date'].toString())
          : null,
      aging: json['aging']?.toString() ?? '',
      quantity: int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      department: json['department'] ?? '',
      controlDepartment: json['control_department'] ?? '',
      costCenter: json['cost_center'] ?? '',
      available: int.tryParse(json['available']?.toString() ?? '0') ?? 0,
      broken: int.tryParse(json['broken']?.toString() ?? '0') ?? 0,
      lost: int.tryParse(json['lost']?.toString() ?? '0') ?? 0,
      remarks: json['remarks'] ?? '',
      imagePath: json['image_path'] ?? (json['primary_photo']?['file_url']),
      photos: json['photos'] != null 
          ? (json['photos'] as List).map((e) => AssetPhoto.fromJson(e)).toList()
          : null,
      primaryPhoto: json['primary_photo'] != null 
          ? AssetPhoto.fromJson(json['primary_photo']) 
          : null,
      photosCount: json['photos_count'] != null
          ? int.tryParse(json['photos_count'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'asset_no': assetNo,
      'general_account': generalAccount,
      'subsidiary_account': subsidiaryAccount,
      'category': category,
      'sub_category': subCategory,
      'asset_specification': assetSpecification,
      'asset_status': assetStatus,
      'acquisition_date': acquisitionDate?.toIso8601String(),
      'aging': aging,
      'quantity': quantity,
      'department': department,
      'control_department': controlDepartment,
      'cost_center': costCenter,
      'available': available,
      'broken': broken,
      'lost': lost,
      'remarks': remarks,
      'image_path': imagePath,
      'photos': photos?.map((photo) => photo.toJson()).toList(),
      'primary_photo': primaryPhoto?.toJson(),
      'photos_count': photosCount,
    };
  }

  String? get primaryImageUrl {
    if (primaryPhoto?.fileUrl != null && primaryPhoto!.fileUrl.isNotEmpty) {
      return primaryPhoto!.fileUrl;
    }
    if (imagePath != null && imagePath!.isNotEmpty) {
      return imagePath;
    }
    if (photos != null && photos!.isNotEmpty) {
      return photos!.first.fileUrl;
    }
    return null;
  }

  List<String> get allImageUrls {
    List<String> urls = [];
    if (primaryPhoto?.fileUrl != null && primaryPhoto!.fileUrl.isNotEmpty) {
      urls.add(primaryPhoto!.fileUrl);
    }
    if (imagePath != null && imagePath!.isNotEmpty && 
        (primaryPhoto?.fileUrl == null || primaryPhoto!.fileUrl != imagePath)) {
      urls.add(imagePath!);
    }
    if (photos != null) {
      for (var photo in photos!) {
        if (photo.fileUrl.isNotEmpty && !urls.contains(photo.fileUrl)) {
          urls.add(photo.fileUrl);
        }
      }
    }
    return urls;
  }

  // Helper methods
  bool get isAvailable => available > 0;
  bool get hasDamaged => broken > 0;
  bool get hasLost => lost > 0;
  int get totalQuantity => quantity;

  @override
  String toString() {
    return 'Asset{id: $id, title: $title, assetNo: $assetNo, assetStatus: $assetStatus}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Asset && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}