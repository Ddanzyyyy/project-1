import 'dart:convert';
import 'package:http/http.dart' as http;

// Asset detail model
class AssetDetail {
  final String assetCode;
  final String assetName;
  final String? imageUrl;
  final String? category;
  final String? location;
  final String? status;
  final String? dateAdded;
  final String? activityTime;

  AssetDetail({
    required this.assetCode,
    required this.assetName,
    this.imageUrl,
    this.category,
    this.location,
    this.status,
    this.dateAdded,
    this.activityTime,
  });

  factory AssetDetail.fromJson(Map<String, dynamic> json) {
    return AssetDetail(
      assetCode: json['asset_code'] ?? '',
      assetName: json['description'] ?? '',
      imageUrl: json['image_path'],
      category: json['category'],
      location: json['location'],
      status: json['status'],
      dateAdded: json['date_added'],
      activityTime: json['activity_time'],
    );
  }
}

class ActivityLog {
  final int id;
  final String activityType;
  final String description;
  final String assetCode;
  final DateTime activityTime;
  final AssetDetail assetDetail;

  ActivityLog({
    required this.id,
    required this.activityType,
    required this.description,
    required this.assetCode,
    required this.activityTime,
    required this.assetDetail,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'],
      activityType: json['activity_type'] ?? '',
      description: json['description'] ?? '',
      assetCode: json['asset_code'] ?? '',
      activityTime: DateTime.parse(json['activity_time'] ?? json['created_at']),
      assetDetail: AssetDetail.fromJson(json),
    );
  }
}

class ActivityService {
  final String baseUrl;
  ActivityService({required this.baseUrl});

  Future<List<ActivityLog>> fetchActivities({required String userId}) async {
    final url = Uri.parse('$baseUrl/api/activity-logs?user_id=$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => ActivityLog.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load activities');
    }
  }
}