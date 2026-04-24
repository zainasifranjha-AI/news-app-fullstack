<?php

namespace App\Http\Controllers;

use App\Models\Category;
use Illuminate\Http\Request;

class CategoryController extends Controller
{
    /**
     * Store new category
     */
    public function store(Request $request)
    {
        // Validation
        $request->validate([
            'name' => 'required|string|max:255',
        ]);

        // Create category
        $category = Category::create([
            'name' => $request->name,
        ]);

        // Response
        return response()->json([
            'message' => 'Category created successfully',
            'data' => $category
        ], 201);
    }

    /**
     * Get all categories
     */
    public function index()
    {
        $categories = Category::all();

        return response()->json([
            'data' => $categories
        ]);
    }
}