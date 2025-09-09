class AssetModel {
  final int id;
  final String name;
  final String code;
  final String location;
  final String division;
  final String status;
  final String imageUrl;
  final String? category;
  final String? description;
  final String? assetCode;
  final String? pic;
  final String? createdAt;

  AssetModel({
    required this.id,
    required this.name,
    required this.code,
    required this.location,
    required this.division,
    required this.status,
    required this.imageUrl,
    this.category,
    this.description,
    this.assetCode,
    this.pic,
    this.createdAt,
  });

  factory AssetModel.fromJson(Map<String, dynamic> json) {
    return AssetModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      location: json['location'] ?? '',
      division: json['division'] ?? '',
      status: json['status'] ?? '',
      imageUrl: json['image_path'] ?? '',
      category: json['category'],
      description: json['description'],
      assetCode: json['asset_code'],
      pic: json['pic'],
      createdAt: json['created_at'],
    );
  }
}