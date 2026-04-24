import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'add_category_screen.dart';
import 'add_post_screen.dart';
import 'package:news_app/screens/admin_posts_screen.dart';

class AdminDashboard extends StatefulWidget {
  final String token;

  const AdminDashboard({super.key, required this.token});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  // 🔥 FETCH CATEGORIES
  Future<void> fetchCategories() async {
    final response = await http.get(
      Uri.parse("http://127.0.0.1:8000/api/categories"),
      headers: {"Accept": "application/json"},
    );

    final data = jsonDecode(response.body);

    setState(() {
      categories = data['data'];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Panel"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // 🔹 ADD CATEGORY
            Card(
              elevation: 4,
              child: ListTile(
                leading: Icon(Icons.category, color: Colors.blue),
                title: Text("Add Category"),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddCategoryScreen(token: widget.token),
                    ),
                  );

                  fetchCategories(); // 🔥 AUTO REFRESH
                },
              ),
            ),

            SizedBox(height: 10),

            // 🔹 VIEW POSTS
            Card(
              elevation: 4,
              child: ListTile(
                leading: Icon(Icons.list, color: Colors.purple),
                title: Text("View All Posts"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminPostsScreen(token: widget.token),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 20),

            // 🔥 CATEGORY LIST
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : categories.isEmpty
                      ? Center(child: Text("No Categories Found"))
                      : ListView.builder(
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final cat = categories[index];

                            return Card(
                              elevation: 4,
                              child: ListTile(
                                leading: Icon(Icons.folder, color: Colors.orange),
                                title: Text(cat['name']),
                                trailing: ElevatedButton(
                                  child: Text("Add Post"),
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AddPostScreen(
                                          token: widget.token,
                                          categoryId: cat['id'],
                                        ),
                                      ),
                                    );

                                    fetchCategories(); // 🔥 REFRESH AFTER POST
                                  },
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}