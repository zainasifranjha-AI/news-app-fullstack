import 'package:flutter/material.dart';

import '../core/theme/news_theme.dart';
import '../core/theme_mode_holder.dart';
import '../core/widgets/news_image.dart';
import '../services/api_service.dart';
import '../services/auth_store.dart';
import 'admin_login_screen.dart';
import 'posts_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<dynamic> categories = [];
  List<dynamic> latest = [];
  bool loading = true;
  String error = '';
  String query = '';
  bool signedIn = false;

  @override
  void initState() {
    super.initState();
    _session();
    load();
  }

  Future<void> _session() async {
    final t = await AuthStore.token();
    if (mounted) setState(() => signedIn = t != null && t.isNotEmpty);
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = '';
    });
    try {
      final cats = await ApiService.getCategories();
      List<dynamic> lat = [];
      try {
        lat = await ApiService.getLatestPosts();
      } catch (_) {
        lat = [];
      }
      if (!mounted) return;
      setState(() {
        categories = cats;
        latest = lat;
        loading = false;
      });
      await _session();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  List<dynamic> get _filtered {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return categories;
    return categories.where((c) {
      final m = Map<String, dynamic>.from(c as Map);
      final name = (m['name'] as String? ?? '').toLowerCase();
      return name.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: load,
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              pinned: true,
              title: const Text('News'),
              actions: [
                if (signedIn)
                  IconButton(
                    tooltip: 'Sign out',
                    onPressed: () async {
                      await AuthStore.clearSession();
                      if (!context.mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                        (_) => false,
                      );
                    },
                    icon: const Icon(Icons.logout),
                  ),
                ValueListenableBuilder<ThemeMode>(
                  valueListenable: globalThemeMode,
                  builder: (context, mode, _) {
                    return IconButton(
                      onPressed: () {
                        globalThemeMode.value = mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
                      },
                      icon: Icon(mode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
                    );
                  },
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: NewsTheme.heroGradient(context),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today’s brief',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                              letterSpacing: 1.2,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Stories that matter,\nin one calm place.',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              height: 1.15,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (latest.isNotEmpty)
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                      child: Text('Trending', style: Theme.of(context).textTheme.titleMedium),
                    ),
                    SizedBox(
                      height: 220,
                      child: PageView.builder(
                        padEnds: true,
                        controller: PageController(viewportFraction: 0.88),
                        itemCount: latest.length.clamp(0, 8),
                        itemBuilder: (context, i) {
                          final post = Map<String, dynamic>.from(latest[i] as Map);
                          final cat = post['category'];
                          final catName = cat is Map ? (cat['name'] as String? ?? '') : '';
                          return Padding(
                            padding: const EdgeInsets.only(left: 12, right: 4, bottom: 8),
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  NewsImage(post: post, height: 120),
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (catName.isNotEmpty)
                                          Text(
                                            catName.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 11,
                                              letterSpacing: 0.8,
                                              color: scheme.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        Text(
                                          post['title'] as String? ?? '',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (latest.isNotEmpty) _BreakingStrip(latest: latest),
                  ],
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: TextField(
                  onChanged: (v) => setState(() => query = v),
                  decoration: InputDecoration(
                    hintText: 'Search categories…',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                  ),
                ),
              ),
            ),
            if (loading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (error.isNotEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(error, textAlign: TextAlign.center),
                  ),
                ),
              )
            else if (_filtered.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    categories.isEmpty ? 'No categories yet' : 'No matches',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                sliver: SliverList.separated(
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final cat = Map<String, dynamic>.from(_filtered[index] as Map);
                    final id = (cat['id'] as num).toInt();
                    final name = cat['name'] as String? ?? 'Category';
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PostsScreen(
                                categoryId: id,
                                categoryName: name,
                              ),
                            ),
                          );
                        },
                        child: Ink(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [
                                scheme.surfaceContainerHighest.withValues(alpha: 0.9),
                                scheme.surface.withValues(alpha: 0.4),
                              ],
                            ),
                            border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                            child: Row(
                              children: [
                                Icon(Icons.folder_special_outlined, color: scheme.primary, size: 28),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    name,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                                Icon(Icons.chevron_right, color: scheme.outline),
                              ],
                            ),
                          ),
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

class _BreakingStrip extends StatelessWidget {
  const _BreakingStrip({required this.latest});

  final List<dynamic> latest;

  @override
  Widget build(BuildContext context) {
    final titles = latest
        .map((e) => Map<String, dynamic>.from(e as Map)['title'] as String?)
        .whereType<String>()
        .toList();
    if (titles.isEmpty) return const SizedBox.shrink();
    final text = titles.join('   ·   ');
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 12),
      child: Material(
        color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.35),
        child: SizedBox(
          height: 40,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.bolt, size: 18, color: Theme.of(context).colorScheme.error),
                  const SizedBox(width: 8),
                  Text(
                    'LIVE',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(text, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
