import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'admin_dashboard.dart';
import 'categories_screen.dart';
import 'package:news_app/screens/register_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  Future<void> login() async {
    try {
      print("🔵 LOGIN START");

      final response = await http.post(
        Uri.parse("https://online-news-app.up.railway.app/api/login"),
        headers: {"Accept": "application/json"},
        body: {
          "email": email.text,
          "password": password.text,
        },
      );

      print("🟢 STATUS: ${response.statusCode}");
      print("🟡 BODY: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        String token = data['token'];

        // ✅ SAFE ROLE FETCH
        String role = "user";
        if (data.containsKey('user') && data['user'] != null) {
          role = data['user']['role'] ?? 'user';
        }

        print("✅ LOGIN SUCCESS");
        print("🔑 TOKEN: $token");
        print("👤 ROLE: $role");

        if (role == "admin") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AdminDashboard(token: token),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CategoriesScreen(),
            ),
          );
        }
      } else {
        print("❌ LOGIN FAILED");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Login Failed: ${data.toString()}"),
          ),
        );
      }
    } catch (e) {
      print("🔥 ERROR: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Center(
        child: Container(
          width: 300,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Login", style: TextStyle(fontSize: 22)),
              SizedBox(height: 20),

              TextField(
                controller: email,
                decoration: InputDecoration(labelText: "Email"),
              ),

              TextField(
                controller: password,
                obscureText: true,
                decoration: InputDecoration(labelText: "Password"),
              ),

              SizedBox(height: 20),

              ElevatedButton(
                onPressed: login,
                child: Text("Login"),
              ),

              SizedBox(height: 10),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RegisterScreen(),
                    ),
                  );
                },
                child: Text("Create New Account"),
              )
            ],
          ),
        ),
      ),
    );
  }
}