class DamageReport {
  final String id;
  final String assetId;
  final String description;
  final String? imageUrl;
  final String status;
  final String dateReported;
  final List<RepairHistory> repairHistory;

  // Tambahan field untuk multi-gambar
  final List<String> additionalImages;

  // Tambahan field untuk notes dokumentasi
  final List<String> additionalImagesNotes; // <-- Tambahkan field ini

  DamageReport({
    required this.id,
    required this.assetId,
    required this.description,
    this.imageUrl,
    required this.status,
    required this.dateReported,
    required this.repairHistory,
    this.additionalImages = const [],
    this.additionalImagesNotes = const [], // <-- Tambahkan di konstruktor
  });

  // Factory untuk parsing dari JSON (sesuai Laravel API)
  factory DamageReport.fromJson(Map<String, dynamic> json) {
    return DamageReport(
      id: json['id'].toString(),
      assetId: json['asset_id'].toString(),
      description: json['description'] ?? '',
      imageUrl: json['image_url'],
      status: json['status'] ?? '',
      dateReported: json['date_reported'] ?? '',
      repairHistory: (json['repair_histories'] ?? [])
          .map<RepairHistory>((rh) => RepairHistory.fromJson(rh))
          .toList(),
      additionalImages: json['additional_images'] != null
          ? List<String>.from(json['additional_images'])
          : [],
      additionalImagesNotes: json['additional_images_notes'] != null
          ? List<String>.from(json['additional_images_notes'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'asset_id': assetId,
      'description': description,
      'image_url': imageUrl,
      'status': status,
      'date_reported': dateReported,
      'repair_histories': repairHistory.map((rh) => rh.toJson()).toList(),
      'additional_images': additionalImages,
      'additional_images_notes': additionalImagesNotes,
    };
  }
}

class RepairHistory {
  final String id;
  final String damageReportId;
  final String action;
  final String? imageUrl;
  final String dateRepaired;
  final String? notes;

  RepairHistory({
    required this.id,
    required this.damageReportId,
    required this.action,
    this.imageUrl,
    required this.dateRepaired,
    this.notes,
  });

  factory RepairHistory.fromJson(Map<String, dynamic> json) {
    return RepairHistory(
      id: json['id'].toString(),
      damageReportId: json['damage_report_id'].toString(),
      action: json['action'] ?? '',
      imageUrl: json['image_url'],
      dateRepaired: json['date_repaired'] ?? '',
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'damage_report_id': damageReportId,
      'action': action,
      'image_url': imageUrl,
      'date_repaired': dateRepaired,
      'notes': notes,
    };
  }
}