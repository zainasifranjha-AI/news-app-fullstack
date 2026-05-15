import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../core/widgets/news_image.dart';
import '../services/api_service.dart';
import '../widgets/post_comments_sheet.dart';
import 'edit_post_screen.dart';

class AdminPostsScreen extends StatefulWidget {
  const AdminPostsScreen({super.key, required this.token});

  final String token;

  @override
  State<AdminPostsScreen> createState() => _AdminPostsScreenState();
}

class _AdminPostsScreenState extends State<AdminPostsScreen> {
  List<dynamic> posts = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    setState(() => loading = true);
    try {
      final list = await ApiService.getAllPosts();
      if (!mounted) return;
      setState(() {
        posts = list;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> confirmDelete(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete post?'),
        content: const Text('This removes the story and its image from storage.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;

    final response = await http.delete(
      Uri.parse('${ApiService.baseUrl}/posts/$id'),
      headers: ApiService.jsonHeaders(token: widget.token),
    );

    if (!mounted) return;
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleted')));
      fetchPosts();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: ${response.statusCode} ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All posts'),
        actions: [
          IconButton(onPressed: fetchPosts, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : posts.isEmpty
              ? Center(
                  child: Text(
                    'No posts yet',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchPosts,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: posts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final post = Map<String, dynamic>.from(posts[index] as Map);
                      final id = (post['id'] as num).toInt();
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 96,
                                height: 72,
                                child: NewsImage(
                                  post: post,
                                  height: 72,
                                  width: 96,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      post['title'] as String? ?? '',
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      post['description'] as String? ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () async {
                                  final ok = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditPostScreen(
                                        postId: id,
                                        token: widget.token,
                                      ),
                                    ),
                                  );
                                  if (ok == true) fetchPosts();
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.chat_bubble_outline),
                                onPressed: () => showPostCommentsSheet(
                                  context,
                                  postId: id,
                                  onCommentCountChanged: (_) => fetchPosts(),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () => confirmDelete(id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
