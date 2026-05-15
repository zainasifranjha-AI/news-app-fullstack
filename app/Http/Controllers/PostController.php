<?php

namespace App\Http\Controllers;

use App\Models\Post;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\PersonalAccessToken;

class PostController extends Controller
{
    protected function optionalUser(Request $request): ?User
    {
        $bearer = $request->bearerToken();
        if (! $bearer) {
            return null;
        }

        $accessToken = PersonalAccessToken::findToken($bearer);

        return $accessToken?->tokenable instanceof User ? $accessToken->tokenable : null;
    }

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
            'user_id' => $request->user()->id,
            'image' => $imagePath,
        ]);

        $user = $request->user();
        $post->load('category')->loadCount(['likes', 'dislikes', 'comments']);
        if ($user) {
            $post->loadExists([
                'likes as liked_by_auth_user' => fn ($q) => $q->where('user_id', $user->id),
                'dislikes as disliked_by_auth_user' => fn ($q) => $q->where('user_id', $user->id),
            ]);
        }

        return response()->json([
            'message' => 'Post created successfully',
            'data' => $post,
        ], 201);
    }

    public function show(Request $request, int $id)
    {
        $user = $this->optionalUser($request);
        $post = Post::query()
            ->with('category')
            ->withEngagement($user)
            ->findOrFail($id);

        return response()->json($post);
    }

    public function index(Request $request)
    {
        $user = $this->optionalUser($request);

        return response()->json(
            Post::query()->with('category')->withEngagement($user)->latest()->get()
        );
    }

    public function latest(Request $request)
    {
        $user = $this->optionalUser($request);

        return response()->json(
            Post::query()->with('category')->withEngagement($user)->latest()->take(12)->get()
        );
    }

    public function byCategory(Request $request, $id)
    {
        $user = $this->optionalUser($request);

        return response()->json(
            Post::query()
                ->with('category')
                ->withEngagement($user)
                ->where('category_id', $id)
                ->latest()
                ->get()
        );
    }

    /**
     * Admin: multipart update (POST to support file uploads from all clients).
     */
    public function update(Request $request, int $id)
    {
        $post = Post::query()->findOrFail($id);

        $request->validate([
            'title' => 'sometimes|required|string',
            'description' => 'sometimes|required|string',
            'category_id' => 'sometimes|required|exists:categories,id',
            'image' => 'nullable|image',
        ]);

        if ($request->filled('title')) {
            $post->title = $request->title;
        }
        if ($request->filled('description')) {
            $post->description = $request->description;
        }
        if ($request->filled('category_id')) {
            $post->category_id = (int) $request->category_id;
        }

        if ($request->hasFile('image')) {
            if ($post->image) {
                Storage::disk('public')->delete($post->image);
            }
            $post->image = $request->file('image')->store('posts', 'public');
        }

        $post->save();

        $user = $request->user();
        $post->load('category')->loadCount(['likes', 'dislikes', 'comments']);
        if ($user) {
            $post->loadExists([
                'likes as liked_by_auth_user' => fn ($q) => $q->where('user_id', $user->id),
                'dislikes as disliked_by_auth_user' => fn ($q) => $q->where('user_id', $user->id),
            ]);
        }

        return response()->json([
            'message' => 'Post updated',
            'data' => $post,
        ]);
    }

    public function destroy(Request $request, int $id)
    {
        $post = Post::query()->findOrFail($id);

        if ($post->user_id !== $request->user()->id && $request->user()->role !== 'admin') {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        if ($post->image) {
            Storage::disk('public')->delete($post->image);
        }

        $post->delete();

        return response()->json(['message' => 'Post deleted']);
    }
}
