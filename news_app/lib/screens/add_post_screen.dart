import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart'; // 🔥 for kIsWeb
import 'dart:io';
import 'dart:typed_data';

class AddPostScreen extends StatefulWidget {
  final String token;
  final int categoryId;

  const AddPostScreen({super.key, 
    required this.token,
    required this.categoryId,
  });

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController caption = TextEditingController();

  File? imageFile;
  Uint8List? webImage;
  final picker = ImagePicker();

  // 🔥 PICK IMAGE
  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      if (kIsWeb) {
        webImage = await picked.readAsBytes();
      } else {
        imageFile = File(picked.path);
      }
      setState(() {});
    }
  }

  // 🔥 IMAGE PREVIEW FUNCTION (OUTSIDE UI)
  Widget imagePreview() {
    if (kIsWeb) {
      if (webImage != null) {
        return Image.memory(webImage!, height: 200);
      } else {
        return SizedBox();
      }
    } else {
      if (imageFile != null) {
        return Image.file(imageFile!, height: 200);
      } else {
        return SizedBox();
      }
    }
  }

  // 🔥 POST DATA
  Future<void> addPost() async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("https://online-news-app.up.railway.app/api/posts"),
    );

    request.headers['Authorization'] = "Bearer ${widget.token}";

    request.fields['title'] = caption.text;
    request.fields['description'] = caption.text;
    request.fields['category_id'] = widget.categoryId.toString();

    // 🔥 IMAGE HANDLE
    if (kIsWeb && webImage != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          webImage!,
          filename: "upload.jpg",
        ),
      );
    } else if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile!.path),
      );
    }

    var response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Post Added")),
      );

      caption.clear();
      setState(() {
        imageFile = null;
        webImage = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Post"),
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            // 🔥 IMAGE PREVIEW (CALL FUNCTION)
            imagePreview(),

            SizedBox(height: 10),

            // 🔥 PICK IMAGE BUTTON
            ElevatedButton(
              onPressed: pickImage,
              child: Text("Select Image"),
            ),

            SizedBox(height: 15),

            // 🔥 CAPTION FIELD
            TextField(
              controller: caption,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Write a caption...",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 20),

            // 🔥 POST BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: addPost,
                child: Text("Post"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}