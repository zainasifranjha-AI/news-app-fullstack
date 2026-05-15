import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../services/api_service.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({
    super.key,
    required this.token,
    required this.categoryId,
    this.categoryName,
  });

  final String token;
  final int categoryId;
  final String? categoryName;

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final title = TextEditingController();
  final description = TextEditingController();
  File? imageFile;
  Uint8List? webImage;
  final picker = ImagePicker();
  bool busy = false;

  Future<void> pickImage() async {
    try {
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;
      if (kIsWeb) {
        webImage = await picked.readAsBytes();
      } else {
        imageFile = File(picked.path);
      }
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Picker error: $e')));
    }
  }

  Widget imagePreview() {
    if (kIsWeb) {
      if (webImage == null) return const SizedBox.shrink();
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(webImage!, height: 200, width: double.infinity, fit: BoxFit.cover),
      );
    }
    if (imageFile == null) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(imageFile!, height: 200, width: double.infinity, fit: BoxFit.cover),
    );
  }

  Future<void> addPost() async {
    setState(() => busy = true);
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.baseUrl}/posts'),
      );
      request.headers.addAll(ApiService.jsonHeaders(token: widget.token));
      request.fields['title'] = title.text.trim();
      request.fields['description'] = description.text.trim();
      request.fields['category_id'] = widget.categoryId.toString();

      if (kIsWeb && webImage != null) {
        request.files.add(
          http.MultipartFile.fromBytes('image', webImage!, filename: 'upload.jpg'),
        );
      } else if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile!.path),
        );
      }

      final streamed = await request.send();
      final body = await streamed.stream.bytesToString();

      if (!mounted) return;
      if (streamed.statusCode == 200 || streamed.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post published')));
        title.clear();
        description.clear();
        setState(() {
          imageFile = null;
          webImage = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed (${streamed.statusCode}): $body')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName == null ? 'New post' : 'Post · ${widget.categoryName}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          imagePreview(),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: pickImage,
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: const Text('Cover image'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: title,
            decoration: const InputDecoration(labelText: 'Headline'),
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
            onPressed: busy ? null : addPost,
            child: busy
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Publish'),
          ),
        ],
      ),
    );
  }
}
