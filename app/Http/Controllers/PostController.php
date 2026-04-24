<?php

namespace App\Http\Controllers;

use App\Models\Post;
use Illuminate\Http\Request;

class PostController extends Controller
{
    // Create Post (Admin)
    public function store(Request $request)
    {
        $request->validate([
            'title' => 'required|string',
            'description' => 'required|string',
            'category_id' => 'required|exists:categories,id',
            'image' => 'nullable|image',
        ]);

        $imagePath = null;

        if ($request->hasFile('image')) {
            $imagePath = $request->file('image')->store('posts', 'public');
        }

        $post = Post::create([
            'title' => $request->title,
            'description' => $request->description,
            'category_id' => $request->category_id,
            'user_id' => 1, // admin id
            'image' => $imagePath,
        ]);

        return response()->json([
            'message' => 'Post created successfully',
            'data' => $post
        ]);
    }

    // Get all posts
    public function index()
    {
        return response()->json(Post::with('category')->latest()->get());
    }

    // Get posts by category
    public function byCategory($id)
    {
        $posts = Post::where('category_id', $id)->get();

        return response()->json($posts);
    }
}