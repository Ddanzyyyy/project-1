import 'package:Simba/screens/home_screen/logistic_asset/logistic_asset_model.dart';

class Asset {
  final int id;
  final String name;
  final String category;
  final String description;
  final String? imagePath;
  final String dateAdded;
  final String assetCode;
  final String location;
  final String pic;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastScannedAt;
  final String? scannedBy;
  final String? generalAccount;
  final String? subsidiaryAccount;
  final String? subCategory;
  final String? assetSpecification;
  final DateTime? acquisitionDate;
  final String? aging;
  final int? quantity;
  final String? controlDepartment;
  final String? costCenter;
  final int? available;
  final int? broken;
  final int? lost;
  final String? remarks;
  final List<AssetPhoto>? photos;
  final AssetPhoto? primaryPhoto;
  final int? photosCount; // Tambahkan field ini

  Asset({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    this.imagePath,
    required this.dateAdded,
    required this.assetCode,
    required this.location,
    required this.pic,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.lastScannedAt,
    this.scannedBy,
    this.generalAccount,
    this.subsidiaryAccount,
    this.subCategory,
    this.assetSpecification,
    this.acquisitionDate,
    this.aging,
    this.quantity,
    this.controlDepartment,
    this.costCenter,
    this.available,
    this.broken,
    this.lost,
    this.remarks,
    this.photos,
    this.primaryPhoto,
    this.photosCount, // Tambahkan ke constructor
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'] ?? 0,
      name: json['title'] ?? json['name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? json['remarks'] ?? '',
      imagePath: json['image_path'] ?? (json['primary_photo']?['file_url']),
      dateAdded: json['date_added'] ?? '',
      assetCode: json['asset_no'] ?? json['asset_code'] ?? '',
      location: json['location'] ?? json['department'] ?? '',
      pic: json['pic'] ?? json['department'] ?? '',
      status: json['asset_status'] ?? json['status'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
      lastScannedAt: json['last_scanned_at'] != null ? DateTime.tryParse(json['last_scanned_at'].toString()) : null,
      scannedBy: json['scanned_by'],
      generalAccount: json['general_account'],
      subsidiaryAccount: json['subsidiary_account'],
      subCategory: json['sub_category'],
      assetSpecification: json['asset_specification'],
      acquisitionDate: json['acquisition_date'] != null 
          ? DateTime.tryParse(json['acquisition_date'].toString()) 
          : null,
      aging: json['aging']?.toString(),
      quantity: int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      controlDepartment: json['control_department'],
      costCenter: json['cost_center'],
      available: int.tryParse(json['available']?.toString() ?? '0') ?? 0,
      broken: int.tryParse(json['broken']?.toString() ?? '0') ?? 0,
      lost: int.tryParse(json['lost']?.toString() ?? '0') ?? 0,
      remarks: json['remarks'],
      photos: json['photos'] != null 
          ? (json['photos'] as List).map((e) => AssetPhoto.fromJson(e)).toList()
          : null,
      primaryPhoto: json['primary_photo'] != null 
          ? AssetPhoto.fromJson(json['primary_photo']) 
          : null,
      photosCount: json['photos_count'] != null
          ? int.tryParse(json['photos_count'].toString())
          : null, // mapping dari API
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': name,
      'category': category,
      'description': description,
      'remarks': description,
      'image_path': imagePath,
      'date_added': dateAdded,
      'asset_code': assetCode,
      'asset_no': assetCode,
      'location': location,
      'department': location,
      'pic': pic,
      'status': status,
      'asset_status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'last_scanned_at': lastScannedAt?.toIso8601String(),
      'scanned_by': scannedBy,
      'general_account': generalAccount,
      'subsidiary_account': subsidiaryAccount,
      'sub_category': subCategory,
      'asset_specification': assetSpecification,
      'acquisition_date': acquisitionDate?.toIso8601String(),
      'aging': aging,
      'quantity': quantity,
      'control_department': controlDepartment,
      'cost_center': costCenter,
      'available': available,
      'broken': broken,
      'lost': lost,
      'photos': photos?.map((photo) => photo.toJson()).toList(),
      'primary_photo': primaryPhoto?.toJson(),
      'photos_count': photosCount, // tambahkan ke toJson
    };
  }

  // Tambahkan agar bisa update field tertentu tanpa membuat instance baru
  Asset copyWith({
    int? id,
    String? name,
    String? category,
    String? description,
    String? imagePath,
    String? dateAdded,
    String? assetCode,
    String? location,
    String? pic,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastScannedAt,
    String? scannedBy,
    String? generalAccount,
    String? subsidiaryAccount,
    String? subCategory,
    String? assetSpecification,
    DateTime? acquisitionDate,
    String? aging,
    int? quantity,
    String? controlDepartment,
    String? costCenter,
    int? available,
    int? broken,
    int? lost,
    String? remarks,
    List<AssetPhoto>? photos,
    AssetPhoto? primaryPhoto,
    int? photosCount, // Tambahkan di copyWith
  }) {
    return Asset(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      dateAdded: dateAdded ?? this.dateAdded,
      assetCode: assetCode ?? this.assetCode,
      location: location ?? this.location,
      pic: pic ?? this.pic,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastScannedAt: lastScannedAt ?? this.lastScannedAt,
      scannedBy: scannedBy ?? this.scannedBy,
      generalAccount: generalAccount ?? this.generalAccount,
      subsidiaryAccount: subsidiaryAccount ?? this.subsidiaryAccount,
      subCategory: subCategory ?? this.subCategory,
      assetSpecification: assetSpecification ?? this.assetSpecification,
      acquisitionDate: acquisitionDate ?? this.acquisitionDate,
      aging: aging ?? this.aging,
      quantity: quantity ?? this.quantity,
      controlDepartment: controlDepartment ?? this.controlDepartment,
      costCenter: costCenter ?? this.costCenter,
      available: available ?? this.available,
      broken: broken ?? this.broken,
      lost: lost ?? this.lost,
      remarks: remarks ?? this.remarks,
      photos: photos ?? this.photos,
      primaryPhoto: primaryPhoto ?? this.primaryPhoto,
      photosCount: photosCount ?? this.photosCount,
    );
  }
}