$(document).ready(function() {
    var a,b,c;

    var benchmarks = $('.benchmark-runtimes');
    for (var i = 0; i < benchmarks.length; i++){
        setWidth(benchmarks[i]);
    }
});

function setWidth(benchmark){
    var maxtime = -1;
    var curtime;
    var children = $($(benchmark)[0]).children();
    for (var i = 0; i <= $(children).length; i++){
        curtime = $(children[i]).attr('time');
        curtime = parseInt(curtime);
        maxtime = parseInt(maxtime)
        if (curtime > maxtime){
            maxtime = curtime;
        }
    }
    for (var i = 0; i < $(children).length; i++){
        var percentage = ($(children[i]).attr('time') / maxtime) * 100;
        $(children[i]).attr('style', 'width:' +percentage +  '%; background-color:rgb(10, ' +parseInt((180 - percentage)* 255 / 100, 10  ) + ', 10);');

    }

}