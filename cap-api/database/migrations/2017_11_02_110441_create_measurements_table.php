<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class CreateMeasurementsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('measurements', function (Blueprint $table) {
            $table->increments('id');
            $table->timestamps();
            $table->bigInteger('run');
            $table->string('uuid');
            $table->boolean('successful');
            $table->bigInteger('q1');
            $table->bigInteger('q2');
            $table->bigInteger('q3');
            $table->bigInteger('q4');
            $table->bigInteger('q5');
            $table->bigInteger('q6');
            $table->bigInteger('q7');
            $table->bigInteger('q8');
            $table->bigInteger('q9');
            $table->bigInteger('q10');
            $table->bigInteger('q11');
            $table->bigInteger('q12');
            $table->bigInteger('q13');
            $table->bigInteger('q14');
            $table->bigInteger('q15');
            $table->bigInteger('q16');
            $table->bigInteger('q17');
            $table->bigInteger('q18');
            $table->bigInteger('q19');
            $table->bigInteger('q20');
            $table->bigInteger('q21');
            $table->bigInteger('q22');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('measurements');
    }
}
