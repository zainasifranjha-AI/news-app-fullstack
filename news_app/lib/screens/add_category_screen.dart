import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddCategoryScreen extends StatelessWidget {
  final String token;
  AddCategoryScreen({super.key, required this.token});

  final TextEditingController name = TextEditingController();

  Future<void> addCategory(BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse("https://online-news-app.up.railway.app/api/categories"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json"
        },
        body: {"name": name.text},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Category Added Successfully")),
        );

        name.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed to Add Category")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Category")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: name,
              decoration: InputDecoration(labelText: "Category Name"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => addCategory(context), // ✅ FIX
              child: Text("Add"),
            )
          ],
        ),
      ),
    );
  }
}