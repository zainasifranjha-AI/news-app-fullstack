import 'package:flutter/material.dart';

import '../core/theme_mode_holder.dart';
import '../services/api_service.dart';
import 'add_category_screen.dart';
import 'add_post_screen.dart';
import 'admin_posts_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key, required this.token});

  final String token;

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<dynamic> categories = [];
  int postCount = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() async {
    setState(() => loading = true);
    try {
      final cats = await ApiService.getCategories();
      final posts = await ApiService.getAllPosts();
      if (!mounted) return;
      setState(() {
        categories = cats;
        postCount = posts.length;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Load error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin'),
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: globalThemeMode,
            builder: (context, mode, _) {
              return IconButton(
                tooltip: 'Theme',
                onPressed: () {
                  globalThemeMode.value = mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
                },
                icon: Icon(mode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
              );
            },
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: refresh,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Categories',
                          value: '${categories.length}',
                          icon: Icons.folder_open,
                          color: scheme.primaryContainer,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'Posts',
                          value: '$postCount',
                          icon: Icons.article_outlined,
                          color: scheme.secondaryContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  FilledButton.tonalIcon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddCategoryScreen(token: widget.token),
                        ),
                      );
                      refresh();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('New category'),
                  ),
                  const SizedBox(height: 10),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdminPostsScreen(token: widget.token),
                        ),
                      );
                    },
                    icon: const Icon(Icons.list_alt),
                    label: const Text('All posts'),
                  ),
                  const SizedBox(height: 24),
                  Text('Categories', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (categories.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'No categories yet — create one to start publishing.',
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    )
                  else
                    ...categories.map((c) {
                      final cat = Map<String, dynamic>.from(c as Map);
                      final id = (cat['id'] as num).toInt();
                      final name = cat['name'] as String? ?? 'Untitled';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?'),
                            ),
                            title: Text(name),
                            trailing: FilledButton(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddPostScreen(
                                      token: widget.token,
                                      categoryId: id,
                                      categoryName: name,
                                    ),
                                  ),
                                );
                                refresh();
                              },
                              child: const Text('Add post'),
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22),
            const SizedBox(height: 12),
            Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
