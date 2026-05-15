import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/api_service.dart';

class EditPostScreen extends StatefulWidget {
  const EditPostScreen({
    super.key,
    required this.postId,
    required this.token,
  });

  final int postId;
  final String token;

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final title = TextEditingController();
  final description = TextEditingController();
  List<dynamic> categories = [];
  int? categoryId;
  File? imageFile;
  Uint8List? webImage;
  final picker = ImagePicker();
  bool loading = true;
  bool saving = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final cats = await ApiService.getCategories();
      final post = await ApiService.getPost(widget.postId);
      if (!mounted) return;
      title.text = post['title'] as String? ?? '';
      description.text = post['description'] as String? ?? '';
      final cat = post['category'];
      if (cat is Map) {
        categoryId = (cat['id'] as num?)?.toInt();
      }
      setState(() {
        categories = cats;
        final ids = cats.map((c) => ((c as Map)['id'] as num).toInt()).toSet();
        if (categoryId != null && !ids.contains(categoryId)) {
          categoryId = ids.isNotEmpty ? ids.first : null;
        }
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  Future<void> _pick() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    if (kIsWeb) {
      webImage = await picked.readAsBytes();
    } else {
      imageFile = File(picked.path);
    }
    setState(() {});
  }

  Future<void> _save() async {
    if (categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pick a category')));
      return;
    }
    setState(() => saving = true);
    try {
      await ApiService.updatePost(
        postId: widget.postId,
        token: widget.token,
        title: title.text.trim(),
        description: description.text.trim(),
        categoryId: categoryId,
        imagePath: kIsWeb ? null : imageFile?.path,
        imageBytes: kIsWeb ? webImage : null,
        imageFilename: kIsWeb && webImage != null ? 'cover.jpg' : null,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit post')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    OutlinedButton.icon(
                      onPressed: _pick,
                      icon: const Icon(Icons.image_outlined),
                      label: const Text('Change cover image'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: categoryId,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: categories.map((c) {
                        final m = Map<String, dynamic>.from(c as Map);
                        final id = (m['id'] as num).toInt();
                        final name = m['name'] as String? ?? '';
                        return DropdownMenuItem(value: id, child: Text(name));
                      }).toList(),
                      onChanged: (v) => setState(() => categoryId = v),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: title,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: description,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        labelText: 'Body',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: saving ? null : _save,
                      child: saving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save changes'),
                    ),
                  ],
                ),
    );
  }
}
