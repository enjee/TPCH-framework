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
            @if($measurement)
            <div class="card-header"><i class="fa fa-area-chart"></i> Recorded log for measurement {{$measurement->id}}</div>
            <div class="card-body">
                <div class="row" style="color: #868e96">
                    <div class="col-sm-8">
                        <h6><i>Log</i></h6>
                        <h4> {{$measurement->log}}</h4>
                    </div>
                </div>
            </div>
            @endif
        </div>
    </div>
</div>
@stop



</body>
</html>
