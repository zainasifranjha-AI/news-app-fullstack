<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

// 🔐 Auth routes
use App\Http\Controllers\Auth\RegisteredUserController;
use App\Http\Controllers\Auth\AuthenticatedSessionController;

// 📂 Category Controller
use App\Http\Controllers\CategoryController;

// 📰 Post Controller
use App\Http\Controllers\PostController;


// 🔹 Protected route (get logged-in user)
Route::middleware(['auth:sanctum'])->get('/user', function (Request $request) {
    return $request->user();
});


// 🔹 Auth APIs
Route::post('/register', [RegisteredUserController::class, 'store']);
Route::post('/login', [AuthenticatedSessionController::class, 'store']);


// 🔹 Category APIs
Route::post('/categories', [CategoryController::class, 'store']);
Route::get('/categories', [CategoryController::class, 'index']);


// 🔹 Post APIs
Route::post('/posts', [PostController::class, 'store']);
Route::get('/posts', [PostController::class, 'index']);
Route::get('/posts/category/{id}', [PostController::class, 'byCategory']);

Route::post('/posts', [PostController::class, 'store'])
    ->middleware(['auth:sanctum', 'admin']);