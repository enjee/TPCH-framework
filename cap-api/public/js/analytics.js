var analytics_data = {
    test_size: 0
};


// create the svg
var svg = d3.select("#barsvg"),
    margin = {top: 20, right: 20, bottom: 30, left: 40},
    width = +svg.attr("width") - margin.left - margin.right,
    height = +svg.attr("height") - margin.top - margin.bottom,
    g = svg.append("g").attr("transform", "translate(" + margin.left + "," + margin.top + ")");

function draw(size) {
    // create the svg
    var svg = d3.select("#barsvg"),
        margin = {top: 20, right: 20, bottom: 30, left: 40},
        width = +svg.attr("width") - margin.left - margin.right - 200,
        height = +svg.attr("height") - margin.top - margin.bottom,
        g = svg.append("g").attr("transform", "translate(" + margin.left + "," + margin.top + ")");

// set x scale
    var x = d3.scaleBand()
        .rangeRound([0, width])
        .paddingInner(0.05)
        .align(0.1);

// set y scale
    var y = d3.scaleLinear()
        .rangeRound([height, 0]);

// set the colors
    var z = d3.scaleOrdinal()
        .range(["#1677cb", "#b73946", "#7b6888", "#6b486b", "#a05d56", "#d0743c", "#ff8c00"]);


    var file = "analytics-" + size + ".csv";
// load the csv and create the chart
    d3.csv(file, function (d, i, columns) {
        for (i = 1, t = 0; i < columns.length; ++i) t += d[columns[i]] = +d[columns[i]];
        d.total = t;
        return d;
    }, function (error, data) {
        if (error) throw error;

        var keys = data.columns.slice(1);

        data.sort(function (a, b) {
            return b.total - a.total;
        });
        x.domain(data.map(function (d) {
            return d.Provider;
        }));
        y.domain([0, d3.max(data, function (d) {
            return d.total;
        })]).nice();
        z.domain(keys);

        g.append("g")
            .selectAll("g")
            .data(d3.stack().keys(keys)(data))
            .enter().append("g")
            .attr("fill", function (d) {
                return z(d.key);
            })
            .selectAll("rect")
            .data(function (d) {
                return d;
            })
            .enter().append("rect")
            .attr("x", function (d) {
                return x(d.data.Provider);
            })
            .attr("y", function (d) {
                return y(d[1]);
            })
            .attr("height", function (d) {
                return y(d[0]) - y(d[1]);
            })
            .attr("width", (x.bandwidth()))
            .on("mouseover", function () {
                tooltip.style("display", null);
            })
            .on("mouseout", function () {
                tooltip.style("display", "none");
            })
            .on("mousedown", function (d) {
                if (size == 0) {
                    var href_path = "../timeline?search_uuid_tag=" + d.data.Provider;
                } else {
                    var href_path = "../timeline?search_uuid_tag=" + d.data.Provider + "," + size;
                }

                window.location.replace(href_path);
            })
            .on("mousemove", function (d) {
                var xPosition = d3.mouse(this)[0] - 5;
                var yPosition = d3.mouse(this)[1] - 5;
                tooltip.attr("transform", "translate(" + xPosition + "," + yPosition + ")");
                tooltip.select("text").text((d[1] - d[0]) + " Minutes");
            });

        g.append("g")
            .attr("class", "axis")
            .attr("transform", "translate(0," + (height) + ")")
            .call(d3.axisBottom(x));

        g.append("g")
            .attr("class", "axis")
            .call(d3.axisLeft(y).ticks(null, "s"))
            .append("text")
            .attr("x", 2)
            .attr("y", y(y.ticks().pop()) + 0.5)
            .attr("dy", "0.32em")
            .attr("fill", "#000")
            .attr("font-weight", "bold")
            .attr("text-anchor", "start");


            var legend = g.append("g")
                .attr("font-family", "sans-serif")
                .attr("font-size", 10)
                .attr("text-anchor", "end")
                .selectAll("g")
                .data(keys.slice().reverse())
                .enter().append("g")
                .attr("transform", function (d, i) {
                    return "translate(150," + i * 20 + ")";
                });

            legend.append("rect")
                .attr("x", width - 19)
                .attr("width", 19)
                .attr("height", 19)
                .attr("fill", z);

            legend.append("text")
                .attr("x", width - 24)
                .attr("y", 9.5)
                .attr("dy", "0.32em")
                .text(function (d) {
                    return d;
                });
    });


// Prep the tooltip bits, initial display is hidden
    var tooltip = svg.append("g")
        .attr("class", "tooltip-hover");


    tooltip.append("text")
        .attr("x", 30)
        .attr("dy", "1.2em")
        .style("text-anchor", "middle")
        .attr("font-size", "12px")
        .attr("font-weight", "bold");
}

draw(1);

function redraw(size) {
    analytics_data.test_size = size;
    if (size == 0) {
        document.getElementById("barchart-header").innerHTML = "Benchmark Times Per Provider";
    } else {
        document.getElementById("barchart-header").innerHTML = "Benchmark Times Per Provider - " + size + " Gigabyte";
    }

    svg.selectAll("*").remove();
    draw(size);
}

var linesvg = d3.select("#linesvg"),
    margin = {top: 20, right: 80, bottom: 30, left: 50},
    width = linesvg.attr("width") - margin.left - margin.right,
    height = linesvg.attr("height") - margin.top - margin.bottom,
    g = linesvg.append("g").attr("transform", "translate(" + margin.left + "," + margin.top + ")");

var x = d3.scaleLinear().range([0, width]),
    y = d3.scaleLinear().range([height, 0]),
    z = d3.scaleOrdinal(d3.schemeCategory10);

var line = d3.line()
    .curve(d3.curveBasis)
    .x(function (d) {
        return x(d['Test Size']);
    })
    .y(function (d) {
        return y(d.provider);
    });
d3.csv("priceperformance.csv", function (error, data) {
    if (error) throw error;

    var pp_items = data.columns.slice(1).map(function (id) {
        return {
            id: id,
            values: data.map(function (d) {
                return {'Test Size': d['Test Size'], provider: d[id]};
            })
        };
    });

    x.domain(d3.extent(data, function (d) {
        return d['Test Size'];
    }));

    y.domain([
        d3.min(pp_items, function (c) {
            return d3.min(c.values, function (d) {
                return d.provider;
            });
        }),
        d3.max(pp_items, function (c) {
            return d3.max(c.values, function (d) {
                return d.provider;
            });
        })
    ]);

    z.domain(pp_items.map(function (c) {
        return c.id;
    }));
    g.append("g")
        .attr("class", "axis axis--x")
        .attr("transform", "translate(0," + height + ")")
        .call(d3.axisBottom(x));

    g.append("g")
        .attr("class", "axis axis--y")
        .call(d3.axisLeft(y))
        .append("text")
        .attr("transform", "rotate(-90)")
        .attr("y", 6)
        .attr("dy", "0.71em")
        .attr("fill", "#000")
        .text("Price performance score");

    var pp_item = g.selectAll(".pp_item")
        .data(pp_items)
        .enter().append("g")
        .attr("class", "pp_item");

    pp_item.append("path")
        .attr("class", "line")
        .attr("d", function (d) {
            return line(d.values);
        })
        .style("stroke", function (d) {
            return z(d.id);
        })
        .style("fill", "none");

    pp_item.append("text")
        .datum(function (d) {
            return {id: d.id, value: d.values[d.values.length - 1]};
        })
        .attr("transform", function (d) {
            return "translate(" + x(d.value['Test Size']) + "," + y(d.value.provider) + ")";
        })
        .attr("x", 3)
        .attr("dy", "0.35em")
        .style("font", "10px sans-serif")
        .text(function (d) {
            return d.id;
        });


});

