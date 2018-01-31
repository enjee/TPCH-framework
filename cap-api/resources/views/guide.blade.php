<!doctype html>
<html lang="{{ app()->getLocale() }}">
<head>
	<style>
	#accordion .panel-heading { padding: 0;}
#accordion .panel-title > a {
	display: block;
	padding: 0.4em 0.6em;
    outline: none;
    font-weight:bold;
    text-decoration: none;
}

a.nostyle:link {
    text-decoration: inherit;
    color: inherit;
    cursor: auto;
}

a.nostyle:visited {
    text-decoration: inherit;
    color: inherit;
    cursor: auto;
}

#accordion .panel-title > a.accordion-toggle::before, #accordion a[data-toggle="collapse"]::before  {
    content:"\e113";
    float: left;
    font-family: 'Glyphicons Halflings';
	margin-right :1em;
}
#accordion .panel-title > a.accordion-toggle.collapsed::before, #accordion a.collapsed[data-toggle="collapse"]::before  {
    content:"\e114";
}
</style>

    @extends('base')
</head>
<body>

@section('content')
<div class="container">
<div class="row">
	<div class="col-md-12">
		
	</div>
<div id="accordion" class="col-md-12">
  <div class="card">
    <div class="card-header" id="headingTwo">
      <h5 class="mb-0">
        <button class="btn btn-link collapsed" data-toggle="collapse" data-target="#collapseTwo" aria-expanded="false" aria-controls="collapseTwo">
          The benchmark script
        </button>
      </h5>
    </div>
    <div id="collapseTwo" class="collapse" aria-labelledby="headingTwo" data-parent="#accordion">
      <div class="card-body">
         <div class="row" style="padding: 0 0 50px 0">
            <div class="col-md-6">
                <h2>powershell version</h2>
                  To succesfully execute the script, a powershell version of 5 or higher is required. you can check this by opening a clean powershell terminal, and entering the command "$PSVersionTable.PSVersion". Once entered, you should see a headere that says "Major". when it says something else then 5, you'll need to update your powershell.
            </div>
          <div class="col-md-6">
            <img style="width:100%" src="https://s3.eu-central-1.amazonaws.com/tpchdashboard/Images/powershell1-1.jpg">
          </div>
        </div>
        <div class="row" style="padding: 0 0 50px 0">
            <div class="col-md-6">
                <h2>Script download</h2>
                  The benchmark script is available on the projects github page. You can download the project directly as a .zip folder here 
                  <form action="https://github.com/enjee/TPCH-framework/archive/master.zip">
                      <input class="btn btn-primary" type="submit" value="Download project" />
                  </form>
                </div>
              </div>
        <div class="row" style="padding: 0 0 50px 0">
            <div class="col-md-6">
                <h2>Execute the script</h2>
                  once the folder is downloaded, follow the following steps to succesfully execute a bechmark.
                  <ul>
                    <li>Open the root folder & locate "start_benchmark.ps1"</li>
                    <li>Right click & choose "run with powershell"</li>
                    <li>Due to the lack of permissions, the script can prompt you with the option to either allow the script or block it. to execute the benchmark, choose "Y" to allow the script.</li>
                    <li>Choose if you want to execute the benchmark on azure or amazon.</li>
                    <li>Choose from the list of nodes, dataset sizes, node amounts etc. to customize the benchmark.</li>
                    <li>Click "Start benchmark" to start the benchmark, then at the pop-up, check if the benchmark is correct and choose "Accept, login and start.</li>
                    <li>the way to authenticate is shown in the tab "authorization" below</li>
                  </ul>
                  once you executed the benchmark, check its results and compare the results to other benchmarks <a href="http://www.tpch.ga">Here</a>
            </div>
          <div class="col-md-6">
            <img style="width:100%" src="https://s3.eu-central-1.amazonaws.com/tpchdashboard/Images/powershell1-2.jpg">
          </div>
        </div>

      </div>
    </div>
  </div>
  <div class="card">
    <div class="card-header" id="headingOne">
      <h5 class="mb-0">
        <button class="btn btn-link collapsed" data-toggle="collapse" data-target="#collapseOne" aria-expanded="true" aria-controls="collapseOne">
          Authorization
        </button>
      </h5>
    </div>
    <div id="collapseOne" class="collapse show" aria-labelledby="headingOne" data-parent="#accordion">
      <div class="card-body">
      	<div class="row" style="padding: 0 0 50px 0">
        <div class="col-md-6">
        	<h2>Amazon web services </h2>
        	To allow the benchmark to make use of your AWS account to run one of its benchmarks, it needs an access and secret key.
        	These need to be generated from the AWS web dashboard. the option to generate the keys can be found at "account dropdown > My security credentials > Users > Your username > Security credentials > Create access key". You then get access to the access and secret key and save it. these keys need to be entered into the GUI to give the script access to your account.</br>
        </div>
        <div class="col-md-6"><img style="width:100%" src="https://s3.eu-central-1.amazonaws.com/tpchdashboard/Images/aws1-5.jpg"></div>
    </div>
    <div class="row" style="padding: 0 0 50px 0">
    	<div class="col-md-6">
        	<h2>Azure </h2>
        	The authorization process on microsofts azure is a lot simpler, as they give the possibility to allow third parties on your account through the use of oauth. When its time time authorize, the script will show you a pop-up provided by azure, which allows you to log in to your account.
        </div>
        <div class="col-md-6"><img style="width:100%" src="https://s3.eu-central-1.amazonaws.com/tpchdashboard/Images/azure1-1.jpg"></div>
    </div>
      </div>
    </div>
  </div>
@stop
</body>
</html>
