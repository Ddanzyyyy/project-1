import 'package:http/http.dart' as http;
import 'dart:convert';
import 'asset_item.dart'; 

class UnscannedAssetService {
  static String baseUrl = "http://192.168.8.131:8000/api";

  static Future<List<AssetItem>> fetchUnscannedAssets({
    required String auditId,
    String? search,
    String? category,
  }) async {
    try {
      String url = "$baseUrl/audit/$auditId/unscanned-assets";
      Map<String, String> queryParams = {};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (category != null && category != "All") queryParams['category'] = category;
      if (queryParams.isNotEmpty) url += "?" + Uri(queryParameters: queryParams).query;

      print("Fetching URL: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      print("Status Code: ${response.statusCode}");
      print("Response Headers: ${response.headers}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        // Check if response is JSON
        if (_isJsonResponse(response)) {
          final parsed = json.decode(response.body);
          if (parsed is List) {
            final filtered = parsed.where((e) => e['status'] == 'unscanned').toList();
            return filtered.map((e) => AssetItem.fromJson(e)).toList();
          } else if (parsed is Map && parsed['data'] is List) {
            // Handle if response is wrapped in data object
            final List data = parsed['data'];
            final filtered = data.where((e) => e['status'] == 'unscanned').toList();
            return filtered.map((e) => AssetItem.fromJson(e)).toList();
          } else {
            throw Exception('Response format tidak valid');
          }
        } else {
          throw Exception('Server mengembalikan HTML, bukan JSON. Periksa endpoint API.');
        }
      } else {
        String errorMessage = _extractErrorMessage(response);
        throw Exception('Failed to load assets (${response.statusCode}): $errorMessage');
      }
    } catch (e) {
      print("Error in fetchUnscannedAssets: $e");
      rethrow;
    }
  }

  static Future<bool> scanAsset(String auditId, String assetCode) async {
    try {
      final url = "$baseUrl/audit/$auditId/scan";
      print("Scan URL: $url");
      print("Asset Code: $assetCode");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: json.encode({"asset_code": assetCode}),
      );

      print("Scan Status Code: ${response.statusCode}");
      print("Scan Response Headers: ${response.headers}");
      print("Scan Response Body: ${response.body}");

      if (_isJsonResponse(response)) {
        final body = json.decode(response.body);
        
        if (response.statusCode == 200) {
          // Check various success indicators
          if (body['success'] == true || 
              body['status'] == 'success' || 
              body['message']?.toString().toLowerCase().contains('berhasil') == true) {
            return true;
          } else {
            throw Exception(body['message'] ?? 'Gagal scan asset');
          }
        } else if (response.statusCode == 422) {
          // Validation error
          String errorMsg = _extractValidationErrors(body);
          throw Exception(errorMsg);
        } else {
          throw Exception(body['message'] ?? 'Gagal scan asset (${response.statusCode})');
        }
      } else {
        String errorMessage = _extractErrorMessage(response);
        throw Exception('Server error: $errorMessage');
      }
    } catch (e) {
      print("Error in scanAsset: $e");
      rethrow;
    }
  }

  static Future<bool> manualScanAsset(String auditId, String assetId) async {
    try {
      final url = "$baseUrl/audit/$auditId/manual-scan";
      print("Manual Scan URL: $url");
      print("Asset ID: $assetId");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: json.encode({"asset_id": assetId}),
      );

      print("Manual Scan Status Code: ${response.statusCode}");
      print("Manual Scan Response Headers: ${response.headers}");
      print("Manual Scan Response Body: ${response.body}");

      if (_isJsonResponse(response)) {
        final body = json.decode(response.body);
        
        if (response.statusCode == 200) {
          // Check various success indicators
          if (body['success'] == true || 
              body['status'] == 'success' || 
              body['message']?.toString().toLowerCase().contains('berhasil') == true) {
            return true;
          } else {
            throw Exception(body['message'] ?? 'Gagal menandai manual');
          }
        } else if (response.statusCode == 422) {
          // Validation error
          String errorMsg = _extractValidationErrors(body);
          throw Exception(errorMsg);
        } else if (response.statusCode == 404) {
          throw Exception('Endpoint tidak ditemukan. Periksa route di Laravel.');
        } else {
          throw Exception(body['message'] ?? 'Gagal menandai manual (${response.statusCode})');
        }
      } else {
        String errorMessage = _extractErrorMessage(response);
        throw Exception('Server error: $errorMessage');
      }
    } catch (e) {
      print("Error in manualScanAsset: $e");
      rethrow;
    }
  }

  // Helper method to check if response is JSON
  static bool _isJsonResponse(http.Response response) {
    final contentType = response.headers['content-type'];
    return contentType != null && contentType.contains('application/json');
  }

  static String _extractErrorMessage(http.Response response) {
    if (response.statusCode == 404) {
      return 'Endpoint tidak ditemukan (404)';
    } else if (response.statusCode == 500) {
      return 'Server error (500)';
    } else if (response.body.contains('<!DOCTYPE html>')) {
      final RegExp titleRegex = RegExp(r'<title>(.*?)</title>');
      final match = titleRegex.firstMatch(response.body);
      if (match != null) {
        return 'Server error: ${match.group(1)}';
      }
      return 'Server mengembalikan halaman HTML error';
    } else {
      return response.body.length > 200 
          ? '${response.body.substring(0, 200)}...' 
          : response.body;
    }
  }

  // Helper method to extract validation errors
  static String _extractValidationErrors(Map<String, dynamic> body) {
    if (body['errors'] != null && body['errors'] is Map) {
      Map<String, dynamic> errors = body['errors'];
      List<String> errorMessages = [];
      errors.forEach((key, value) {
        if (value is List) {
          errorMessages.addAll(value.map((e) => e.toString()));
        } else {
          errorMessages.add(value.toString());
        }
      });
      return errorMessages.join(', ');
    }
    return body['message'] ?? 'Validation error';
  }
  static Future<List<AssetItem>> fetchScannedHistory({required String auditId}) async {
  final url = "$baseUrl/audit/$auditId/scanned-history";
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final parsed = json.decode(response.body);
      if (parsed is List) {
        return parsed.map<AssetItem>((e) => AssetItem.fromJson(e)).toList();
      } else {
        throw Exception('Format response tidak valid');
      }
    } else {
      throw Exception('Gagal mengambil riwayat: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error mengambil riwayat: $e');
  }
}
}

