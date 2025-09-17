class RecentAsset {
  final int id;
  final String assetNo;
  final String? title;
  final String? assetSpecification;
  final String? generalAccount;
  final String? category;
  final String? subCategory;
  final String? subsidiaryAccount;
  final DateTime? acquisitionDate;
  final String? aging;
  final int? quantity;
  final String? department;
  final String? controlDepartment;
  final String? costCenter;
  final String? remarks;
  final String? status;
  final int available;
  final int broken;
  final int lost;
  final String scannedBy;
  final DateTime scannedAt;
  final int photosCount;

  RecentAsset({
    required this.id,
    required this.assetNo,
    this.title,
    this.assetSpecification,
    this.generalAccount,
    this.category,
    this.subCategory,
    this.subsidiaryAccount,
    this.acquisitionDate,
    this.aging,
    this.quantity,
    this.department,
    this.controlDepartment,
    this.costCenter,
    this.remarks,
    this.status,
    required this.available,
    required this.broken,
    required this.lost,
    required this.scannedBy,
    required this.scannedAt,
    required this.photosCount,
  });

  factory RecentAsset.fromJson(Map<String, dynamic> json) {
    print("DEBUG: Creating RecentAsset from JSON: $json");
    
    return RecentAsset(
      id: json['id'],
      assetNo: json['asset_no'],
      title: json['title'],
      assetSpecification: json['asset_specification'],
      generalAccount: json['general_account'],
      category: json['category'],
      subCategory: json['sub_category'],
      subsidiaryAccount: json['subsidiary_account'],
      acquisitionDate: json['acquisition_date'] != null 
          ? DateTime.tryParse(json['acquisition_date']) 
          : null,
      aging: json['aging'],
      quantity: json['quantity'],
      department: json['department'],
      controlDepartment: json['control_department'],
      costCenter: json['cost_center'],
      remarks: json['remarks'],
      status: json['asset_status'], 
      available: json['available'] ?? 0,
      broken: json['broken'] ?? 0,
      lost: json['lost'] ?? 0,
      scannedBy: json['scanned_by'],
      scannedAt: DateTime.parse(json['scanned_at']),
      photosCount: json['photos_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'asset_no': assetNo,
      'title': title,
      'asset_specification': assetSpecification,
      'general_account': generalAccount,
      'category': category,
      'sub_category': subCategory,
      'subsidiary_account': subsidiaryAccount,
      'acquisition_date': acquisitionDate?.toIso8601String(),
      'aging': aging,
      'quantity': quantity,
      'department': department,
      'control_department': controlDepartment,
      'cost_center': costCenter,
      'remarks': remarks,
      'asset_status': status,
      'available': available,
      'broken': broken,
      'lost': lost,
      'scanned_by': scannedBy,
      'scanned_at': scannedAt.toIso8601String(),
      'photos_count': photosCount,
    };
  }
}