class Asset {
  final String id;
  final String name;
  final String category;
  final String description;
  final String imagePath;
  final String dateAdded;
  final String createdAt;    // <--- Tambahan field createdAt
  final String assetCode; 
  final String location;  
  final String pic;      
  final String status; 

  Asset({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.imagePath,
    required this.dateAdded,
    required this.createdAt,   // <--- Tambahan di constructor
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
      createdAt: json['created_at'] ?? '',    // <--- Ambil dari json
      assetCode: json['asset_code'] ?? '',
      location: json['location'] ?? '',
      pic: json['pic'] ?? '',
      status: json['status'] ?? '',
    );
  }

  get updatedAt => null;
  get lastScanned => null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'description': description,
    'image_path': imagePath,
    'date_added': dateAdded,
    'created_at': createdAt,      // <--- Tambahkan ke JSON
    'asset_code': assetCode,
    'location': location,
    'pic': pic,
    'status': status,
  };

  copyWith({required String name, required String category, required String location, required String description, required String status}) {}
}