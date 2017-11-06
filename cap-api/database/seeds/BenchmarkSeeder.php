<?php

use Illuminate\Database\Seeder;
use Carbon\Carbon;

class BenchmarkSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        $uuids = array(11111,22222,33333);

        foreach($uuids as $uuid) {
            DB::table('benchmarks')->insert([
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
                'uuid' => $uuid,
                'provider' => 'azure',
                'test_size' => random_int(1, 100) . ' GB'
            ]);
            for($i = 0; $i < 3; $i++){
                DB::table('measurements')->insert([
                    'created_at' => Carbon::now(),
                    'updated_at' => Carbon::now(),
                    'uuid' => $uuid,
                    'run' => $i,
                    'successful' => true,
                    'q1' => random_int(0, 10000),
                    'q2' => random_int(0, 10000),
                    'q3' => random_int(0, 10000),
                    'q4' => random_int(0, 10000),
                    'q5' => random_int(0, 10000),
                    'q6' => random_int(0, 10000),
                    'q7' => random_int(0, 10000),
                    'q8' => random_int(0, 10000),
                    'q9' => random_int(0, 10000),
                    'q10' => random_int(0, 10000),
                    'q11' => random_int(0, 10000),
                    'q12' => random_int(0, 10000),
                    'q13' => random_int(0, 10000),
                    'q14' => random_int(0, 10000),
                    'q15' => random_int(0, 10000),
                    'q16' => random_int(0, 10000),
                    'q17' => random_int(0, 10000),
                    'q18' => random_int(0, 10000),
                    'q19' => random_int(0, 10000),
                    'q20' => random_int(0, 10000),
                    'q21' => random_int(0, 10000),
                    'q22' => random_int(0, 10000)
                ]);
            }
        }

    }
}
