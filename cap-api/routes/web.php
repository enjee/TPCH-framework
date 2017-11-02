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

Route::get('/logged', function () {
    return view('logged');
});

Route::get('/login', function () {
    return Redirect::to("https://login.microsoftonline.com/common/oauth2/authorize?client_id=51099241-6929-4552-a40e-93c83359a7f1&scope=api&redirect_uri=http://localhost:8000/logged&response_type=code&prompt=consent");
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