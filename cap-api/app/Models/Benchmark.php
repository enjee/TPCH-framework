<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Models\Measurement;

class Benchmark extends Model
{
    protected $table = 'benchmarks';
    protected $fillable = ['uuid'];
    protected $hidden = ['uuid'];

    public function measurements(){
        return $this->hasMany(Measurement::class, 'uuid', 'uuid');
    }
}
