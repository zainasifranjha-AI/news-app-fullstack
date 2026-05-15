<?php

use App\Http\Controllers\Auth\AuthenticatedSessionController;
use App\Http\Controllers\Auth\RegisteredUserController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\PostCommentController;
use App\Http\Controllers\PostController;
use App\Http\Controllers\PostEngagementController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::middleware(['auth:sanctum'])->get('/user', function (Request $request) {
    return $request->user();
});

Route::post('/register', [RegisteredUserController::class, 'store']);
Route::post('/login', [AuthenticatedSessionController::class, 'store']);

Route::get('/categories', [CategoryController::class, 'index']);
Route::get('/posts', [PostController::class, 'index']);
Route::get('/posts/latest', [PostController::class, 'latest']);
Route::get('/posts/category/{id}', [PostController::class, 'byCategory']);
Route::get('/posts/{postId}/comments', [PostCommentController::class, 'index'])->whereNumber('postId');
Route::get('/posts/{id}', [PostController::class, 'show'])->whereNumber('id');

Route::middleware(['auth:sanctum'])->group(function () {
    Route::post('/posts/{postId}/like', [PostEngagementController::class, 'toggleLike'])->whereNumber('postId');
    Route::post('/posts/{postId}/dislike', [PostEngagementController::class, 'toggleDislike'])->whereNumber('postId');
    Route::post('/posts/{postId}/comments', [PostCommentController::class, 'store'])->whereNumber('postId');
    Route::delete('/comments/{id}', [PostCommentController::class, 'destroy'])->whereNumber('id');
});

Route::middleware(['auth:sanctum', 'admin'])->group(function () {
    Route::post('/categories', [CategoryController::class, 'store']);
    Route::post('/posts', [PostController::class, 'store']);
    Route::post('/posts/{id}/update', [PostController::class, 'update'])->whereNumber('id');
    Route::delete('/posts/{id}', [PostController::class, 'destroy'])->whereNumber('id');
});
