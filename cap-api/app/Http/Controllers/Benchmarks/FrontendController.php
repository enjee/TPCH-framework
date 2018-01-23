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
use stdClass;

class FrontendController extends Controller
{
    public function timeline()
    {
        $search_uuid_tag = Input::get('search_uuid_tag');
        if ($search_uuid_tag != null) {
            if(strpos($search_uuid_tag, ',') !== false){

                $trimmed_search = str_replace(" ", "", $search_uuid_tag);
                $search_array = explode(",", $trimmed_search);
                $benchmark_array = collect(new Benchmark);

                $first_search = $search_array[0];

                if(strlen($first_search) < 9){
                    $benchmark = Benchmark::with('measurements')->where('provider', 'LIKE', "%" . $first_search . "%")->orWhere('test_size', '=', $first_search)->orWhere('tag', 'LIKE', "%" . $first_search . "%")->get();
                }else{
                    $benchmark = Benchmark::with('measurements')->where('provider', 'LIKE', "%" . $first_search . "%")->orWhere('test_size', '=', $first_search)->orWhere('uuid', 'LIKE', "%" . $first_search . "%")->orWhere('tag', 'LIKE', "%" . $first_search . "%")->get();
                }

                $candidates = [];

                foreach($benchmark as $b){
                    array_push($candidates, $b->uuid);
                }

                for ($i = 1; $i < count($search_array); $i++){

                    $search = $search_array[$i];

                        $benchmark = Benchmark::with('measurements')->where('test_size', '=',  $search)->whereIn('uuid', $candidates)->get();
                        if(count($benchmark) < 1){
                            $benchmark = Benchmark::with('measurements')->where('tag', 'LIKE', "%" . $search . "%")->whereIn('uuid', $candidates)->get();
                        }
                        if(count($benchmark) < 1){
                            $benchmark = Benchmark::with('measurements')->where('provider', 'LIKE', "%" . $search . "%")->whereIn('uuid', $candidates)->get();
                        }
                    if(count($benchmark) < 1){
                        $benchmark = Benchmark::with('measurements')->where('uuid', 'LIKE', "%" . $search . "%")->whereIn('uuid', $candidates)->get();
                    }


                    $candidates = [];

                    foreach($benchmark as $b){
                        array_push($candidates, $b->uuid);
                    }


                }



                if(count($benchmark) > 0){
                    foreach($benchmark as $b){
                        $benchmark_array->push($b);
                    }
                }

                $benchmarks = $benchmark_array->unique()->sort()->reverse();
            }else{
                if(strlen($search_uuid_tag) < 7){
                    $benchmarks = Benchmark::with('measurements')->where('provider', 'LIKE', "%" . $search_uuid_tag . "%")->orWhere('test_size', '=', $search_uuid_tag)->orWhere('tag', 'LIKE', "%" . $search_uuid_tag . "%")->get();
                }else{
                    $benchmarks = Benchmark::with('measurements')->where('provider', 'LIKE', "%" . $search_uuid_tag . "%")->orWhere('test_size', '=', $search_uuid_tag)->orWhere('uuid', 'LIKE', "%" . $search_uuid_tag . "%")->orWhere('tag', 'LIKE', "%" . $search_uuid_tag . "%")->get();
                }
            }
        } else {
            $benchmarks = Benchmark::with('measurements')->get()->reverse();
        }

        return view('timeline', ['benchmarks' => $benchmarks, 'search_uuid_tag' => $search_uuid_tag]);
    }


    public function analytics($size = 0)
    {
        $sizes = ['0', '1', '10', '100', '1000'];
        $providers = ['Azure', 'Amazon'];
        $linechart_csv = Writer::createFromPath( "priceperformance.csv", "w");
        $linechart_csv->insertOne(["Test Size", "Azure", "Amazon"]);
        foreach($sizes as $s){
                $linechart_data = [];
                array_push($linechart_data, $s);
                $barchart_path = "analytics-" . $s . ".csv";
                $barchart_csv = Writer::createFromPath( $barchart_path, "w");

                $barchart_csv->insertOne(["Provider", "Time Elapsed In Minutes", "Overhead In Minutes"]);

            foreach($providers as $p) {
                $row = $this->analytics_json($p, $s);
                $price_performance = 0;
                if ($row) {
                    $price = $row[3];
                    unset($row[3]);
                    $barchart_csv->insertOne($row);
                    $price_performance = $price / $row[1];
                } else {
                    $barchart_csv->insertOne([$p . '- No data available', 0, 0]);
                }
                array_push($linechart_data, $price_performance);
            }
            $linechart_csv->insertOne($linechart_data);
        }



        return view('analytics');
    }

    public function analytics_json($provider, $size){
        if($size < 1){
            $benchmarks = Benchmark::with('measurements')->where('provider', '=', $provider)->get();
        }else{
            $benchmarks = Benchmark::with('measurements')->where('provider', '=', $provider)->where('test_size', '=', $size)->get();
        }



        if($benchmarks->count() < 1){
            return null;
        }

        $total_overhead = 0;
        $total_cost = 0;


        $measurements = [];
        foreach($benchmarks as $b){
            array_push($measurements, $b->measurements());
            $total_overhead += $b->overhead;
            $total_cost += $b->cost;
        }
        $measurement_count = 0;
        foreach($measurements as $m){
            $measurement_count += $m->get()->count();
        }
        $total = 0;

        for($i = 0; $i < count($measurements); $i++){
            $current_measurements = $measurements[$i]->get();
            for($j = 0; $j < count($current_measurements); $j++){
                $measurement = $current_measurements[$j];
                $measurement_total = 0;
                for($k = 0; $k < 22; $k++){
                    $measurement_total += object_get($measurement, "q{$k}" );
                }
                $total += $measurement_total;
            }
        }


        $total = intval((($total / $measurement_count) / 60));
        $total_overhead = ($total_overhead / $benchmarks->count());
        $total_cost = ($total_cost / $benchmarks->count());
        $provider_data = [$provider, $total, $total_overhead, $total_cost];
        return $provider_data;
    }

    public function log($uuid, $run)
    {
        $measurement = $measurements = Measurement::where(['uuid' => $uuid])->where('run', '=', $run)->first();

        return view('log', ['measurement' => $measurement]);
    }

    public function detailed($uuid)
    {
        $benchmark = Benchmark::with('measurements')->where(['uuid' => $uuid])->first();
        $measurements = Measurement::where(['uuid' => $uuid])->get();

        $benchmark->created_at = $benchmark->created_at->add(\DateInterval::createFromDateString('+1 hours'));
        $runtimes = array();
        $runindex = 0;
        foreach (object_get($benchmark, "measurements") as $measurement) {
            $currentrun = 0;

            for ($i = 0; $i < 22; $i++) {
                $currentrun += object_get($measurement, "q{$i}");
            }
            array_push($runtimes, $currentrun);
            $runindex++;
        }

        if (count($runtimes) > 0) {
            $average_time = array_sum($runtimes) / count($runtimes);
        } else {
            $average_time = 0;
        }

        return view('detailed', ['benchmark' => $benchmark, 'measurement' => $measurements, 'average_time' => $average_time]);
    }

    public function search($search = null)
    {
            $benchmarks = Benchmark::with('measurements')->where('provider', 'LIKE', "%" . $search . "%")->orWhere('test_size', 'LIKE', "%" . $search . "%")->orWhere('uuid', 'LIKE', "%" . $search . "%")->orWhere('tag', 'LIKE', "%" . $search . "%")->get();
        if ($benchmarks->count() < 1) {
            $benchmarks = Benchmark::with('measurements')->get();
        }

        if ($benchmarks) {
            return response()->json($benchmarks, 200);
        } else {
            return response()->json('benchmark not found', 404);
        }
    }

    public function download_csv($search = null)
    {
        if ($search) {
            if(strpos($search, ',') !== false){

                $trimmed_search = str_replace(" ", "", $search);
                $search_array = explode(",", $trimmed_search);
                $benchmark_array = collect(new Benchmark);
                foreach ($search_array as $s){

                    $benchmark = Benchmark::with('measurements')->where('uuid', 'LIKE', "%" . $s . "%")->orWhere('tag', 'LIKE', "%" . $s . "%")->get();

                    if(count($benchmark) > 0){
                        foreach($benchmark as $b){
                            $benchmark_array->push($b);
                        }
                    }
                }

                $benchmarks = $benchmark_array->unique();
            }else{
                $benchmarks = Benchmark::with('measurements')->where('uuid', 'LIKE', "%" . $search . "%")->orWhere('tag', 'LIKE', "%" . $search . "%")->get()->reverse();
            }
            $filename = $search . '.csv';
        } else {
            $benchmarks = Benchmark::with('measurements')->get();
            $filename = 'benchmarks.csv';
        }

        if (count($benchmarks) > 0) {

            $csv = Writer::createFromFileObject(new SplTempFileObject());


            $measurement1 = $benchmarks[0]->measurements()->get();

            if (count($measurement1) == 0) {
                return response()->json('Benchmark contains no measurements, csv cannot be provided', 500);
            }

            $header_measurements = array_keys($measurement1[0]->toArray());
            if (($key = array_search('log', $header_measurements)) !== false) {
                unset($header_measurements[$key]);
            }
            $benchmark1 = $benchmarks[0];


            unset($benchmark1['measurements']);
            unset($benchmark1['id']);
            unset($benchmark1['created_at']);
            unset($benchmark1['updated_at']);
            unset($benchmark1['uuid']);

            $header_benchmark = array_keys($benchmark1->toArray());


            $headers = array_merge($header_measurements, $header_benchmark);

            $csv->insertOne($headers);

            foreach ($measurement1 as $m) {
                unset($m['log']);
                $csv->insertOne(array_merge($m->toArray(), $benchmark1->toArray()));
            }

            foreach ($benchmarks as $benchmark) {
                $data_measurements = $benchmark->measurements()->get();
                unset($benchmark['measurements']);
                unset($benchmark['id']);
                unset($benchmark['created_at']);
                unset($benchmark['updated_at']);
                unset($benchmark['uuid']);
                $data = $benchmark->toArray();
                foreach ($data_measurements as $measurement) {
                    unset($measurement['log']);
                    $csv->insertOne(array_merge($measurement->toArray(), $data));
                }
            }

            $csv->output($filename);
        } else {
            return response()->json('benchmark not found', 404);
        }
    }
}
