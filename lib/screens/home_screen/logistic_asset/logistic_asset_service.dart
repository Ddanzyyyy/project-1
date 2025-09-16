import 'dart:convert';
import 'dart:io';
import 'package:Simba/screens/home_screen/logistic_asset/logistic_asset_model.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class LogisticAssetService {
  static const String baseUrl = 'http://192.168.1.4:8000/api';

  static Future<List<LogisticAsset>> getLogisticAssets({
    String search = '',
    String category = 'All',
  }) async {
    try {
      final queryParams = <String, String>{};
      if (search.isNotEmpty) queryParams['search'] = search;
      if (category != 'All') queryParams['category'] = category;

      final uri = Uri.parse('$baseUrl/logistic-assets')
          .replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> data = jsonData['data'] ?? [];
        return data.map((json) => LogisticAsset.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load logistic assets');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<LogisticAsset?> getLogisticAssetByAssetNo(String assetNo) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/logistic-assets/asset-no/$assetNo'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return LogisticAsset.fromJson(jsonData['data']);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to get logistic asset');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<AssetPhoto>> getAssetPhotos(String assetNo) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/logistic-assets/assets/$assetNo/photos'),
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> data = jsonData['data'] ?? [];
        return data.map((json) => AssetPhoto.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load asset photos');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> importExcel(File file) async {
    try {
      final request =
          http.MultipartRequest('POST', Uri.parse('$baseUrl/logistic-assets/import'));
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      print ('Import response: $responseBody');
      if (responseBody.isEmpty) {
        throw Exception('Empty response from server');
      }
      final jsonData = json.decode(responseBody);

      if (response.statusCode == 200) {
        return jsonData;
      } else {
        throw Exception(jsonData['message'] ?? 'Import failed');
      }
    } catch (e) {
      throw Exception('Import error: $e');
    }
  }

  static Future<List<String>> getCategories() async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/logistic-assets/categories'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> data = jsonData['data'] ?? [];
        return data.map((item) => item.toString()).toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>?> uploadPhotoDio({
    required String assetNo,
    required File file,
    bool isPrimary = false,
    String? caption,
  }) async {
    try {
      if (!await file.exists()) {
        print('File does not exist: ${file.path}');
        return null;
      }

      String? mimeType = lookupMimeType(file.path);
      if (mimeType == null || !mimeType.startsWith('image/')) {
        print('Invalid file type: $mimeType');
        return null;
      }

      final dio = Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Accept': 'application/json',
        },
      ));

      FormData formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
          contentType: MediaType.parse(mimeType),
        ),
        'is_primary': isPrimary ? '1' : '0',
        if (caption != null && caption.isNotEmpty) 'caption': caption,
      });

      print('Uploading to: $baseUrl/logistic-assets/assets/$assetNo/photos');
      print('File: ${file.path}');
      print('File size: ${await file.length()} bytes');

      final response = await dio.post(
        '/logistic-assets/assets/$assetNo/photos',
        data: formData,
      );

      print('Status code: ${response.statusCode}');
      print('Response: ${response.data}');

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        if (response.data['success'] == true) {
          return response.data['data'];
        }
      }

      return null;
    } catch (e) {
      print('Dio upload error: $e');
      if (e is DioException) {
        print('DioError type: ${e.type}');
        print('DioError message: ${e.message}');
        print('DioError response: ${e.response?.data}');
      }
      return null;
    }
  }

  static Future<Map<String, dynamic>?> uploadPhoto({
    required String assetNo,
    required File file,
    bool isPrimary = false,
    String? caption,
  }) async {
    try {
      if (!await file.exists()) {
        print('File does not exist: ${file.path}');
        return null;
      }

      String? mimeType = lookupMimeType(file.path);
      if (mimeType == null || !mimeType.startsWith('image/')) {
        print('Invalid file type: $mimeType');
        return null;
      }

      final url = Uri.parse('$baseUrl/logistic-assets/assets/$assetNo/photos');
      final request = http.MultipartRequest('POST', url);

      request.files.add(await http.MultipartFile.fromPath(
        'photo',
        file.path,
        filename: file.path.split('/').last,
        contentType: MediaType.parse(mimeType),
      ));

      request.fields['is_primary'] = isPrimary ? '1' : '0';
      if (caption != null && caption.isNotEmpty) {
        request.fields['caption'] = caption;
      }
      request.headers['Accept'] = 'application/json';

      print('Uploading to: ${url.toString()}');
      print('File path: ${file.path}');
      print('File size: ${await file.length()} bytes');
      print('MIME type: $mimeType');

      final response = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Upload timeout');
        },
      );

      final responseBody = await response.stream.bytesToString();
      print('Status code: ${response.statusCode}');
      print('Response body: $responseBody');

      if (responseBody.isEmpty) {
        print('Empty response body');
        return null;
      }

      final jsonData = json.decode(responseBody);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          jsonData['success'] == true) {
        return jsonData['data'];
      }
      return null;
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  static Future<bool> updateAssetStatus({
    required String assetId,
    required String status,
    int? available,
    int? broken,
    int? lost,
    String? remarks,
  }) async {
    try {
      final dio = Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 25),
        headers: {
          'Accept': 'application/json',
        },
      ));

      final data = <String, dynamic>{
        'asset_status': status,
        if (available != null) 'available': available,
        if (broken != null) 'broken': broken,
        if (lost != null) 'lost': lost,
        if (remarks != null) 'remarks': remarks,
      };

      final response = await dio.patch(
        '/logistic-assets/$assetId/status',
        data: data,
      );
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      print('Error updating asset status: $e');
      return false;
    }
  }
}