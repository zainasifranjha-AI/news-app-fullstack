import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/api_service.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key, required this.token});

  final String token;

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final name = TextEditingController();
  bool busy = false;

  Future<void> addCategory() async {
    setState(() => busy = true);
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/categories'),
        headers: {
          ...ApiService.jsonHeaders(token: widget.token),
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'name': name.text}),
      );

      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category added')),
        );
        name.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${response.body}')),
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
      appBar: AppBar(title: const Text('New category')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(
            controller: name,
            decoration: const InputDecoration(labelText: 'Category name'),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: busy ? null : addCategory,
            child: busy
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
    );
  }
}
