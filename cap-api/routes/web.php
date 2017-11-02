<?php

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

Route::get('/', function () {
    return view('welcome');
});

Route::get('/oauth', function () {
    return view('oauth');
});

Route::get('/tl', function () {
    $benchmarktime = array(12000, 12333, 18000, 14234);
    $benchmarksize = array(10, 10, 20, 10);
    return view('timeline', ['time' => $benchmarktime], ['size' => $benchmarksize]);
});

Route::get('/benchmark', function () {
    return view('benchmark');
});

Route::get('timeline', '\App\Http\Controllers\Benchmarks\BenchmarkController@timeline');