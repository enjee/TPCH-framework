<!doctype html>
<html lang="{{ app()->getLocale() }}">
<head>
    @extends('base')
</head>
<body>

@section('content')
<div class="row">

    <div class="col-12">
        <div class="card mb-3">
            @if($benchmark)
            <div class="card-header"><i class="fa fa-area-chart"></i> Benchmark information</div>
            <div class="card-body">
                <div class="row" style="color: #868e96">
                    <div class="col-sm-3">
                        <h6><i>Benchmark ran on</i></h6>
                        <h4> {{$benchmark->provider}}</h4>
                    </div>
                    <div class="col-sm-3">
                        <h6><i>Test size</i></h6>
                        <h4> {{$benchmark->test_size}} GB</h4>
                    </div>
                    <div class="col-sm-3">
                        <h6><i>Head node type</i></h6>
                        <h4> {{$benchmark->head_node_type}}</h4>
                    </div>
                    <div class="col-sm-3">
                        <h6><i>Head node count</i></h6>
                        @if($benchmark->head_node_count == 1)
                            <h4> {{$benchmark->head_node_count}} head node</h4>
                        @else
                            <h4> {{$benchmark->head_node_count}} head nodes</h4>
                        @endif
                    </div>
                    <div class="col-sm-3">
                        <h6><i>Worker node type</i></h6>
                        <h4> {{$benchmark->worker_node_type}}</h4>
                    </div>
                    <div class="col-sm-3">
                        <h6><i>Worker node count</i></h6>
                        <h4> {{$benchmark->worker_node_count}} worker nodes</h4>
                    </div>
                    <div class="col-sm-3">
                        <h6><i>Tag</i></h6>
                        <h4> #{{$benchmark->tag}}</h4>
                    </div>
                    @if($benchmark->cost)
                    <div class="col-sm-3">
                        <h6><i>Cost</i></h6>
                        <h4><b> €{{ number_format((float) $benchmark->cost, 2) }}</b></h4>
                    </div>
                    @endif
                    <div class="col-sm-3">
                        <h6><i>Average runtime</i></h6>
                        <?php
                        echo '<h6>' . App\Http\Controllers\Benchmarks\FrontendController::secondsToTime( $average_time / 1) . '</h6>'
                        ?>
                    </div>
                </div>
            </div>
            <div class="card-footer small text-muted">Benchmark started at: {{$benchmark->created_at}}</div>

            @endif
        </div>
        @if ($benchmark)
        @foreach($measurement as $m)
        <div class="card mb-3">
            <div data-toggle="collapse" data-target="#card_{{$m->run}}" aria-controls="card_{{$m->run}}"
                 aria-expanded="false" aria-label="Toggle navigation" class="card-header"><i class="fa fa-table"></i>
                <b> Run {{$m->run}}</b>
                <button style="float: right; background: transparent; border: 0;" class="fa fa-chevron-down"
                        type="button" data-toggle="collapse" data-target="#card_{{$m->run}}"
                        aria-controls="card_{{$m->run}}" aria-expanded="false" aria-label="Toggle navigation"></button>
            </div>
            <div class="card-body collapse" id="card_{{$m->run}}">

                <div class="container">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="text-center text-uppercase">
                                <h2>Duration of seperate queries</h2>
                            </div>
                            <!-- //.text-center -->


                            <div class="column-chart">
                                <div class="chart clearfix">
                                    <?php
                                    $qs = array();
                                    for ($count = 0; $count < 22; $count++) {
                                        array_push($qs, object_get($m, "q" . $count));
                                    }
                                    $scale = 260 / max($qs);
                                    ?>

                                    @for($count = 1; $count < 23; $count++)

                                    <div class="item">
                                        <div class="bar tooltip-barchart">
                                            <span class="percent">q{{$count}}</span>
                                            <span class="tooltiptext-barchart"><h5>q{{$count}}</h5><h7>{{object_get($m, "q" . $count)}} seconds</h7></span>
                                            <div class="item-progress" data-percent=
                                            {{ object_get($m,
                                            "q{$count}" ) * $scale }}>
                                            <span class="title">{{ object_get($m, "q{$count}" ) }}</span>
                                        </div>
                                        <!-- //.item-progress -->
                                    </div>
                                    <!-- //.bar -->
                                </div>
                                <!-- //.item -->

                                @endfor


                            </div>
                            <!-- //.chart -->
                        </div>
                        <!-- //.column-chart -->
                    </div>
                    <!-- //.col-md-6 -->
                </div>
                <!-- //.row -->
            </div>
            <!-- //.container -->


            <a href="/log/{{$m->uuid}}/{{$m->run}}">View log</a>
            <table class="table table-bordered" id="dataTable" width="100%" cellspacing="0">
                <thead>
                <tr>
                    <th>Query</th>
                    <th>Run time</th>
                </tr>
                </thead>
                <tbody>
                @for($count = 1; $count < 23; $count++)
                <tr>
                    <td><i> Query {{$count}}</i></td>
                    <td> {{ object_get($m, "q{$count}" ) }} seconds</td>
                </tr>
                @endfor
                </tbody>
            </table>
        </div>
    </div>
    @endforeach
    @endif
</div>
</div>
@stop


</body>
</html>
