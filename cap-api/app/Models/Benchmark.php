<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Models\Measurement;

class Benchmark extends Model
{
    protected $table = 'benchmarks';

    public function measurements(){
        return $this->hasMany(Measurement::class, 'uuid', 'uuid');
    }
}
