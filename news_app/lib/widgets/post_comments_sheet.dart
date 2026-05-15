import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../services/api_service.dart';
import '../services/auth_store.dart';

Future<void> showPostCommentsSheet(
  BuildContext context, {
  required int postId,
  required void Function(int newCommentsCount) onCommentCountChanged,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => _PostCommentsBody(
      postId: postId,
      onCommentCountChanged: onCommentCountChanged,
    ),
  );
}

class _PostCommentsBody extends StatefulWidget {
  const _PostCommentsBody({
    required this.postId,
    required this.onCommentCountChanged,
  });

  final int postId;
  final void Function(int newCommentsCount) onCommentCountChanged;

  @override
  State<_PostCommentsBody> createState() => _PostCommentsBodyState();
}

class _PostCommentsBodyState extends State<_PostCommentsBody> {
  List<dynamic> comments = [];
  final bodyCtrl = TextEditingController();
  bool loading = true;
  bool posting = false;
  int? myUserId;
  String? myRole;

  @override
  void initState() {
    super.initState();
    _load();
    _loadMe();
  }

  @override
  void dispose() {
    bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMe() async {
    final id = await AuthStore.userId();
    final r = await AuthStore.role();
    if (mounted) setState(() {
      myUserId = id;
      myRole = r;
    });
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final list = await ApiService.getComments(widget.postId);
      if (mounted) {
        setState(() {
          comments = list;
          loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _submit() async {
    final token = await AuthStore.token();
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign in to comment')),
        );
      }
      return;
    }
    final text = bodyCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => posting = true);
    try {
      await ApiService.addComment(widget.postId, token, text);
      bodyCtrl.clear();
      await _load();
      widget.onCommentCountChanged(comments.length);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Posted')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => posting = false);
    }
  }

  Future<void> _delete(int commentId) async {
    final token = await AuthStore.token();
    if (token == null) return;
    try {
      final res = await ApiService.deleteComment(commentId, token);
      await _load();
      final c = res['comments_count'];
      if (c is int) {
        widget.onCommentCountChanged(c);
      } else if (c is num) {
        widget.onCommentCountChanged(c.toInt());
      } else {
        widget.onCommentCountChanged(comments.length);
      }
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Removed')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  String _ago(String? iso) {
    if (iso == null) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    return timeago.format(dt.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.55,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Comments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const Divider(),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (context, i) {
                        final c = Map<String, dynamic>.from(comments[i] as Map);
                        final id = (c['id'] as num).toInt();
                        final user = Map<String, dynamic>.from(c['user'] as Map? ?? {});
                        final name = user['name'] as String? ?? 'User';
                        final uid = (user['id'] as num?)?.toInt();
                        final canDelete =
                            myUserId != null && (uid == myUserId || myRole == 'admin');
                        return ListTile(
                          title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c['body'] as String? ?? ''),
                              Text(
                                _ago(c['created_at'] as String?),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                          trailing: canDelete
                              ? IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  onPressed: () => _delete(id),
                                )
                              : null,
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: bodyCtrl,
                      minLines: 1,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Write a comment…',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  posting
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton.filled(
                          onPressed: _submit,
                          icon: const Icon(Icons.send),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
