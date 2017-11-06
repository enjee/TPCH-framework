<!doctype html>
<html lang="{{ app()->getLocale() }}">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

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

        .full-height {
            height: 100vh;
        }

        .flex-center {
            align-items: center;
            display: flex;
            justify-content: center;
        }

        .position-ref {
            position: relative;
        }

        .top-right {
            position: absolute;
            right: 10px;
            top: 18px;
        }

        .content {
            text-align: center;
        }

        .title {
            font-size: 84px;
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
            background-color: #cccccc;
            margin: 10px;
            display: inline-block;
            width: 90%;
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
            width: 49%;
        }
    </style>
</head>
<body>
<!--<div class="flex-center position-ref full-height">-->
<!--    @if (Route::has('login'))-->
<!--    <div class="top-right links">-->
<!--        @auth-->
<!--        <a href="{{ url('/home') }}">Home</a>-->
<!--        @else-->
<!--        <a href="{{ route('login') }}">Login</a>-->
<!--        <a href="{{ route('register') }}">Register</a>-->
<!--        @endauth-->
<!--    </div>-->
<!--    @endif-->
<!--    <div class="benchmark">-->
<!--        <span class="benchmark-title">Benchmark number 1</span>-->
<!--        <div class="benchmark-container">-->
<!---->
<!--            <div class="benchmark-info">-->
<!--                <table style="width:100%">-->
<!--                    <tr>-->
<!--                        <th>Created at:</th>-->
<!--                        <td>2017-11-02 13:44:36</td>-->
<!--                    </tr>-->
<!--                    <tr>-->
<!--                        <th>Provider</th>-->
<!--                        <td>Azure</td>-->
<!--                    </tr>-->
<!--                    <th>DataSize</th>-->
<!--                    <td>30 GB</td>-->
<!--                    </tr>-->
<!--                    <tr>-->
<!--                        <th>Total time of this run</th>-->
<!--                        <td>6213</td>-->
<!--                    </tr>-->
<!--                </table>-->
<!---->
<!--            </div>-->
<!--            <div class="benchmark-runtimes">-->
<!--                <div class="benchmark-run">RUN NR. 1!-->
<!--                    <div class="benchmark-details">-->
<!--                        <table style="width:100%">-->
<!--                            <tr>-->
<!--                                <th>Total time of this run</th>-->
<!--                                <td>6213</td>-->
<!--                            </tr>-->
<!--                        </table>-->
<!--                    </div>-->
<!--                </div>-->
<!--                <div class="benchmark-run">RUN NR. 2!-->
<!--                    <div class="benchmark-details">-->
<!--                        <table style="width:100%">-->
<!--                            <tr>-->
<!--                                <th>Total time of this run</th>-->
<!--                                <td>6213</td>-->
<!--                            </tr>-->
<!--                        </table>-->
<!--                    </div>-->
<!--                </div>-->
<!--                <div class="benchmark-run">-->
<!--                    RUN NR. 3!-->
<!--                    <div class="benchmark-details">-->
<!--                        <table style="width:100%">-->
<!--                            <tr>-->
<!--                                <th>Total time of this run</th>-->
<!--                                <td>6213</td>-->
<!--                            </tr>-->
<!--                        </table>-->
<!--                    </div>-->
<!--                </div>-->
<!--            </div>-->
<!--        </div>-->
<!--    </div>-->
    <div class="content">
        <?php
        foreach ($benchmarks as $benchmark) {
            echo '<a href="/api/benchmark/'. object_get($benchmark, "uuid") . '"> <div class="benchmark">
                    <span class="benchmark-title">
                    Benchmark id ' . object_get($benchmark, "id") .
                    '</span>
                            <div class="benchmark-container">
                            <div class="benchmark-info">
                                <table style="width:100%">
                                    <tr>
                                        <th>Created at: </th>
                                        <td>'. object_get($benchmark, "created_at") .'</td>
                                    </tr>
                                    <tr>
                                        <th>Provider</th>
                                        <td>'. object_get($benchmark, "provider") .'</td>
                                    </tr>
                                        <th>DataSize</th>
                                        <td>'. object_get($benchmark, "test_size") .'</td>
                                    </tr>';

            $runtimes = array(0,0,0);
            $runindex = 0;
            foreach (object_get($benchmark, "measurements") as $measurement) {
                $currentrun = 0;

                for ($i = 0; $i < 22; $i++) {
                    $currentrun += object_get($measurement, "q{$i}" );
                }
                $runtimes[$runindex] = $currentrun;
                $runindex++;
            }

            echo '<tr><th>average time of this benchmark</th><td>'. intval(($runtimes[0] + $runtimes[1] + $runtimes[2])/3) .'</td>
                          </tr>
                          </table>
                          </div>
                          <div class="benchmark-runtimes">';
            for($i = 0; $i < count($runtimes); $i++){
                echo '<div class="benchmark-run">Run Nr. '. ($i+1) . '
                <div class="benchmark-details">
                        <table style="width:100%">
                            <tr>
                                <th>Total time of this run</th>
                                <td>'. $runtimes[$i]. '</td>
                            </tr>
                        </table>
                    </div>
                </div>';
            }

                echo '</div></div></div></a>';
        }
        //            object_get($m, "q{$count}" );
        ?>
    </div>
</div>
</body>
</html>
