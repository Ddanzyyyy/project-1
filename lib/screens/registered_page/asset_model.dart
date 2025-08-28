class Asset {
  final String id;
  final String name;
  final String category;
  final String description;
  final String imagePath;
  final String dateAdded;
  final String assetCode; // Kode Aset / QR Code
  final String location;  // Lokasi
  final String pic;       // PIC / Penanggung Jawab
  final String status;    // Status Aset

  Asset({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.imagePath,
    required this.dateAdded,
    required this.assetCode,
    required this.location,
    required this.pic,
    required this.status,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      imagePath: json['image_path'] ?? '',
      dateAdded: json['date_added'] ?? '',
      assetCode: json['asset_code'] ?? '',
      location: json['location'] ?? '',
      pic: json['pic'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'description': description,
    'image_path': imagePath,
    'date_added': dateAdded,
    'asset_code': assetCode,
    'location': location,
    'pic': pic,
    'status': status,
  };
}