import 'dart:convert';
import 'package:http/http.dart' as http;

import 'auth_store.dart';

class ApiService {
  ApiService._();

  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api',
  );

  static String get origin {
    var o = baseUrl.trim();
    if (o.endsWith('/api')) {
      o = o.substring(0, o.length - 4);
    } else if (o.endsWith('/api/')) {
      o = o.substring(0, o.length - 5);
    }
    while (o.endsWith('/')) {
      o = o.substring(0, o.length - 1);
    }
    return o;
  }

  static Map<String, String> jsonHeaders({String? token}) {
    return {
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<String?> _authHeader() async {
    return await AuthStore.token();
  }

  /// Prefer `image_storage_path` (always under app root) + [origin] so URLs match
  /// Flutter BASE_URL / XAMPP subpaths / Android emulator hosts. Fixes wrong APP_URL in JSON.
  static String? resolvePostImageUrl(Map<String, dynamic> post) {
    final storagePath = post['image_storage_path'];
    if (storagePath is String && storagePath.isNotEmpty) {
      final p = storagePath.startsWith('/') ? storagePath : '/$storagePath';
      return '$origin$p'.replaceAll(RegExp(r'(?<!:)/{2,}'), '/');
    }

    final direct = post['image_url'];
    if (direct is String && direct.isNotEmpty) {
      final d = direct.trim();
      if (d.startsWith('http://') || d.startsWith('https://')) {
        return _rewriteLocalhostImageUrl(d);
      }
      if (d.startsWith('/')) {
        return '$origin$d'.replaceAll(RegExp(r'(?<!:)/{2,}'), '/');
      }
    }

    final path = post['image'];
    if (path is! String || path.isEmpty) {
      return null;
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return _rewriteLocalhostImageUrl(path);
    }
    var clean = path.replaceFirst(RegExp(r'^/+'), '');
    if (clean.startsWith('storage/')) {
      clean = clean.substring('storage/'.length);
    }
    return '$origin/storage/$clean'.replaceAll(RegExp(r'(?<!:)/{2,}'), '/');
  }

  /// If API returned http://localhost/... but app talks to 10.0.2.2, swap host to [origin]'s host.
  static String _rewriteLocalhostImageUrl(String url) {
    try {
      final u = Uri.parse(url);
      final o = Uri.parse(origin);
      const localHosts = {'localhost', '127.0.0.1', '0.0.0.0'};
      if (localHosts.contains(u.host) && !localHosts.contains(o.host)) {
        return u.replace(host: o.host, port: o.hasPort ? o.port : null).toString();
      }
    } catch (_) {}
    return url;
  }

  static Future<List<dynamic>> getCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/categories'),
      headers: jsonHeaders(),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load categories (${response.statusCode})');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['data'] as List<dynamic>?) ?? [];
  }

  static Future<List<dynamic>> getPostsByCategory(int categoryId) async {
    final t = await _authHeader();
    final response = await http.get(
      Uri.parse('$baseUrl/posts/category/$categoryId'),
      headers: jsonHeaders(token: t),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load posts (${response.statusCode})');
    }
    return jsonDecode(response.body) as List<dynamic>;
  }

  static Future<List<dynamic>> getLatestPosts() async {
    final t = await _authHeader();
    final response = await http.get(
      Uri.parse('$baseUrl/posts/latest'),
      headers: jsonHeaders(token: t),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load latest (${response.statusCode})');
    }
    return jsonDecode(response.body) as List<dynamic>;
  }

  static Future<List<dynamic>> getAllPosts() async {
    final t = await _authHeader();
    final response = await http.get(
      Uri.parse('$baseUrl/posts'),
      headers: jsonHeaders(token: t),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load posts (${response.statusCode})');
    }
    return jsonDecode(response.body) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> getPost(int id) async {
    final t = await _authHeader();
    final response = await http.get(
      Uri.parse('$baseUrl/posts/$id'),
      headers: jsonHeaders(token: t),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load post (${response.statusCode})');
    }
    return Map<String, dynamic>.from(jsonDecode(response.body) as Map);
  }

  static Future<Map<String, dynamic>> toggleLike(int postId, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts/$postId/like'),
      headers: jsonHeaders(token: token),
    );
    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
    return Map<String, dynamic>.from(jsonDecode(response.body) as Map);
  }

  static Future<Map<String, dynamic>> toggleDislike(int postId, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts/$postId/dislike'),
      headers: jsonHeaders(token: token),
    );
    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
    return Map<String, dynamic>.from(jsonDecode(response.body) as Map);
  }

  static Future<List<dynamic>> getComments(int postId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts/$postId/comments'),
      headers: jsonHeaders(),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load comments');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return (body['data'] as List<dynamic>?) ?? [];
  }

  static Future<void> addComment(int postId, String token, String body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts/$postId/comments'),
      headers: {
        ...jsonHeaders(token: token),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'body': body}),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(response.body);
    }
  }

  static Future<Map<String, dynamic>> deleteComment(int commentId, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/comments/$commentId'),
      headers: jsonHeaders(token: token),
    );
    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
    return Map<String, dynamic>.from(jsonDecode(response.body) as Map);
  }

  static Future<Map<String, dynamic>> updatePost({
    required int postId,
    required String token,
    String? title,
    String? description,
    int? categoryId,
    String? imagePath,
    List<int>? imageBytes,
    String? imageFilename,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/posts/$postId/update'),
    );
    request.headers.addAll(jsonHeaders(token: token));
    if (title != null) request.fields['title'] = title;
    if (description != null) request.fields['description'] = description;
    if (categoryId != null) request.fields['category_id'] = '$categoryId';
    if (imagePath != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    } else if (imageBytes != null && imageFilename != null) {
      request.files.add(
        http.MultipartFile.fromBytes('image', imageBytes, filename: imageFilename),
      );
    }
    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();
    if (streamed.statusCode != 200) {
      throw Exception(body);
    }
    final decoded = jsonDecode(body) as Map<String, dynamic>;
    final inner = decoded['data'];
    if (inner is Map) {
      return Map<String, dynamic>.from(inner as Map);
    }
    return decoded;
  }
}
