import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'posts_screen.dart'; // 🔥 NEW IMPORT

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List categories = [];
  bool isLoading = true;
  String error = "";

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final data = await ApiService.getCategories();

      setState(() {
        categories = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Categories")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(child: Text("Error: $error"))
              : categories.isEmpty
                  ? Center(child: Text("No Categories Found"))
                  : ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];

                        return Card(
                          child: ListTile(
                            title: Text(category['name']),

                            // 🔥 NEW NAVIGATION
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PostsScreen(
                                    categoryId: category['id'],
                                    categoryName: category['name'],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}