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

Route::get('/', '\App\Http\Controllers\Benchmarks\BenchmarkController@timeline');

Route::get('/api/search/{search}', '\App\Http\Controllers\Benchmarks\BenchmarkController@search');

Route::get('/api/download/{search}', '\App\Http\Controllers\Benchmarks\BenchmarkController@download');

Route::get('/log/{uuid}/{run}', '\App\Http\Controllers\Benchmarks\BenchmarkController@log');

Route::get('/analytics', '\App\Http\Controllers\Benchmarks\BenchmarkController@analytics');

Route::get('/timeline', '\App\Http\Controllers\Benchmarks\BenchmarkController@timeline');

Route::get('/detailed/{uuid}', '\App\Http\Controllers\Benchmarks\BenchmarkController@detailed');

Route::get('/api/benchmark/{uuid}', '\App\Http\Controllers\Benchmarks\BenchmarkController@benchmark');

Route::get('/api/measurement/{uuid}/{run}', '\App\Http\Controllers\Benchmarks\BenchmarkController@measurement');

Route::get('/api/timeline', '\App\Http\Controllers\Benchmarks\BenchmarkController@api_timeline');

Route::post('/api/benchmark/new', '\App\Http\Controllers\Benchmarks\BenchmarkController@create_benchmark');

Route::post('/api/measurement/new', '\App\Http\Controllers\Benchmarks\BenchmarkController@create_measurement');

Route::get('/api/benchmark/delete/{uuid}', '\App\Http\Controllers\Benchmarks\BenchmarkController@delete_benchmark');

Route::get('/api/measurement/delete/{uuid}/{run}', '\App\Http\Controllers\Benchmarks\BenchmarkController@delete_measurement');

