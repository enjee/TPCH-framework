<?php

namespace App\Http\Controllers\Benchmarks;

use App\Http\Requests\Benchmarks\CreateBenchmarkRequest;
use App\Http\Requests\Benchmarks\CreateMeasurementRequest;
use App\Models\Benchmark;
use App\Models\Measurement;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Input;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Storage;
use League\Csv\Writer;
use SplTempFileObject;

class BenchmarkController extends Controller
{
    public function timeline()
    {
        $search_uuid_tag  = Input::get('search_uuid_tag');
        if($search_uuid_tag != null){
            $benchmarks = Benchmark::with('measurements')->where('uuid', 'LIKE', "%".$search_uuid_tag."%" )->orWhere('tag', 'LIKE', "%".$search_uuid_tag."%" )->get()->reverse();
        }else{
            $benchmarks = Benchmark::with('measurements')->get()->reverse();
        }

        return view('timeline',['benchmarks'=>$benchmarks, 'search_uuid_tag'=>$search_uuid_tag]);
    }

    public function api_timeline(){
        $benchmarks = Benchmark::with('measurements')->get();
        return response()->json($benchmarks, 200);
    }

    public function detailed($uuid)
    {
        $benchmark = Benchmark::with('measurements')->where(['uuid' => $uuid])->first();
        $measurements = Measurement::where(['uuid' => $uuid])->get();

        $runtimes = array();
        $runindex = 0;
        foreach (object_get($benchmark, "measurements") as $measurement) {
            $currentrun = 0;

            for ($i = 0; $i < 22; $i++) {
                $currentrun += object_get($measurement, "q{$i}" );
            }
            array_push($runtimes, $currentrun);
            $runindex++;
        }

        if(count($runtimes) > 0) {
            $average_time = array_sum($runtimes) / count($runtimes);
        }else{
            $average_time = 0;
        }

        return view('detailed', ['benchmark' => $benchmark, 'measurement' => $measurements, 'average_time' => $average_time]);
    }

    public function log($uuid, $run){
        $measurement = $measurements = Measurement::where(['uuid' => $uuid])->where('run', '=', $run)->first();

        return view('log', ['measurement' => $measurement]);
    }

    public function analytics(){
        return view('analytics');
    }

    public function benchmark($uuid){
        $benchmark = Benchmark::with('measurements')->where('uuid', '=', $uuid)->first();

        if($benchmark){
            return response()->json($benchmark, 200);
        } else {
            return response()->json('benchmark not found', 404);
        }
    }

    public function measurement($uuid, $run){
        $measurement = Measurement::where('uuid', '=', $uuid)->where('run', '=', $run)->first();

        if($measurement){
            return response()->json($measurement, 200);
        } else {
            return response()->json('measurement not found', 404);
        }
    }

    public function create_benchmark(Request $request){

        $benchmark = new Benchmark();

        if($request->uuid){
            $exists = Benchmark::where('uuid', '=', $request->uuid)->first();

            if($exists){
                return response()->json('benchmark already exists', 409);
            }else{
                $benchmark->uuid = $request->uuid;
                $benchmark->provider = $request->provider;
                $benchmark->head_node_type = $request->head_node_type;
                $benchmark->head_node_count = $request->head_node_count;
                $benchmark->worker_node_type = $request->worker_node_type;
                $benchmark->worker_node_count = $request->worker_node_count;
                $benchmark->test_size =$request->test_size;
                $benchmark->tag = $request->tag;
            }

        }else{
            $data = $request->json()->all();

            $exists = Benchmark::where('uuid', '=', $data['uuid'])->first();

            if($exists){
                return response()->json('benchmark already exists', 409);
            }else {

                $benchmark->uuid = $data['uuid'];
                $benchmark->provider = $data['provider'];
                $benchmark->head_node_type = $data['head_node_type'];
                $benchmark->head_node_count = $data['head_node_count'];
                $benchmark->worker_node_type = $data['worker_node_type'];
                $benchmark->worker_node_count = $data['worker_node_count'];
                $benchmark->test_size = $data['test_size'];
                $benchmark->tag = $data['tag'];
            }
        }

        $benchmark->save();

        return response()->json($benchmark, 201);
    }

    public function delete_benchmark($uuid)
    {
        $benchmark = Benchmark::with('measurements')->where('uuid', '=', $uuid)->first();

        if($benchmark){
            $benchmark->measurements()->delete();
            $benchmark->delete();

            return response()->json('benchmark deleted', 200);
        } else {
            return response()->json('benchmark with uuid ' . $uuid . ' not found', 404);
        }

    }

    public function create_measurement(Request $request){

        if($request->uuid){
            $data = $request->all();
            $log = $request->json()->all()['log'];

            $exists = Measurement::where('uuid', '=', $request->uuid)->where('run', '=', $request->run)->first();

            if($exists){
                return response()->json('measurement already exists', 409);
            }else{
                $measurement = new Measurement($data);
                $measurement->log = $log;
            }

        }else{
            $data = $request->json()->all();

            $exists = Measurement::where('uuid', '=', $data['uuid'])->where('run', '=', $data['run'])->first();

            if($exists) {
                return response()->json('measurement already exists', 409);
            }else {
                $measurement = new Measurement();

                $measurement->run = $data['run'];
                $measurement->uuid = $data['uuid'];
                $measurement->successful = $data['successful'];
                $measurement->log = $data['log'];
                $measurement->q1 = $data['q1'];
                $measurement->q2 = $data['q2'];
                $measurement->q3 = $data['q3'];
                $measurement->q4 = $data['q4'];
                $measurement->q5 = $data['q5'];
                $measurement->q6 = $data['q6'];
                $measurement->q7 = $data['q7'];
                $measurement->q8 = $data['q8'];
                $measurement->q9 = $data['q9'];
                $measurement->q10 = $data['q10'];
                $measurement->q11 = $data['q11'];
                $measurement->q12 = $data['q12'];
                $measurement->q13 = $data['q13'];
                $measurement->q14 = $data['q14'];
                $measurement->q15 = $data['q15'];
                $measurement->q16 = $data['q16'];
                $measurement->q17 = $data['q17'];
                $measurement->q18 = $data['q18'];
                $measurement->q19 = $data['q19'];
                $measurement->q20 = $data['q20'];
                $measurement->q21 = $data['q21'];
                $measurement->q22 = $data['q22'];
            }
        }


        $measurement->save();

        return response()->json($measurement, 201);
    }

    public function delete_measurement($uuid, $run){
        $measurement = Measurement::where('uuid', '=', $uuid)->where('run', '=', $run)->first();

        if($measurement){
            $measurement->delete();

            return response()->json('measurement deleted', 200);
        } else {
            return response()->json('measurement not found', 404);
        }
    }

    public function search($search = null){
        if($search){
            $benchmarks = Benchmark::with('measurements')->where('uuid', 'LIKE', "%".$search."%" )->orWhere('tag', 'LIKE', "%".$search."%" )->get();
        }else{
            $benchmarks = Benchmark::with('measurements')->get();
        }

    if($benchmarks){
        return response()->json($benchmarks, 200);
    } else {
        return response()->json('benchmark not found', 404);
    }
}

    public function download($search = null){
        if($search){
            $benchmarks = Benchmark::with('measurements')->where('uuid', 'LIKE', "%".$search."%" )->orWhere('tag', 'LIKE', "%".$search."%" )->get();
            $filename = $search . '.json';
        }else{
            $benchmarks = Benchmark::with('measurements')->get();
            $filename = 'benchmarks.json';
        }


        if(count($benchmarks) > 0){
            Storage::put($filename, $benchmarks->toJson());

            $path = storage_path('/app/' . $filename);

            return response()->download($path, $filename)->deleteFileAfterSend(true);
        } else {
            return response()->json('benchmark not found', 404);
        }
    }

    public function download_csv($search = null){
        if($search){
            $benchmarks = Benchmark::with('measurements')->where('uuid', 'LIKE', "%".$search."%" )->orWhere('tag', 'LIKE', "%".$search."%" )->get();
            $filename = $search . '.csv';
        }else{
            $benchmarks = Benchmark::with('measurements')->get();
            $filename = 'benchmarks.csv';
        }

        if(count($benchmarks) > 0){

            $csv = Writer::createFromFileObject(new SplTempFileObject());


            $measurement1 = $benchmarks[0]->measurements()->get();

            if(count($measurement1) == 0){
                return response()->json('Benchmark contains no measurements, csv cannot be provided', 500);
            }

            $header_measurements = array_keys($measurement1[0]->toArray());

            $benchmark1 = $benchmarks[0];


            unset($benchmark1['measurements']);
            unset($benchmark1['id']);
            unset($benchmark1['created_at']);
            unset($benchmark1['updated_at']);
            unset($benchmark1['uuid']);

            $header_benchmark = array_keys($benchmark1->toArray());


            $headers = array_merge($header_measurements, $header_benchmark);

            $csv->insertOne($headers);

            foreach($measurement1 as $m){
                $csv->insertOne(array_merge($m->toArray(), $benchmark1->toArray()));
            }

            foreach($benchmarks as $benchmark){
                $data_measurements = $benchmark->measurements()->get();
                unset($benchmark['measurements']);
                unset($benchmark['id']);
                unset($benchmark['created_at']);
                unset($benchmark['updated_at']);
                unset($benchmark['uuid']);
                $data = $benchmark->toArray();
                foreach($data_measurements as $measurement){
                    $csv->insertOne(array_merge($measurement->toArray(), $data));
                }
            }

            $csv->output($filename);
        } else {
            return response()->json('benchmark not found', 404);
        }
    }

}
