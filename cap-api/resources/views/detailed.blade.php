<!doctype html>
<html lang="{{ app()->getLocale() }}">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
    <title>Laravel</title>

    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css?family=Raleway:100,600" rel="stylesheet" type="text/css">

    <!-- Styles -->
    <style>
        html, body {
            background-color: #fff;
            color: #636b6f;
            font-family: 'Raleway', sans-serif;
            font-weight: 100;
            height: 100vh;
            margin: 0;
        }

        .content {
            text-align: center;
        }


        .links > a {
            color: #636b6f;
            padding: 0 25px;
            font-size: 12px;
            font-weight: 600;
            letter-spacing: .1rem;
            text-decoration: none;
            text-transform: uppercase;
        }

    </style>
</head>
<body>

<div class="container-fluid">
    <div class="row content">
        <div class="col-sm-3 sidenav hidden-xs">
            <h2>Benchmark informatie </h2>
        </div>
        <br>

        <div class="col-sm-9">
            <div class="well">
                @if($benchmark)
                    <h1>Uitgevoerd op: {{$benchmark->provider}}</h1>
                    <h3>Grootte: {{$benchmark->test_size}}</h3>
                @endif

            </div>
            <div class="row">
                @if ($benchmark)
                    @foreach($measurement as $m)
                        <div class="well">
                        <h1><b> Run {{$m->run}}</b></h1>
                        </div>
                        <div class="row">
                            @for($count = 1; $count < 23; $count++)
                                <div class="col-sm-2">
                                    <div class="well" style="padding: 10px">
                                        <h4>Query {{$count}}</h4>
                                        <p>{{ object_get($m, "q{$count}" ) }} seconden</p>
                                    </div>
                                </div>
                            @endfor
                        </div>
                    @endforeach
                @endif
            </div>
        </div>
    </div>
</div>

</body>
</html>
