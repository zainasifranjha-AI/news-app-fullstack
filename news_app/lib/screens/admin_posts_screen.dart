import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminPostsScreen extends StatefulWidget {
  final String token;

  const AdminPostsScreen({super.key, required this.token});

  @override
  State<AdminPostsScreen> createState() => _AdminPostsScreenState();
}

class _AdminPostsScreenState extends State<AdminPostsScreen> {
  List posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    final response = await http.get(
      Uri.parse("http://127.0.0.1:8000/api/posts"),
      headers: {"Accept": "application/json"},
    );

    setState(() {
      posts = jsonDecode(response.body);
      isLoading = false;
    });
  }

  Future<void> deletePost(int id) async {
    await http.delete(
      Uri.parse("http://127.0.0.1:8000/api/posts/$id"),
      headers: {
        "Authorization": "Bearer ${widget.token}"
      },
    );

    fetchPosts(); // 🔥 refresh
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("All Posts")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];

                return Card(
                  child: ListTile(
                    title: Text(post['title']),
                    subtitle: Text(post['description']),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deletePost(post['id']),
                    ),
                  ),
                );
              },
            ),
    );
  }
}