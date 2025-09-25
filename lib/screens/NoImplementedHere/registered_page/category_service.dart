import 'dart:convert';
import 'package:http/http.dart' as http;

const String categoryUrl = "http://192.168.1.4:8000/api/categories/";

class CategoryService {
  static Future<List<String>> getCategories() async {
    final response = await http.get(Uri.parse(categoryUrl));
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map<String>((e) => e['name'].toString()).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  static Future<bool> addCategory(String name) async {
    final response = await http.post(
      Uri.parse(categoryUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name}),
    );
    return response.statusCode == 201;
  }
}