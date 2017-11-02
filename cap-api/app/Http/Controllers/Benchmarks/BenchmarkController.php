<?php

namespace App\Http\Controllers\Benchmarks;

use App\Models\Benchmark;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;

class BenchmarkController extends Controller
{
    public function timeline(BenchmarkRequest $request)
    {

        return response()->json(['reason' => 'success'], 200);
    }
}
