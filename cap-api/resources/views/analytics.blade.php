<!doctype html>
<body>
@extends('base')

</div>
<div class="content-wrapper">
    <div class="container-fluid">





            <div id="main">
                <h1 id="barchart-header">Benchmark Times Per Provider - 1 Gigabyte</h1>

                <p>This barchart displays the average time it took to complete a single run of the benchmark for a selected dataset size. <br><br>
                    When a bar is clicked you will be brought to our timeline page displaying all the benchmarks for the selected provider at the displayed dataset size.<br><br></p>
                <div class="dropdown">
                    <button class="btn btn-secondary dropdown-toggle" type="button" id="dropdownMenuButton"
                            data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                        Select dataset size
                    </button>
                    <div class="dropdown-menu" aria-labelledby="dropdownMenuButton">
                        <a class="dropdown-item" href="javascript:redraw(0)">All sizes</a>
                        <a class="dropdown-item" href="javascript:redraw(1)">1 GB</a>
                        <a class="dropdown-item" href="javascript:redraw(10)">10 GB</a>
                        <a class="dropdown-item" href="javascript:redraw(100)">100 GB</a>
                        <a class="dropdown-item" href="javascript:redraw(1000)">1000 GB</a>
                    </div>



                </div>
                <svg id="barsvg" width="960" height="500"></svg>

        </div>

        <div id="main-linechart">
            <h1 id="linechart-header">Price Performance Rating</h1>
            <p>This chart displays the average price to performance ratio per provider per dataset size, with the score on the <b>Y</b> axis and the dataset size on the <b>X</b> axis.<br><br>
                This is displayed through a performance score which is derived through the following formula: <b>Score = ( ( 1/average_time ) / average_price) * dataset_size^2)) * 1000</b><br>
                Where <b>average_time</b> is the average execution time for a given provider at a certain <b>dataset_size</b> and <b>average_price</b> is the average cost
                to run the benchmark in question for the provider at the <b>dataset_size</b>.
                </p>
            <svg id="linesvg" width="960" height="500"></svg>
        </div>
    </div>
</div>


<script src="https://d3js.org/d3.v4.min.js"></script>
<script src="{{ asset('js/analytics.js') }}"></script>

</body>
</html>
