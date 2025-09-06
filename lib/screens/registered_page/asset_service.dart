import 'dart:convert';
import 'dart:io';
import 'package:Simba/screens/setting_screen/notification_service.dart';
import 'package:http/http.dart' as http;
import 'asset_model.dart';

const String apiUrl = "http://192.168.1.9:8000/api/assets";

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
      final newAsset = Asset.fromJson(jsonDecode(respStr));
      if (newAsset.status == 'damaged' || newAsset.status == 'lost') {
        await NotificationService.notifyAssetStatusChange(newAsset.name, newAsset.status);
      }
      return newAsset;
    } else {
      throw Exception('Failed to add asset: ${response.statusCode} - $respStr');
    }
  }

  static Future<Asset> updateAsset(Asset asset, {File? imageFile}) async {
    if (asset.id.isEmpty) {
      throw Exception('Asset ID cannot be empty');
    }
    var uri = Uri.parse('$apiUrl/${asset.id}');
    Asset updatedAsset;
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
        updatedAsset = Asset.fromJson(jsonDecode(respStr));
      } else {
        throw Exception('Failed to update asset: ${response.statusCode} - $respStr');
      }
    } else {
      // PATCH biasa
      final Map<String, dynamic> updateBody = asset.toJson();
      updateBody.remove('id');
      final response = await http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updateBody),
      );
      if (response.statusCode == 200) {
        updatedAsset = Asset.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update asset: ${response.body}');
      }
    }
    // Notif jika status critical
    if (updatedAsset.status == 'damaged' || updatedAsset.status == 'lost') {
      await NotificationService.notifyAssetStatusChange(updatedAsset.name, updatedAsset.status);
    }
    return updatedAsset;
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

  static Future<Asset> updateAssetStatus(String assetId, String newStatus, {String? assetName}) async {
    try {
      final assets = await getAssets();
      final asset = assets.firstWhere((a) => a.id == assetId);
      final updatedAsset = Asset(
        id: asset.id,
        name: asset.name,
        category: asset.category,
        description: asset.description,
        imagePath: asset.imagePath,
        dateAdded: asset.dateAdded,
        assetCode: asset.assetCode,
        location: asset.location,
        createdAt: asset.createdAt,
        pic: asset.pic,
        status: newStatus,
      );
      final result = await updateAsset(updatedAsset);
      if (newStatus == 'damaged' || newStatus == 'lost') {
        final name = assetName ?? result.name;
        await NotificationService.notifyAssetStatusChange(name, newStatus);
      }
      return result;
    } catch (e) {
      print('Error updating asset status: $e');
      throw Exception('Failed to update asset status: $e');
    }
  }

  static Future<List<Asset>> getAssetsByStatus(String status) async {
    try {
      final assets = await getAssets();
      return assets.where((asset) => asset.status.toLowerCase() == status.toLowerCase()).toList();
    } catch (e) {
      print('Error getting assets by status: $e');
      return [];
    }
  }
}