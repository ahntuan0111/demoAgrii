<?php
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Admin\FarmerController;
use App\Http\Controllers\Admin\TrangNongController;
use App\Http\Controllers\Admin\LaoNongController;
use App\Http\Controllers\Admin\SupplierController;
use App\Http\Controllers\Admin\ProductController;
use App\Http\Controllers\Admin\CatalogController;
use App\Http\Controllers\Admin\OrderController;

Route::get('/', fn() => redirect()->route('farmers.index'));

Route::prefix('admin')->middleware(['web'])->group(function () {
  Route::resource('farmers', FarmerController::class)->names('farmers');
  Route::resource('trang-nong', TrangNongController::class)->names('trangnong');
  Route::resource('lao-nong', LaoNongController::class)->names('laonong');
  Route::resource('suppliers', SupplierController::class)->names('suppliers');
  Route::resource('products', ProductController::class)->names('products');
  Route::resource('catalog', CatalogController::class)->names('catalog');
  Route::resource('orders', OrderController::class)->only(['index', 'show']);
  Route::post('orders/{order}/change-status', [\App\Http\Controllers\Admin\OrderController::class,'changeStatus'])
        ->name('orders.change-status');
  Route::get('orders', [OrderController::class, 'index'])->name('orders.index');
  
});
