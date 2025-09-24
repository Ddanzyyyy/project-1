import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class LostAssetService {
  final String baseUrl;

  LostAssetService({this.baseUrl = "http://192.168.8.144:8000/api"});

  Future<List<Map<String, dynamic>>> fetchLostAssets() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/lost-assets'));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('success') && responseData['success'] == true) {
          final List data = responseData['data'];
          return data.cast<Map<String, dynamic>>();
        } else {
          throw Exception(responseData['message'] ?? 'API returned unsuccessful response');
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching lost assets: $e');
      throw Exception('Gagal mengambil data aset hilang: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchReportableAssets() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/lost-assets/reportable-assets'));
      print('Reportable assets response status: ${response.statusCode}');
      print('Reportable assets response body: ${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('success') && responseData['success'] == true) {
          final List data = responseData['data'];
          return data.cast<Map<String, dynamic>>();
        } else {
          throw Exception(responseData['message'] ?? 'API returned unsuccessful response');
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching reportable assets: $e');
      throw Exception('Gagal mengambil data aset: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchRegisteredAssets() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/assets?status=lost'));
      print('Registered assets response status: ${response.statusCode}');
      print('Registered assets response body: ${response.body}');
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        List<Map<String, dynamic>> assets;
        if (decoded is List) {
          assets = decoded.cast<Map<String, dynamic>>();
        } else if (decoded is Map && decoded.containsKey('data')) {
          final List data = decoded['data'];
          assets = data.cast<Map<String, dynamic>>();
        } else {
          throw Exception('Unexpected response format: $decoded');
        }
        final lostAssets = assets.where((a) =>
          (a['status']?.toString().toLowerCase() == 'lost')).toList();
        return lostAssets;
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching registered assets: $e');
      throw Exception('Gagal mengambil data aset terdaftar: $e');
    }
  }

  /// Submit laporan kehilangan aset
  /// Pastikan assetId adalah ID dari asset yang statusnya masih 'registered' atau 'damaged'
  Future<bool> reportAssetLost({
    required int assetId,
    required String lostCause,
    required String lostChronology,
    required String reportedBy,
    File? lostEvidence,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/lost-assets/report/$assetId');
      var request = http.MultipartRequest('POST', uri)
        ..fields['lost_cause'] = lostCause
        ..fields['lost_chronology'] = lostChronology
        ..fields['reported_by'] = reportedBy;

      if (lostEvidence != null) {
        request.files.add(await http.MultipartFile.fromPath('lost_evidence', lostEvidence.path));
      }

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();
      print('Report lost response status: ${response.statusCode}');
      print('Report lost response body: $responseBody');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(responseBody);
        return responseData['success'] == true;
      } else {
        print('Error response: $responseBody');
        return false;
      }
    } catch (e) {
      print('Error reporting lost asset: $e');
      return false;
    }
  }

  /// Tandai aset hilang sebagai ditemukan
  Future<bool> markAssetFound(int assetId) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/lost-assets/$assetId/found'),
        headers: {'Content-Type': 'application/json'},
      );
      print('Mark found response: ${response.body}');
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error marking asset as found: $e');
      return false;
    }
  }

  /// Ambil detail asset hilang
  Future<Map<String, dynamic>> fetchLostAssetDetail(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/lost-assets/$id'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('success') && responseData['success'] == true) {
          return responseData['data'] as Map<String, dynamic>;
        } else {
          throw Exception(responseData['message'] ?? 'Failed to get asset detail');
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching asset detail: $e');
      throw Exception('Gagal mengambil detail aset: $e');
    }
  }
}