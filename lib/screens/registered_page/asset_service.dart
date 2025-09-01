import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'asset_model.dart';

const String apiUrl = "http://192.168.8.131:8000/api/assets";

class AssetService {
  static Future<List<Asset>> getAssets({String? search, String? category}) async {
    String url = apiUrl;
    Map<String, String> params = {};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (category != null && category != "All") params['category'] = category;
    if (params.isNotEmpty) {
      url += "?" + Uri(queryParameters: params).query;
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => Asset.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load assets');
    }
  }

  static Future<Asset> addAsset(Asset asset, {File? imageFile}) async {
    var uri = Uri.parse(apiUrl);
    var request = http.MultipartRequest('POST', uri);
    request.fields['name'] = asset.name;
    request.fields['category'] = asset.category;
    if (asset.description.isNotEmpty) request.fields['description'] = asset.description;
    request.fields['date_added'] = asset.dateAdded;
    request.fields['asset_code'] = asset.assetCode; 
    request.fields['location'] = asset.location;     
    request.fields['pic'] = asset.pic;               
    request.fields['status'] = asset.status;         

    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    }
    var response = await request.send();
    final respStr = await response.stream.bytesToString();
    if (response.statusCode == 201) {
      return Asset.fromJson(jsonDecode(respStr));
    } else {
      throw Exception('Failed to add asset: ${response.statusCode} - $respStr');
    }
  }

  /// Update asset ke API (support gambar baru)
  static Future<Asset> updateAsset(Asset asset, {File? imageFile}) async {
    if (asset.id.isEmpty) {
      throw Exception('Asset ID cannot be empty');
    }
    var uri = Uri.parse('$apiUrl/${asset.id}');
    if (imageFile != null) {
      var request = http.MultipartRequest('POST', uri);
      request.fields['_method'] = 'PATCH';
      request.fields['name'] = asset.name;
      request.fields['category'] = asset.category;
      if (asset.description.isNotEmpty) request.fields['description'] = asset.description;
      if (asset.dateAdded.isNotEmpty) request.fields['date_added'] = asset.dateAdded;
      request.fields['asset_code'] = asset.assetCode;
      request.fields['location'] = asset.location;
      request.fields['pic'] = asset.pic;
      request.fields['status'] = asset.status;
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      var response = await request.send();
      final respStr = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        return Asset.fromJson(jsonDecode(respStr));
      } else {
        throw Exception('Failed to update asset: ${response.statusCode} - $respStr');
      }
    } else {
      // Jika tidak ada gambar baru, gunakan PATCH biasa
      final Map<String, dynamic> updateBody = asset.toJson();
      // Make sure only fields needed by backend are sent
      updateBody.remove('id');
      final response = await http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updateBody),
      );
      if (response.statusCode == 200) {
        return Asset.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update asset: ${response.body}');
      }
    }
  }

  /// Hapus asset dari API
  static Future<void> deleteAsset(String id) async {
    if (id.isEmpty) {
      throw Exception('Asset ID cannot be empty');
    }
    final response = await http.delete(Uri.parse('$apiUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete asset: ${response.body}');
    }
  }
}