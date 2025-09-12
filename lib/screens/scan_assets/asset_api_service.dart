import 'dart:convert';
import 'package:Simba/screens/scan_assets/asset.dart';
import 'package:http/http.dart' as http;

class AssetApiService {
  static const String baseUrl = 'http://192.168.1.8:8000/api';
  
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<Asset?> getAssetByQr(String qrCode) async {
    try {
      print('🔍 Searching for asset with QR Code: $qrCode');
      
      final url = '$baseUrl/assets/qr?qr_code=${Uri.encodeComponent(qrCode)}';
      print('📡 API URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      
      print('📊 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final dynamic rawData = json.decode(response.body);
        
        // Proper type casting
        if (rawData is Map<String, dynamic>) {
          print('✅ Asset found: ${rawData['name']} (ID: ${rawData['id']})');
          return Asset.fromJson(rawData);
        } else if (rawData is Map) {
          // Convert Map<dynamic, dynamic> to Map<String, dynamic>
          final Map<String, dynamic> data = Map<String, dynamic>.from(rawData);
          print('✅ Asset found (converted): ${data['name']} (ID: ${data['id']})');
          return Asset.fromJson(data);
        } else {
          print('⚠️ Unexpected response format: ${rawData.runtimeType}');
          return null;
        }
      } else if (response.statusCode == 404) {
        print('❌ Asset not found in database');
        return null;
      } else {
        print('⚠️ API Error: ${response.statusCode}');
        throw Exception('Error scanning QR: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Exception in getAssetByQr: $e');
      throw Exception('Error scanning QR: $e');
    }
  }

  // Alternative search method by asset code
  static Future<Asset?> getAssetByAssetCode(String assetCode) async {
    try {
      print('🔍 Searching for asset with Asset Code: $assetCode');
      
      final urls = [
        '$baseUrl/assets/qr?qr_code=$assetCode',
        '$baseUrl/assets/qr?asset_code=$assetCode', 
        '$baseUrl/assets?search=$assetCode',
      ];
      
      for (String url in urls) {
        print('📡 Trying URL: $url');
        
        final response = await http.get(
          Uri.parse(url),
          headers: headers,
        );
        
        print('📊 Response Status: ${response.statusCode}');
        print('📄 Response Body: ${response.body}');
        
        if (response.statusCode == 200) {
          final dynamic rawData = json.decode(response.body);
          
          // Handle different response formats with proper casting
          if (rawData is List) {
            if (rawData.isNotEmpty) {
              final dynamic firstItem = rawData.first;
              if (firstItem is Map<String, dynamic>) {
                print('✅ Asset found in array: ${firstItem['name']}');
                return Asset.fromJson(firstItem);
              } else if (firstItem is Map) {
                final Map<String, dynamic> data = Map<String, dynamic>.from(firstItem);
                print('✅ Asset found in array (converted): ${data['name']}');
                return Asset.fromJson(data);
              }
            }
          } else if (rawData is Map<String, dynamic>) {
            print('✅ Asset found: ${rawData['name']}');
            return Asset.fromJson(rawData);
          } else if (rawData is Map) {
            final Map<String, dynamic> data = Map<String, dynamic>.from(rawData);
            print('✅ Asset found (converted): ${data['name']}');
            return Asset.fromJson(data);
          }
        }
      }
      
      print('❌ Asset not found in any endpoint');
      return null;
    } catch (e) {
      print('💥 Exception in getAssetByAssetCode: $e');
      throw Exception('Error searching asset: $e');
    }
  }

  // Get all assets with proper type casting
  static Future<List<Asset>> getAssets({String? search, String? category}) async {
    try {
      String url = '$baseUrl/assets';
      Map<String, String> queryParams = {};
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (category != null && category != 'All') {
        queryParams['category'] = category;
      }
      
      if (queryParams.isNotEmpty) {
        url += '?' + queryParams.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
      }

      print('📡 Loading assets from: $url');
      final response = await http.get(Uri.parse(url), headers: headers);
      
      if (response.statusCode == 200) {
        final dynamic rawData = json.decode(response.body);
        
        if (rawData is List) {
          List<Asset> assets = [];
          for (dynamic item in rawData) {
            if (item is Map<String, dynamic>) {
              assets.add(Asset.fromJson(item));
            } else if (item is Map) {
              final Map<String, dynamic> data = Map<String, dynamic>.from(item);
              assets.add(Asset.fromJson(data));
            }
          }
          print('✅ Loaded ${assets.length} assets');
          return assets;
        } else {
          throw Exception('Unexpected response format: expected List, got ${rawData.runtimeType}');
        }
      } else {
        throw Exception('Failed to fetch assets: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching assets: $e');
    }
  }

  // Add asset with proper type casting
  static Future<Asset> addAsset(Asset asset) async {
    try {
      print('📝 Adding asset: ${asset.name}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/assets'),
        headers: headers,
        body: json.encode(asset.toJson()),
      );
      
      print('📊 Add Asset Response Status: ${response.statusCode}');
      print('📄 Add Asset Response Body: ${response.body}');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final dynamic rawData = json.decode(response.body);
        
        if (rawData is Map<String, dynamic>) {
          return Asset.fromJson(rawData);
        } else if (rawData is Map) {
          final Map<String, dynamic> data = Map<String, dynamic>.from(rawData);
          return Asset.fromJson(data);
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        final dynamic errorData = json.decode(response.body);
        String errorMessage = 'Unknown error';
        
        if (errorData is Map && errorData.containsKey('message')) {
          errorMessage = errorData['message'].toString();
        }
        
        throw Exception('Failed to add asset: $errorMessage');
      }
    } catch (e) {
      print('💥 Exception in addAsset: $e');
      throw Exception('Error adding asset: $e');
    }
  }

  // Update asset with proper type casting
  static Future<Asset> updateAsset(int id, Asset asset) async {
    try {
      print('📝 Updating asset ID: $id');
      
      final response = await http.put(
        Uri.parse('$baseUrl/assets/$id'),
        headers: headers,
        body: json.encode(asset.toJson()),
      );
      
      print('📊 Update Asset Response Status: ${response.statusCode}');
      print('📄 Update Asset Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final dynamic rawData = json.decode(response.body);
        
        if (rawData is Map<String, dynamic>) {
          return Asset.fromJson(rawData);
        } else if (rawData is Map) {
          final Map<String, dynamic> data = Map<String, dynamic>.from(rawData);
          return Asset.fromJson(data);
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        final dynamic errorData = json.decode(response.body);
        String errorMessage = 'Unknown error';
        
        if (errorData is Map && errorData.containsKey('message')) {
          errorMessage = errorData['message'].toString();
        }
        
        throw Exception('Failed to update asset: $errorMessage');
      }
    } catch (e) {
      print('💥 Exception in updateAsset: $e');
      throw Exception('Error updating asset: $e');
    }
  }

  // Delete asset
  static Future<void> deleteAsset(int id) async {
    try {
      print('🗑️ Deleting asset ID: $id');
      
      final response = await http.delete(
        Uri.parse('$baseUrl/assets/$id'),
        headers: headers,
      );
      
      print('📊 Delete Asset Response Status: ${response.statusCode}');
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        final dynamic errorData = json.decode(response.body);
        String errorMessage = 'Unknown error';
        
        if (errorData is Map && errorData.containsKey('message')) {
          errorMessage = errorData['message'].toString();
        }
        
        throw Exception('Failed to delete asset: $errorMessage');
      }
    } catch (e) {
      print('Exception in deleteAsset: $e');
      throw Exception('Error deleting asset: $e');
    }
  }
}