<?php

namespace App\Http\Controllers;

use App\Models\Post;
use App\Models\User;
use Illuminate\Http\Request;

class PostEngagementController extends Controller
{
    public function toggleLike(Request $request, int $postId)
    {
        $post = Post::query()->findOrFail($postId);
        /** @var User $user */
        $user = $request->user();

        $existing = $post->likes()->where('user_id', $user->id)->exists();
        if ($existing) {
            $post->likes()->where('user_id', $user->id)->delete();
        } else {
            $post->dislikes()->where('user_id', $user->id)->delete();
            $post->likes()->create(['user_id' => $user->id]);
        }

        return response()->json($this->payload($post->fresh(), $user));
    }

    public function toggleDislike(Request $request, int $postId)
    {
        $post = Post::query()->findOrFail($postId);
        /** @var User $user */
        $user = $request->user();

        $existing = $post->dislikes()->where('user_id', $user->id)->exists();
        if ($existing) {
            $post->dislikes()->where('user_id', $user->id)->delete();
        } else {
            $post->likes()->where('user_id', $user->id)->delete();
            $post->dislikes()->create(['user_id' => $user->id]);
        }

        return response()->json($this->payload($post->fresh(), $user));
    }

    private function payload(Post $post, User $user): array
    {
        $post->loadCount(['likes', 'dislikes', 'comments']);
        $post->loadExists([
            'likes as liked_by_auth_user' => fn ($q) => $q->where('user_id', $user->id),
            'dislikes as disliked_by_auth_user' => fn ($q) => $q->where('user_id', $user->id),
        ]);

        return [
            'likes_count' => $post->likes_count,
            'dislikes_count' => $post->dislikes_count,
            'comments_count' => $post->comments_count,
            'liked_by_auth_user' => (bool) $post->liked_by_auth_user,
            'disliked_by_auth_user' => (bool) $post->disliked_by_auth_user,
        ];
    }
}
