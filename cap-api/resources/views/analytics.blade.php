<!doctype html>
<body>
@extends('base')

</div><div class="content-wrapper">
    <div class="container-fluid">


    <div class="dropdown">
      <button class="btn btn-secondary dropdown-toggle" type="button" id="dropdownMenuButton" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
        Select testset size
      </button>
      <div class="dropdown-menu" aria-labelledby="dropdownMenuButton">
          <a class="dropdown-item" href="javascript:redraw(0)">All sizes</a>
          <a class="dropdown-item" href="javascript:redraw(1)">1 GB</a>
          <a class="dropdown-item" href="javascript:redraw(10)">10 GB</a>
          <a class="dropdown-item" href="javascript:redraw(100)">100 GB</a>
          <a class="dropdown-item" href="javascript:redraw(1000)">1000 GB</a>
      </div>


        <div id="main">
            <h1 id="barchart-header">Benchmark Times Per Provider</h1>
            <svg width="960" height="500"></svg>
        </div>

</div>

    <div class="content-wrapper">
        <div class="container-fluid">


            <div id="main-linechart">
                <h1 id="linechart-header">Price Performance Rating</h1>
                <svg id="linesvg" width="960" height="500"></svg>
            </div>
        </div>
    </div>


<script src="https://d3js.org/d3.v4.min.js"></script>
<script src="{{ asset('js/analytics.js') }}"></script>

</body>
</html>
