<?php

use Illuminate\Database\Seeder;
use Carbon\Carbon;
use Illuminate\Support\Facades\Hash;

class BenchmarkSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        $providers = ['Azure', 'Amazon'];
        $sizes = [1, 10, 100, 1000];

        foreach($providers as $provider) {
            foreach($sizes as $s){
                for($j = 0; $j < 15; $j++){
                    $uuid = str_replace("/", "", Hash::make(Carbon::now()->toDateTimeString()));


                    DB::table('benchmarks')->insert([
                        'created_at' => Carbon::now(),
                        'updated_at' => Carbon::now(),
                        'uuid' => $uuid,
                        'provider' => $provider,
                        'head_node_type' => 'A3',
                        'head_node_count' => '2',
                        'worker_node_type' => 'A3',
                        'worker_node_count' => 2,
                        'test_size' => $s,
                        'tag' => 'test_tag',
                        'cost' => ((rand(12, 14) / 10) * $s),
                        'overhead' => random_int(19, 35)
                    ]);
                    for($i = 0; $i < 3; $i++){
                        DB::table('measurements')->insert([
                            'created_at' => Carbon::now(),
                            'updated_at' => Carbon::now(),
                            'uuid' => $uuid,
                            'run' => $i + 1,
                            'successful' => true,
                            'q1' => (random_int(53, 56) * $s),
                            'q2' => (random_int(80, 86) * $s),
                            'q3' => (random_int(69, 74) * $s),
                            'q4' => (random_int(65, 70) * $s),
                            'q5' => (random_int(70, 78) * $s),
                            'q6' => (random_int(58, 64) * $s),
                            'q7' => (random_int(102, 113) * $s),
                            'q8' => (random_int(77, 85) * $s),
                            'q9' => (random_int(82, 89) * $s),
                            'q10' => (random_int(82, 87) * $s),
                            'q11' => (random_int(30, 36) * $s),
                            'q12' => (random_int(65, 71) * $s),
                            'q13' => (random_int(78, 85) * $s),
                            'q14' => (random_int(61, 66) * $s),
                            'q15' => (random_int(76, 82) * $s),
                            'q16' => (random_int(105, 118) * $s),
                            'q17' => (random_int(88, 94) * $s),
                            'q18' => (random_int(145, 156) * $s),
                            'q19' => (random_int(64, 69) * $s),
                            'q20' => (random_int(105, 112) * $s),
                            'q21' => (random_int(130, 137) * $s),
                            'q22' => (random_int(114, 121 * $s))
                        ]);
                    }
                }
            }

        }

    }
}
