import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../services/api_service.dart';
import '../services/auth_store.dart';

class PostActionBar extends StatefulWidget {
  const PostActionBar({
    super.key,
    required this.post,
    required this.onEngagementChanged,
    required this.onOpenComments,
  });

  final Map<String, dynamic> post;
  final void Function(Map<String, dynamic> patch) onEngagementChanged;
  final VoidCallback onOpenComments;

  @override
  State<PostActionBar> createState() => _PostActionBarState();
}

class _PostActionBarState extends State<PostActionBar> with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 220));
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  int _i(String key) {
    final v = widget.post[key];
    if (v is int) return v;
    if (v is num) return v.toInt();
    return 0;
  }

  bool _b(String key) => widget.post[key] == true;

  Future<void> _needAuth() async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sign in to react or comment')),
    );
  }

  Future<void> _like() async {
    final token = await AuthStore.token();
    if (token == null) return _needAuth();
    try {
      _pulse.forward(from: 0);
      final patch = await ApiService.toggleLike((widget.post['id'] as num).toInt(), token);
      widget.onEngagementChanged(patch);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _dislike() async {
    final token = await AuthStore.token();
    if (token == null) return _needAuth();
    try {
      _pulse.forward(from: 0);
      final patch = await ApiService.toggleDislike((widget.post['id'] as num).toInt(), token);
      widget.onEngagementChanged(patch);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _share() async {
    final id = (widget.post['id'] as num).toInt();
    final title = widget.post['title'] as String? ?? '';
    final desc = widget.post['description'] as String? ?? '';
    final img = ApiService.resolvePostImageUrl(widget.post);
    final link = '${ApiService.origin}/api/posts/$id';
    final text = '$title\n\n$desc\n\n${img ?? ''}\n\n$link';
    await Share.share(text, subject: title);
  }

  Future<void> _copyLink() async {
    final id = (widget.post['id'] as num).toInt();
    final link = '${ApiService.origin}/api/posts/$id';
    await Clipboard.setData(ClipboardData(text: link));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link copied')));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final likes = _i('likes_count');
    final dislikes = _i('dislikes_count');
    final comments = _i('comments_count');
    final liked = _b('liked_by_auth_user');
    final disliked = _b('disliked_by_auth_user');

    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 1.04).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeOut)),
      child: Material(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            children: [
              _chip(
                icon: Icons.thumb_up_alt_outlined,
                activeIcon: Icons.thumb_up,
                active: liked,
                count: likes,
                onTap: _like,
                color: scheme.primary,
              ),
              _chip(
                icon: Icons.thumb_down_alt_outlined,
                activeIcon: Icons.thumb_down,
                active: disliked,
                count: dislikes,
                onTap: _dislike,
                color: scheme.error,
              ),
              _chip(
                icon: Icons.mode_comment_outlined,
                activeIcon: Icons.mode_comment,
                active: false,
                count: comments,
                onTap: widget.onOpenComments,
                color: scheme.secondary,
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Share',
                onPressed: _share,
                icon: const Icon(Icons.share_outlined),
              ),
              IconButton(
                tooltip: 'Copy link',
                onPressed: _copyLink,
                icon: const Icon(Icons.link),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip({
    required IconData icon,
    required IconData activeIcon,
    required bool active,
    required int count,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(active ? activeIcon : icon, size: 20, color: active ? color : null),
            const SizedBox(width: 4),
            Text('$count', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
