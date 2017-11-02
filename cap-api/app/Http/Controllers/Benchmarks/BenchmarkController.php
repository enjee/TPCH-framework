<?php

namespace App\Http\Controllers\Benchmarks;

use App\Models\Benchmark;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;

class BenchmarkController extends Controller
{
    public function timeline()
    {
        $benchmarks = Benchmark::with('measurements')->get();

        return response()->json($benchmarks);
    }
}
