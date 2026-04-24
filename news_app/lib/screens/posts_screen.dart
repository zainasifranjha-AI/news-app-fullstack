import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PostsScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const PostsScreen({super.key, required this.categoryId, required this.categoryName});

  @override
  _PostsScreenState createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  List posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    try {
      final data =
          await ApiService.getPostsByCategory(widget.categoryId);

      setState(() {
        posts = data;
        isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryName)),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : posts.isEmpty
              ? Center(child: Text("No News Found"))
              : ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];

                    return Card(
                      margin: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🔥 IMAGE
                          if (post['image'] != null)
                            Image.network(
                              (ApiService.getImageUrl(post['image'])),
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),

                          Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              post['title'],
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(post['description']),
                          ),

                          SizedBox(height: 10),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}