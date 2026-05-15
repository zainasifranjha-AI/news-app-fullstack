<?php

namespace App\Http\Controllers;

use App\Models\Post;
use App\Models\PostComment;
use Illuminate\Http\Request;

class PostCommentController extends Controller
{
    public function index(int $postId)
    {
        $post = Post::query()->findOrFail($postId);

        $comments = $post->comments()
            ->with('user:id,name')
            ->latest()
            ->get()
            ->map(fn (PostComment $c) => [
                'id' => $c->id,
                'body' => $c->body,
                'created_at' => $c->created_at?->toIso8601String(),
                'user' => [
                    'id' => $c->user_id,
                    'name' => $c->user?->name ?? 'User',
                ],
            ]);

        return response()->json(['data' => $comments]);
    }

    public function store(Request $request, int $postId)
    {
        $post = Post::query()->findOrFail($postId);

        $validated = $request->validate([
            'body' => 'required|string|max:5000',
        ]);

        $comment = $post->comments()->create([
            'user_id' => $request->user()->id,
            'body' => $validated['body'],
        ]);

        $comment->load('user:id,name');

        return response()->json([
            'message' => 'Comment added',
            'data' => [
                'id' => $comment->id,
                'body' => $comment->body,
                'created_at' => $comment->created_at?->toIso8601String(),
                'user' => [
                    'id' => $comment->user_id,
                    'name' => $comment->user?->name ?? 'User',
                ],
            ],
        ], 201);
    }

    public function destroy(Request $request, int $id)
    {
        $comment = PostComment::query()->findOrFail($id);

        $user = $request->user();
        if ($comment->user_id !== $user->id && $user->role !== 'admin') {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $post = $comment->post;
        $comment->delete();

        $post->loadCount(['likes', 'dislikes', 'comments']);

        return response()->json([
            'message' => 'Comment deleted',
            'comments_count' => $post->comments_count,
        ]);
    }
}
