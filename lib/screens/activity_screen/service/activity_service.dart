import 'dart:convert';
import 'package:http/http.dart' as http;

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
  final String? activityType;
  final String? description;

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
    this.activityType,
    this.description,
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
      activityType: json['activity_type'],
      description: json['description'],
    );
  }

  String? get imageUrl => null;
  String? get location => department;
  String? get status => assetStatus;
  String? get dateAdded => acquisitionDate;
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
    // Create AssetDetail with activity information
    Map<String, dynamic> assetDetailJson = Map<String, dynamic>.from(json);
    assetDetailJson['activity_type'] = json['activity_type'];
    assetDetailJson['description'] = json['description'];
    assetDetailJson['activity_time'] = json['activity_time'];

    return ActivityLog(
      id: json['id'],
      userId: json['user_id']?.toString() ?? '',
      activityType: json['activity_type'] ?? '',
      description: json['description'] ?? '',
      assetCode: json['asset_code'] ?? '',
      activityTime: DateTime.parse(json['activity_time'] ?? DateTime.now().toIso8601String()),
      meta: json['meta']?.toString(),
      assetDetail: AssetDetail.fromJson(assetDetailJson),
    );
  }

  // Helper methods untuk UI
  String get activityIcon {
    switch (activityType) {
      case 'scan_asset':
        return '📱';
      case 'upload_photo':
      case 'photo_upload':
        return '📸';
      case 'update_status':
      case 'status_change':
        return '🔄';
      case 'import_assets':
        return '📁';
      case 'search_asset':
        return '🔍';
      case 'view_photos':
        return '👁️';
      case 'create_asset':
        return '➕';
      case 'update_asset':
        return '✏️';
      case 'delete_asset':
        return '🗑️';
      case 'photo_delete':
        return '🗂️';
      default:
        return '📋';
    }
  }

  String get activityTitle {
    switch (activityType) {
      case 'scan_asset':
        return 'Asset Scanned';
      case 'upload_photo':
      case 'photo_upload':
        return 'Photo Uploaded';
      case 'update_status':
      case 'status_change':
        return 'Status Updated';
      case 'import_assets':
        return 'Assets Imported';
      case 'search_asset':
        return 'Asset Searched';
      case 'view_photos':
        return 'Photos Viewed';
      case 'create_asset':
        return 'Asset Created';
      case 'update_asset':
        return 'Asset Updated';
      case 'delete_asset':
        return 'Asset Deleted';
      case 'photo_delete':
        return 'Photo Deleted';
      default:
        return 'Activity';
    }
  }

  // Method untuk mendapatkan activity type yang lebih readable
  String get readableActivityType {
    switch (activityType) {
      case 'scan_asset':
        return 'Asset Scanning';
      case 'upload_photo':
      case 'photo_upload':
        return 'Photo Upload';
      case 'update_status':
      case 'status_change':
        return 'Status Change';
      case 'import_assets':
        return 'Asset Import';
      case 'search_asset':
        return 'Asset Search';
      case 'view_photos':
        return 'Photo View';
      case 'create_asset':
        return 'Asset Creation';
      case 'update_asset':
        return 'Asset Update';
      case 'delete_asset':
        return 'Asset Deletion';
      case 'photo_delete':
        return 'Photo Deletion';
      default:
        return 'Asset Activity';
    }
  }

  // Method untuk mendapatkan deskripsi yang lebih detail
  String get detailedDescription {
    if (description.isNotEmpty) {
      return description;
    }
    
    switch (activityType) {
      case 'scan_asset':
        return 'Scan asset: $assetCode';
      case 'upload_photo':
      case 'photo_upload':
        return 'Uploaded photo for asset: $assetCode';
      case 'update_status':
      case 'status_change':
        return 'Changed status for asset: $assetCode';
      case 'create_asset':
        return 'Created new asset: $assetCode';
      case 'update_asset':
        return 'Updated asset information: $assetCode';
      case 'delete_asset':
        return 'Deleted asset: $assetCode';
      case 'photo_delete':
        return 'Deleted photo from asset: $assetCode';
      case 'import_assets':
        return 'Imported assets to system';
      case 'search_asset':
        return 'Searched for asset: $assetCode';
      case 'view_photos':
        return 'Viewed photos of asset: $assetCode';
      default:
        return 'Activity performed on asset: $assetCode';
    }
  }
}

class ActivityService {
  final String baseUrl;
  ActivityService({required this.baseUrl});

  // Fetch activities dengan filtering
  Future<List<ActivityLog>> fetchActivities({String? userId}) async {
    String url = '$baseUrl/api/activity-logs';
    if (userId != null && userId.isNotEmpty) {
      url += '?user_id=$userId';
    }
    
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        List<dynamic> data;
        if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
          if (responseData['data'] is List) {
            data = responseData['data'];
          } else if (responseData['data'] is Map) {
            data = [responseData['data']];
          } else {
            data = [];
          }
        } else if (responseData is List) {
          data = responseData;
        } else if (responseData is Map) {
          data = [responseData];
        } else {
          data = [];
        }
        
        return data.map((json) => ActivityLog.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load activities: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load activities: $e');
    }
  }

  // Fetch single activity detail
  Future<ActivityLog?> fetchActivityDetail(int activityId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/activity-logs/$activityId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData is Map<String, dynamic> && responseData['success'] == true && responseData['data'] != null) {
          return ActivityLog.fromJson(responseData['data']);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load activity detail: $e');
    }
  }

  // Fetch activities by asset code
  Future<List<ActivityLog>> fetchActivitiesByAsset(String assetCode) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/activity-logs?asset_code=$assetCode'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        List<dynamic> data;
        if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
          if (responseData['data'] is List) {
            data = responseData['data'];
          } else if (responseData['data'] is Map) {
            data = [responseData['data']];
          } else {
            data = [];
          }
        } else if (responseData is List) {
          data = responseData;
        } else if (responseData is Map) {
          data = [responseData];
        } else {
          data = [];
        }
        
        return data.map((json) => ActivityLog.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load asset activities: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load asset activities: $e');
    }
  }

  // Fetch recent activities with limit
  Future<List<ActivityLog>> fetchRecentActivities({int limit = 20, String? userId}) async {
    String url = '$baseUrl/api/activity-logs?limit=$limit';
    if (userId != null && userId.isNotEmpty) {
      url += '&user_id=$userId';
    }
    
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        List<dynamic> data;
        if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
          if (responseData['data'] is List) {
            data = responseData['data'];
          } else if (responseData['data'] is Map) {
            data = [responseData['data']];
          } else {
            data = [];
          }
        } else if (responseData is List) {
          data = responseData;
        } else if (responseData is Map) {
          data = [responseData];
        } else {
          data = [];
        }
        
        return data.map((json) => ActivityLog.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load recent activities: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load recent activities: $e');
    }
  }
}