<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Facades\Storage;

class Post extends Model
{
    use HasFactory;

    protected $fillable = [
        'title',
        'description',
        'image',
        'category_id',
        'user_id',
    ];

    protected $appends = ['image_url', 'image_storage_path'];

    public static function normalizeStorageRelativePath(?string $stored): ?string
    {
        if (! $stored) {
            return null;
        }

        $p = str_replace('\\', '/', trim($stored));
        $p = ltrim($p, '/');

        if (str_starts_with($p, 'public/')) {
            $p = substr($p, strlen('public/'));
        }

        if (str_starts_with($p, 'storage/')) {
            $p = substr($p, strlen('storage/'));
        }

        return $p !== '' ? $p : null;
    }

    public function getImageStoragePathAttribute(): ?string
    {
        $rel = self::normalizeStorageRelativePath($this->image);

        return $rel ? '/storage/'.$rel : null;
    }

    public function getImageUrlAttribute(): ?string
    {
        $rel = self::normalizeStorageRelativePath($this->image);
        if (! $rel) {
            return null;
        }

        return Storage::disk('public')->url($rel);
    }

    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function likes(): HasMany
    {
        return $this->hasMany(PostLike::class);
    }

    public function dislikes(): HasMany
    {
        return $this->hasMany(PostDislike::class);
    }

    public function comments(): HasMany
    {
        return $this->hasMany(PostComment::class);
    }

    public function scopeWithEngagement(Builder $query, ?User $user): Builder
    {
        $query->withCount(['likes', 'dislikes', 'comments']);

        if ($user) {
            $query->withExists([
                'likes as liked_by_auth_user' => fn ($q) => $q->where('user_id', $user->id),
                'dislikes as disliked_by_auth_user' => fn ($q) => $q->where('user_id', $user->id),
            ]);
        }

        return $query;
    }
}
