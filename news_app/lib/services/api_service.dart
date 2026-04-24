import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // 🔥 DYNAMIC BASE URL (future safe)
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://localhost:8000/api',
  );

  // 🔥 BASE URL WITHOUT /api (for images)
  static String get base {
    return baseUrl.replaceAll('/api', '');
  }

  // 🔥 GET CATEGORIES
  static Future<List<dynamic>> getCategories() async {
    try {
      print("CALLING CATEGORIES API...");

      final response = await http.get(
        Uri.parse("$baseUrl/categories"),
        headers: {
          "Accept": "application/json",
        },
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        throw Exception("Failed to load categories");
      }
    } catch (e) {
      print("ERROR: $e");
      throw Exception(e.toString());
    }
  }

  // 🔥 GET POSTS BY CATEGORY
  static Future<List<dynamic>> getPostsByCategory(int categoryId) async {
    try {
      print("CALLING POSTS API...");

      final response = await http.get(
        Uri.parse("$baseUrl/posts/category/$categoryId"),
        headers: {
          "Accept": "application/json",
        },
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load posts");
      }
    } catch (e) {
      print("ERROR: $e");
      throw Exception(e.toString());
    }
  }

  // 🔥 IMAGE URL HELPER (VERY IMPORTANT)
  static String getImageUrl(String path) {
    return "$base/storage/$path";
  }
}