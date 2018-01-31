<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class CreateBenchmarksTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('benchmarks', function (Blueprint $table) {
            $table->increments('id');
            $table->timestamps();
            $table->string('uuid');
            $table->string('provider');
            $table->string('head_node_type');
            $table->string('head_node_count');
            $table->string('worker_node_type');
            $table->string('worker_node_count');
            $table->string('test_size');
            $table->string('tag')->nullable();
            $table->string('cost')->nullable();
            $table->string('overhead')->nullable();

        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('benchmarks');
    }
}
