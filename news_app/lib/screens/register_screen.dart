import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/api_service.dart';
import '../services/auth_store.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  bool busy = false;

  Future<void> register() async {
    setState(() => busy = true);
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/register'),
        headers: ApiService.jsonHeaders(),
        body: {
          'name': name.text,
          'email': email.text,
          'password': password.text,
          'password_confirmation': password.text,
        },
      );

      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final token = data['token'] as String?;
        if (token != null) {
          int? userId;
          var role = 'user';
          if (data['user'] != null) {
            final u = Map<String, dynamic>.from(data['user'] as Map);
            userId = (u['id'] as num?)?.toInt();
            role = u['role'] as String? ?? 'user';
          }
          await AuthStore.saveToken(token);
          await AuthStore.saveProfile(userId: userId, role: role);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registered — you can sign in now')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${response.body}')),
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
      appBar: AppBar(title: const Text('Register')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
          const SizedBox(height: 12),
          TextField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: password,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password'),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: busy ? null : register,
            child: busy
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Register'),
          ),
        ],
      ),
    );
  }
}
