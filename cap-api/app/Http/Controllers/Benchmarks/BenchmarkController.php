<?php

namespace App\Http\Controllers\Benchmarks;

use App\Http\Requests\Benchmarks\CreateBenchmarkRequest;
use App\Http\Requests\Benchmarks\CreateMeasurementRequest;
use App\Models\Benchmark;
use App\Models\Measurement;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;

class BenchmarkController extends Controller
{
    public function timeline()
    {
        $benchmarks = Benchmark::with('measurements')->get();

        return response()->json($benchmarks);
    }

    public function detailed($uuid)
    {
        $benchmark = Benchmark::with('measurements')->where(['uuid'=>$uuid])->get();
        $measurements = Measurement::where(['uuid'=>$uuid])->get();
        return view('detailed', ['benchmark' => $benchmark, 'measurement' => $measurements]);
    }

    public function create_benchmark(CreateBenchmarkRequest $request){
        $benchmark = new Benchmark();
        $benchmark->uuid = $request->uuid;

        $benchmark->save();

        return response()->json($benchmark, 201);
    }

    public function create_measurement(CreateMeasurementRequest $request){
        $data = $request->all();
        $measurement = new Measurement($data);

        $measurement->save();

        return response()->json($measurement, 201);
    }
}
