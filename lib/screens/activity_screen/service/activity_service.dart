import 'dart:convert';
import 'package:http/http.dart' as http;

// Asset detail model sesuai LogisticAsset
class AssetDetail {
  final String assetCode;
  final String assetName;
  final String? category;
  final String? department;
  final String? assetStatus;
  final String? acquisitionDate;
  final String? aging;
  final int? quantity;
  final int? available;
  final int? broken;
  final int? lost;
  final String? activityTime;
  final String? createdAt;
  final String? updatedAt;

  AssetDetail({
    required this.assetCode,
    required this.assetName,
    this.category,
    this.department,
    this.assetStatus,
    this.acquisitionDate,
    this.aging,
    this.quantity,
    this.available,
    this.broken,
    this.lost,
    this.activityTime,
    this.createdAt,
    this.updatedAt,
  });

  factory AssetDetail.fromJson(Map<String, dynamic> json) {
    return AssetDetail(
      assetCode: json['asset_code'] ?? '',
      assetName: json['title'] ?? json['description'] ?? '',
      category: json['category'],
      department: json['department'],
      assetStatus: json['asset_status'],
      acquisitionDate: json['acquisition_date'],
      aging: json['aging'],
      quantity: json['quantity'],
      available: json['available'],
      broken: json['broken'],
      lost: json['lost'],
      activityTime: json['activity_time'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  // Untuk compatibility dengan kode lama
  String? get imageUrl => null; // Tidak ada image_url di LogisticAsset
  String? get location => department; // Gunakan department sebagai location
  String? get status => assetStatus; // Gunakan asset_status sebagai status
  String? get dateAdded => acquisitionDate; // Gunakan acquisition_date
}

class ActivityLog {
  final int id;
  final String userId;
  final String activityType;
  final String description;
  final String assetCode;
  final DateTime activityTime;
  final String? meta;
  final AssetDetail assetDetail;

  ActivityLog({
    required this.id,
    required this.userId,
    required this.activityType,
    required this.description,
    required this.assetCode,
    required this.activityTime,
    this.meta,
    required this.assetDetail,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'],
      userId: json['user_id']?.toString() ?? '',
      activityType: json['activity_type'] ?? '',
      description: json['description'] ?? '',
      assetCode: json['asset_code'] ?? '',
      activityTime: DateTime.parse(json['activity_time'] ?? DateTime.now().toIso8601String()),
      meta: json['meta']?.toString(),
      assetDetail: AssetDetail.fromJson(json),
    );
  }

  // Helper methods untuk UI
  String get activityIcon {
    switch (activityType) {
      case 'scan_asset':
        return '📱';
      case 'upload_photo':
        return '📸';
      case 'update_status':
        return '🔄';
      case 'import_assets':
        return '📁';
      case 'search_asset':
        return '🔍';
      case 'view_photos':
        return '👁️';
      default:
        return '📋';
    }
  }

  String get activityTitle {
    switch (activityType) {
      case 'scan_asset':
        return 'Asset Scanned';
      case 'upload_photo':
        return 'Photo Uploaded';
      case 'update_status':
        return 'Status Updated';
      case 'import_assets':
        return 'Assets Imported';
      case 'search_asset':
        return 'Asset Searched';
      case 'view_photos':
        return 'Photos Viewed';
      default:
        return 'Activity';
    }
  }
}

class ActivityService {
  final String baseUrl;
  ActivityService({required this.baseUrl});

  // Hanya method fetch - tidak ada CRUD
  Future<List<ActivityLog>> fetchActivities({String? userId}) async {
    String url = '$baseUrl/api/activity-logs';
    if (userId != null && userId.isNotEmpty) {
      url += '?user_id=$userId';
    }
    
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => ActivityLog.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load activities');
    }
  }
}