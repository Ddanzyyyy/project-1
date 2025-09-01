class AssetItem {
  final String id;
  final String name;
  final String category;
  final String description;
  final String image_path;
  final String date_added;
  final String asset_code;
  final String location;
  final String pic;
  final String status;
  final String? last_scanned_at;
  final String? created_at;
  final String? updated_at;
  final String? scanned_at;
  final String? scan_type;

  AssetItem({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.image_path,
    required this.date_added,
    required this.asset_code,
    required this.location,
    required this.pic,
    required this.status,
    this.last_scanned_at,
    this.created_at,
    this.updated_at,
    this.scanned_at,
    this.scan_type,
  });

  // Tambahkan getter scannedAt
  String? get scannedAt => scanned_at;

  factory AssetItem.fromJson(Map<String, dynamic> json) {
    return AssetItem(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      image_path: json['image_path'] ?? '',
      date_added: json['date_added'] ?? '',
      asset_code: json['asset_code'] ?? '',
      location: json['location'] ?? '',
      pic: json['pic'] ?? '',
      status: json['status'] ?? '',
      last_scanned_at: json['last_scanned_at'],
      created_at: json['created_at'],
      updated_at: json['updated_at'],
      scanned_at: json['scanned_at'],
      scan_type: json['scan_type'],
    );
  }
}