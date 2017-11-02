<?php

namespace App\Http\Controllers\Benchmarks;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;

class TimelineController extends Controller
{
    public function timeline()
    {
        $benchmarks = Benchmark::with('measurements')->get();
        dd($benchmarks);
        return response()->json($benchmarks);
    }
}
