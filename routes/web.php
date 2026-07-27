<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::inertia('/', 'welcome')->name('home');

Route::middleware(['auth', 'verified'])->group(function () {
    Route::get('dashboard', fn (Request $request) => redirect()->route($request->user()->dashboardRoute()))->name('dashboard');
});

require __DIR__.'/settings.php';
require __DIR__.'/admin.php';
