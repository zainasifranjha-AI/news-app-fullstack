<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

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

    // 🔥 Relation: Post belongs to Category
    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    // 🔥 Relation: Post belongs to User (Admin)
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}