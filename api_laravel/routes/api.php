<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BukuController;
use App\Http\Controllers\Api\AnggotaController;
use App\Http\Controllers\Api\PeminjamanController;

// Public routes — Auth
Route::prefix('auth')->group(function () {
    Route::post('register', [AuthController::class, 'register']);
    Route::post('login',    [AuthController::class, 'login']);
});

// Protected routes — JWT middleware
Route::middleware('auth:api')->group(function () {
    Route::prefix('auth')->group(function () {
        Route::post('logout',  [AuthController::class, 'logout']);
        Route::post('refresh', [AuthController::class, 'refresh']);
        Route::get('me',       [AuthController::class, 'me']);
    });

    Route::apiResource('bukus',        BukuController::class);
    Route::apiResource('anggotas',     AnggotaController::class);
    Route::apiResource('peminjamans',  PeminjamanController::class);
});
