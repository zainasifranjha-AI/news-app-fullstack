import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../core/theme/news_theme.dart';
import '../core/widgets/news_image.dart';
import '../services/api_service.dart';
import '../widgets/post_action_bar.dart';
import '../widgets/post_comments_sheet.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  final int categoryId;
  final String categoryName;

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  List<dynamic> posts = [];
  bool loading = true;
  String? loadError;

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    setState(() {
      loading = true;
      loadError = null;
    });
    try {
      final data = await ApiService.getPostsByCategory(widget.categoryId);
      if (!mounted) return;
      setState(() {
        posts = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loadError = e.toString();
        loading = false;
      });
    }
  }

  String _relative(String? iso) {
    if (iso == null) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    return timeago.format(dt.toLocal());
  }

  void _patchPost(int index, Map<String, dynamic> patch) {
    setState(() {
      final m = Map<String, dynamic>.from(posts[index] as Map);
      m.addAll(patch);
      posts[index] = m;
    });
  }

  Future<void> _openComments(int index) async {
    final post = Map<String, dynamic>.from(posts[index] as Map);
    final id = (post['id'] as num).toInt();
    await showPostCommentsSheet(
      context,
      postId: id,
      onCommentCountChanged: (c) => _patchPost(index, {'comments_count': c}),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: fetchPosts,
        child: CustomScrollView(
          slivers: [
            SliverAppBar.medium(
              pinned: true,
              title: Text(widget.categoryName),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: NewsTheme.heroGradient(context),
                  ),
                  child: Text(
                    widget.categoryName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
            ),
            if (loading)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            else if (loadError != null)
              SliverFillRemaining(
                child: Center(child: Text(loadError!, textAlign: TextAlign.center)),
              )
            else if (posts.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    'No stories in this desk yet',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList.separated(
                  itemCount: posts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final post = Map<String, dynamic>.from(posts[index] as Map);
                    final when = _relative(post['created_at'] as String?);
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.35)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          NewsImage(
                            post: post,
                            height: 200,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                          ),
                          if (when.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                              child: Text(
                                when,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: scheme.outline,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(16, when.isNotEmpty ? 6 : 14, 16, 6),
                            child: Text(
                              post['title'] as String? ?? '',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                            child: Text(
                              post['description'] as String? ?? '',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    height: 1.45,
                                    color: scheme.onSurfaceVariant,
                                  ),
                            ),
                          ),
                          PostActionBar(
                            post: post,
                            onEngagementChanged: (patch) => _patchPost(index, patch),
                            onOpenComments: () => _openComments(index),
                          ),
                        ],
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
