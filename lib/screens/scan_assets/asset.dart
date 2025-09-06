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
    this.lastScannedAt, // Tambahan ke constructor
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      imagePath: json['image_path'],
      dateAdded: json['date_added'] ?? '',
      assetCode: json['asset_code'] ?? '',
      location: json['location'] ?? '',
      pic: json['pic'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      lastScannedAt: json['last_scanned_at'] != null ? DateTime.parse(json['last_scanned_at']) : null, // Tambahan
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'description': description,
      'date_added': dateAdded,
      'asset_code': assetCode,
      'location': location,
      'pic': pic,
      'status': status,
      'last_scanned_at': lastScannedAt?.toIso8601String(), // Tambahan
    };
  }

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
    );
  }
}