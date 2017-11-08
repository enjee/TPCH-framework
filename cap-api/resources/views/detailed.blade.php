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
                    <div class="card-header"><i class="fa fa-area-chart"></i> Benchmark informatie</div>
                    <div class="card-body">
                        <p>Uitgevoerd op: {{$benchmark->provider}}</p>
                        <p>Grootte: {{$benchmark->test_size}}</p>
                    </div>
                    <div class="card-footer small text-muted">Uitgevoerd op {{$benchmark->created_at}}</div>
                @endif
            </div>
            @if ($benchmark)
                @foreach($measurement as $m)
                    <div class="card mb-3">
                        <div class="card-header"><i class="fa fa-table"></i> <b> Run {{$m->run}}</b>
                            <button style="float: right; background: transparent; border: 0;" class="fa fa-chevron-down" type="button" data-toggle="collapse" data-target="#card_{{$m->run}}" aria-controls="card_{{$m->run}}" aria-expanded="false" aria-label="Toggle navigation"></button></div>
                        <div class="card-body collapse" id="card_{{$m->run}}">
                            <table class="table table-bordered" id="dataTable" width="100%" cellspacing="0">
                                <thead>
                                <tr>
                                    <th>Query</th>
                                    <th>Tijdsduur</th>
                                </tr>
                                </thead>
                                <tbody>
                                @for($count = 1; $count < 23; $count++)
                                    <tr>
                                        <td><i> Query {{$count}}</i></td>
                                        <td> {{ object_get($m, "q{$count}" ) }} seconden</td>
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
