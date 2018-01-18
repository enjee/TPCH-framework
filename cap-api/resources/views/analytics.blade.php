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
        <a class="dropdown-item" href="analytics/1">1 GB</a>
        <a class="dropdown-item" href="analytics/10">10 GB</a>
        <a class="dropdown-item" href="analytics/100">100 GB</a>
        <a class="dropdown-item" href="analytics/1000">1000 GB</a>
      </div>


        <div id="main">
            <svg width="960" height="500"></svg>
        </div>
</div>



<script src="https://d3js.org/d3.v4.min.js"></script>
    <script type="text/javascript">

        var azure = {!! $azure !!}

    </script>
<script src="{{ asset('js/analytics.js') }}"></script>

</body>
</html>
