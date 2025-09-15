import 'dart:convert';
import 'package:Simba/screens/home_screen/logistic_asset/logistic_asset_model.dart';
import 'package:Simba/screens/scan_assets/asset.dart';
import 'package:http/http.dart' as http;

/// Service untuk membaca data asset yang sudah di-import ke sistem (LogisticAsset).
/// Semua endpoint disesuaikan agar membaca data dari backend yang sudah terupdate,
/// khususnya dari tabel logistic_assets, termasuk asset hasil import dari Excel.

class AssetApiService {
  static const String baseUrl = 'http://192.168.8.138:8000/api';

  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<Asset?> getAssetByQr(String qrCode) async {
    try {
      print('🔍 Searching for asset (logistic_assets) with QR Code: $qrCode');
      final url = '$baseUrl/logistic-assets/qr?qr_code=${Uri.encodeComponent(qrCode)}';
      print('📡 API URL: $url');

      final response = await http.get(Uri.parse(url), headers: headers);

      print('📊 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic rawData = json.decode(response.body);

        // Backend sebaiknya mengembalikan Map<String, dynamic>
        if (rawData is Map<String, dynamic>) {
          print('✅ LogisticAsset found: ${rawData['title']} (Asset No: ${rawData['asset_no']})');
          return Asset.fromJson(rawData);
        } else if (rawData is Map) {
          final Map<String, dynamic> data = Map<String, dynamic>.from(rawData);
          print('✅ LogisticAsset found (converted): ${data['title']}');
          return Asset.fromJson(data);
        } else {
          print('⚠️ Unexpected response format: ${rawData.runtimeType}');
          return null;
        }
      } else if (response.statusCode == 404) {
        print('❌ Asset not found in logistic_assets');
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

  /// Ambil asset berdasarkan asset_no (kode asset) di logistic_assets
  static Future<Asset?> getAssetByAssetCode(String assetCode) async {
    try {
      print('🔍 Searching for logistic asset with Asset Code: $assetCode');

      // Prioritaskan endpoint logistic-assets
      final urls = [
        '$baseUrl/logistic-assets/qr?qr_code=$assetCode',
        '$baseUrl/logistic-assets?search=$assetCode',
      ];

      for (String url in urls) {
        print('📡 Trying URL: $url');

        final response = await http.get(Uri.parse(url), headers: headers);

        print('📊 Response Status: ${response.statusCode}');
        print('📄 Response Body: ${response.body}');

        if (response.statusCode == 200) {
          final dynamic rawData = json.decode(response.body);

          // Jika backend mengembalikan list (pencarian)
          if (rawData is List) {
            if (rawData.isNotEmpty) {
              final dynamic firstItem = rawData.first;
              if (firstItem is Map<String, dynamic>) {
                print('✅ LogisticAsset found in array: ${firstItem['title']}');
                return Asset.fromJson(firstItem);
              } else if (firstItem is Map) {
                final Map<String, dynamic> data = Map<String, dynamic>.from(firstItem);
                print('✅ LogisticAsset found in array (converted): ${data['title']}');
                return Asset.fromJson(data);
              }
            }
          }
          // Jika backend mengembalikan satu asset
          else if (rawData is Map<String, dynamic>) {
            print('✅ LogisticAsset found: ${rawData['title']}');
            return Asset.fromJson(rawData);
          } else if (rawData is Map) {
            final Map<String, dynamic> data = Map<String, dynamic>.from(rawData);
            print('✅ LogisticAsset found (converted): ${data['title']}');
            return Asset.fromJson(data);
          }
        }
      }

      print('❌ LogisticAsset not found in any endpoint');
      return null;
    } catch (e) {
      print('💥 Exception in getAssetByAssetCode: $e');
      throw Exception('Error searching asset: $e');
    }
  }

  /// Ambil semua asset di logistic_assets, termasuk hasil import Excel
  static Future<List<Asset>> getAssets({String? search, String? category}) async {
    try {
      String url = '$baseUrl/logistic-assets';
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
          print('✅ Loaded ${assets.length} assets (from logistic_assets)');
          return assets;
        } else if (rawData is Map<String, dynamic> && rawData.containsKey('data')) {
          // Jika API mengembalikan { data: [...] }
          final dataList = rawData['data'];
          if (dataList is List) {
            List<Asset> assets = [];
            for (dynamic item in dataList) {
              if (item is Map<String, dynamic>) {
                assets.add(Asset.fromJson(item));
              } else if (item is Map) {
                final Map<String, dynamic> data = Map<String, dynamic>.from(item);
                assets.add(Asset.fromJson(data));
              }
            }
            print('✅ Loaded ${assets.length} assets (from logistic_assets.data)');
            return assets;
          }
        }
        throw Exception('Unexpected response format: expected List, got ${rawData.runtimeType}');
      } else {
        throw Exception('Failed to fetch assets: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching assets: $e');
    }
  }

  /// Tambah asset ke logistic_assets (opsional, biasanya lewat import Excel di backend)
  static Future<Asset> addAsset(Asset asset) async {
    try {
      print('📝 Adding asset to logistic_assets: ${asset.name}');
      final response = await http.post(
        Uri.parse('$baseUrl/logistic-assets'),
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

  /// Update asset di logistic_assets
  static Future<Asset> updateAsset(String assetNo, Asset asset) async {
    try {
      print('📝 Updating logistic asset Asset No: $assetNo');
      final response = await http.put(
        Uri.parse('$baseUrl/logistic-assets/$assetNo'),
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

  /// Hapus asset dari logistic_assets
  static Future<void> deleteAsset(String assetNo) async {
    try {
      print('🗑️ Deleting logistic asset Asset No: $assetNo');
      final response = await http.delete(
        Uri.parse('$baseUrl/logistic-assets/$assetNo'),
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
  /// GET asset photos by assetId
static Future<List<AssetPhoto>> getAssetPhotos(String assetId) async {
    try {
      final url = '$baseUrl/logistic-assets/$assetId/photos';
      print('📡 Loading asset photos from: $url');
      final response = await http.get(Uri.parse(url), headers: headers);

      print('📊 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic rawData = json.decode(response.body);

        // Jika backend mengirimkan { success: true, data: [...] }
        if (rawData is Map<String, dynamic> && rawData.containsKey('data')) {
          final dataList = rawData['data'];
          if (dataList is List) {
            List<AssetPhoto> photos = [];
            for (dynamic item in dataList) {
              if (item is Map<String, dynamic>) {
                photos.add(AssetPhoto.fromJson(item));
              } else if (item is Map) {
                final Map<String, dynamic> data = Map<String, dynamic>.from(item);
                photos.add(AssetPhoto.fromJson(data));
              }
            }
            print('✅ Loaded ${photos.length} asset photos');
            return photos;
          }
        }
        // Jika backend mengirimkan langsung List (jarang)
        else if (rawData is List) {
          List<AssetPhoto> photos = [];
          for (dynamic item in rawData) {
            if (item is Map<String, dynamic>) {
              photos.add(AssetPhoto.fromJson(item));
            } else if (item is Map) {
              final Map<String, dynamic> data = Map<String, dynamic>.from(item);
              photos.add(AssetPhoto.fromJson(data));
            }
          }
          print('✅ Loaded ${photos.length} asset photos');
          return photos;
        }
        throw Exception('Unexpected response format for asset photos: ${rawData.runtimeType}');
      } else {
        throw Exception('Failed to load asset photos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}