import 'dart:convert';
// import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'damage_report_model.dart';

const String baseUrl = "http://192.168.8.138:8000/api";

class DamageReportService {
  static Future<List<DamageReport>> getDamageReports(
      {required String assetId}) async {
    final url = "$baseUrl/assets/$assetId/damage-reports";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => DamageReport.fromJson(e)).toList();
    } else {
      throw Exception("Gagal mengambil data laporan kerusakan");
    }
  }

  static Future<bool> createDamageReport({
    required String assetId,
    required String description,
    required String status,
    String? imageUrl,
  }) async {
    final url = "$baseUrl/damage-reports";
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "asset_id": assetId,
        "description": description,
        "status": status,
        "image_url": imageUrl,
      }),
    );
    return response.statusCode == 201;
  }

  // Update status laporan kerusakan
  static Future<bool> updateDamageReportStatus(
      String reportId, String status) async {
    final url = "$baseUrl/damage-reports/$reportId";
    final response = await http.put(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"status": status}),
    );
    return response.statusCode == 200;
  }

  static Future<String?> uploadImage(XFile? imageFile) async {
    if (imageFile == null) return null;
    final url = "$baseUrl/upload-image";
    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.files
        .add(await http.MultipartFile.fromPath('image', imageFile.path));
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('Upload status: ${response.statusCode}');
    print('Upload body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['url'];
    } else {
      throw Exception("Gagal upload gambar");
    }
  }

  static Future<bool> addImagesToDamageReport(
    String reportId,
    List<String> imageUrls,
    String notes,
  ) async {
    final url = Uri.parse(
      //API Damage Report Add Image
        '$baseUrl/damage-reports/$reportId/add-images');
    final body = {
      'additional_images': imageUrls,
      'notes': notes,
    };
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      print('addImages response: ${response.statusCode}');
      print('addImages body: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('Error addImagesToDamageReport: $e');
      return false;
    }
  }

  static Future<bool> deleteDamageReport(String reportId) async {
    final url = "$baseUrl/damage-reports/$reportId";
    final response = await http.delete(Uri.parse(url));
    return response.statusCode == 204;
  }
}
