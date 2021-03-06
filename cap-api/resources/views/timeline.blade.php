<!doctype html>
<html lang="{{ app()->getLocale() }}">
<head>
    @extends('base')
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css?family=Raleway:100,600" rel="stylesheet" type="text/css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>

    <script src="{{ asset('js/colorDiv.js') }}"></script>
    <script src="{{asset('js/labelmanager.js') }}"></script>

    <!-- Styles -->
    <style>



        .links > a {
            color: #636b6f;
            padding: 0 25px;
            font-size: 12px;
            font-weight: 600;
            letter-spacing: .1rem;
            text-decoration: none;
            text-transform: uppercase;
        }

        .m-b-md {
            margin-bottom: 30px;
        }

        .benchmark {
            margin:20px auto;
            padding:20px;
            width: 80%;
            padding: 5px;
            border-radius: 5px;
            height: auto;
            background-color: #f5f5f5;
            box-shadow: 0 0px 3px rgba(0,0,0,0.12), 0 1px 2px rgba(0,0,0,0.24);
            transition: all 0.3s cubic-bezier(.25,.8,.25,1);

        }

        .benchmark:hover {
            box-shadow: 0 14px 28px rgba(0,0,0,0.25), 0 10px 10px rgba(0,0,0,0.22);
        }
        .benchmark-container {
            margin: auto;
            text-align: center;
            -webkit-border-radius: 5px;
            -moz-border-radius: 5px;
            border-radius: 5px;
            padding: 5px;
            width: 98%;
            background-color: #e1e1e1;
            color: #ffffff;
        }
        a{
            color: inherit;
            text-decoration: none;
        }
        .benchmark-run {
            text-align: left;
            padding: 10px;
            -webkit-border-radius: 3px;
            -moz-border-radius: 3px;
            border-radius: 3px;
            background-color: #cc0001;
            margin: 10px;
            display: inline-block;
            width: 90%;
            box-shadow: -3px 3px 10px #888888;

        }

        .benchmark-title {
            font-size: 40px;
            font-family: 'Raleway', sans-serif;
        }

        .benchmark-info {
            display: inline-block;
            width: 47%;
            padding: 10px;
            border-radius: 10px;
            background-color: #cccccc;

        }

        .benchmark-runtimes {
            display: inline-block;
            width: 98%;
        }

        .label{
            color: whitesmoke;
            background-color: #1b1e21; border-radius: 3px; padding: 2px 7px; margin: 5px;
        }
    </style>
</head>
<body>

@section('searchbar')
<div id="labels"></div>
    <form id="searchbar" method="get" action="/timeline" class="form-inline my-2 my-lg-0 mr-lg-2">
        <div class="input-group">
            <input id="searchfield" name="search_uuid_tag" class="form-control" type="text" placeholder="Search on tag/uuid..." value="{{$search_uuid_tag}}">
            <span class="input-group-btn">
                    <button class="btn btn-primary" type="Submit">
                      <i class="fa fa-search"></i>
                    </button>
                  </span>
        </div>
    </form>
    <a class="btn btn-info" href="/api/csv/{{$search_uuid_tag}}"><i class="fa fa-download"></i></br></a>


    @stop

    @section('content')
        <div class="panel panel-default">

        <!-- /.panel-heading -->
        <div class="panel-body">
            <ul class="timeline">


        @foreach ($benchmarks as $benchmark)
            <li>
                <div class="timeline-badge"><i class="fa fa-check"></i>
                </div>
                <div class="timeline-panel">
                    <div class="timeline-heading">
                        <h4 class="timeline-title"> Benchmark with id {{$benchmark->uuid}}</h4>
                        <p><small class="text-muted"><i class="fa fa-clock-o"></i> <?php echo $benchmark->created_at->add(\DateInterval::createFromDateString('+1 hours'))?></small>
                        </p>
                    </div>
                    <div class="timeline-body">
                        <div class="row" style="color: #868e96">
                            <div class="col-sm-3">
                                <h7><i>Benchmark ran on</i></h7>
                                <h6><b> {{$benchmark->provider}}</b></h6>
                            </div>
                            <div class="col-sm-3">
                                <h7><i>Test size</i></h7>
                                <h6><b> {{$benchmark->test_size}} GB</b></h6>
                            </div>
                            <div class="col-sm-3">
                                <h7><i>Head node type</i></h7>
                                <h6><b> {{$benchmark->head_node_type}}</b></h6>
                            </div>
                            <div class="col-sm-3">
                                <h7><i>Head node count</i></h7>
                                @if($benchmark->head_node_count == 1)
                                    <h6><b> {{$benchmark->head_node_count}} head node</b></h6>
                                @else
                                    <h6><b> {{$benchmark->head_node_count}} head nodes</b></h6>
                                @endif
                            </div>
                            <div class="col-sm-3">
                                <h7><i>Worker node type</i></h7>
                                <h6><b> {{$benchmark->worker_node_type}}</b></h6>
                            </div>
                            <div class="col-sm-3">
                                <h7><i>Worker node count</i></h7>
                                <h6><b> {{$benchmark->worker_node_count}} worker nodes</b></h6>
                            </div>
                            <div class="col-sm-3">
                                <h7><i>Tag</i></h7>
                                <h6><b> #{{$benchmark->tag}}</b></h6>
                            </div>
                            @if($benchmark->cost)
                            <div class="col-sm-3">
                                <h7><i>Cost</i></h7>
                                <h6><b> €{{ number_format((float) $benchmark->cost, 2) }}</b></h6>
                            </div>
                            @endif
            <?php


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


                echo '<div class="col-sm-3"> <h7><i>average runtime</i></h7> <h6><b>'  . App\Http\Controllers\Benchmarks\FrontendController::secondsToTime(intval(array_sum($runtimes) / count($runtimes))) . '</b></h6> </div>
                          </table>
                          </div>
                          <div class="benchmark-runtimes" >';
                for ($i = 0; $i < count($runtimes); $i++) {
                    echo '<div class="benchmark-run" time="' . $runtimes[$i] . '">run nr. ' . ($i + 1) . '
                <div class="benchmark-details" >
                        <table style="width:100%">
                            <tr>
                                <th>total time of this run</th>
                                <td>' . App\Http\Controllers\Benchmarks\FrontendController::secondsToTime($runtimes[$i]) . '</td>
                            </tr>
                        </table>
                    </div>
                </div>';
                }
            }
                             ?>

                    </div>
                    <a href="/detailed/{{$benchmark->uuid}}"> Show Details</a>
                </div>
            </li>



        @endforeach

@stop

</div>
</body>
</html>
