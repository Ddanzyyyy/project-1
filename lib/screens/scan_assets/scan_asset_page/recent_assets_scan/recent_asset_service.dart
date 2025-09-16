import 'dart:convert';
import 'package:Simba/screens/scan_assets/scan_asset_page/recent_assets_scan/recent_asset_model.dart';
import 'package:http/http.dart' as http;

class RecentAssetService {
  static const String baseUrl = 'http://192.168.1.4:8000/api';

  static Future<bool> saveRecentAsset(String assetNo, String scannedBy) async {
    final url = '$baseUrl/recent-assets';
    final body = json.encode({
      'asset_no': assetNo,
      'scanned_by': scannedBy,
    });
    
    print("DEBUG: Sending POST to $url");
    print("DEBUG: Request body: $body");
    print("DEBUG: Headers: Content-Type: application/json, Accept: application/json");
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );
      
      print("DEBUG: Save recent asset response status: ${response.statusCode}");
      print("DEBUG: Save recent asset response body: ${response.body}");
      
      if (response.statusCode == 201) {
        print("DEBUG: ✅ Recent asset saved successfully");
        return true;
      } else {
        print("DEBUG: ❌ Failed to save recent asset: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("DEBUG: ❌ Exception saving recent asset: $e");
      return false;
    }
  }

  static Future<List<RecentAsset>> getRecentAssets({String? scannedBy}) async {
    String url = '$baseUrl/recent-assets';
    if (scannedBy != null) {
      url += '?scanned_by=$scannedBy';
    }
    
    print("DEBUG: Getting recent assets from: $url");
    print("DEBUG: Filtering by scanned_by: $scannedBy");
    
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      print("DEBUG: Get recent assets response status: ${response.statusCode}");
      print("DEBUG: Get recent assets response body: ${response.body}");
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print("DEBUG: Parsed JSON response: $jsonResponse");
        
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final List<dynamic> dataList = jsonResponse['data'] as List;
          print("DEBUG: Found ${dataList.length} recent assets in response");
          
          final List<RecentAsset> recentAssets = dataList.map((e) {
            print("DEBUG: Processing recent asset item: $e");
            return RecentAsset.fromJson(e);
          }).toList();
          
          print("DEBUG: ✅ Successfully parsed ${recentAssets.length} recent assets");
          return recentAssets;
        } else {
          print("DEBUG: ❌ Invalid response format or no data");
          return [];
        }
      } else {
        print("DEBUG: ❌ Failed to get recent assets: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("DEBUG: ❌ Exception getting recent assets: $e");
      return [];
    }
  }

  static Future<bool> updatePhotosCount(int recentAssetId) async {
    final url = '$baseUrl/recent-assets/$recentAssetId/photos-count';
    
    print("DEBUG: Updating photos count for recent asset ID: $recentAssetId");
    print("DEBUG: PATCH URL: $url");
    
    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      print("DEBUG: Update photos count response status: ${response.statusCode}");
      print("DEBUG: Update photos count response body: ${response.body}");
      
      if (response.statusCode == 200) {
        print("DEBUG: ✅ Photos count updated successfully");
        return true;
      } else {
        print("DEBUG: ❌ Failed to update photos count: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("DEBUG: ❌ Exception updating photos count: $e");
      return false;
    }
  }
}