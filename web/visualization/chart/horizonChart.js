/**
 * Created by waldmann on 06.12.13.
 */
HorizonChart.prototype = new ViewPoint();

HorizonChart.prototype.constructor = HorizonChart;

function HorizonChart () {
    this.context = null;
    this.metric = null;
	this.overlayLibrary = new ViewPointOverlay();
	this.overlayLibrary.setParent(this);



	this.setData = function (dataIn) {
		var self = this;
		this.data = JSON.parse(dataIn);
		console.log(this.data);
		this.context = cubism.context()
			.step(500 /
				self.data.map(function (d) {
					return d.HR;
				}).length) // Distance between data points in milliseconds
			.size(500) // Number of data points
			.stop();   // Fetching from a static data source; don't update values

		this.metric = this.context.metric(function (start, stop, step, callback) {
			// Creates an array of the price differences throughout the day
			var values = self.data.map(function (d) {
				return d.HR;
			});
			console.log(values);
			callback(null, values);
		});
		console.log(this.metric);
		d3.select(this.shadowRoot).select(this.container).append("div") // Add a vertical rule
	}

	this.onRender = function () {
		var self = this;
		console.log("visualizing");
		d3.select(this.shadowRoot).select(this.container).append("div") // Add a vertical rule
			.attr("class", "rule")         // to the graph
			.call(self.context.rule());


		console.log("added context");
		d3.select(this.shadowRoot).select(this.container)                 // Select the div on which we want to act
			.selectAll(".axis")              // This is a standard D3 mechanism to bind data
			.data(["top", "bottom"])                   // to a graph. In this case we're binding the axes
			.enter()                         // "top" and "bottom". Create two divs and give them
			.append("div")                   // the classes top axis and bottom axis respectively.
			.attr("class", function (d) {
				return d + " axis";
			})
			.each(function (d) {
						  console.log(d)// For each of these axes, draw the axes with 4
				d3.select(this)              // intervals and place them in their proper places.
					.call(self.context.axis()       // 4 ticks gives us an hourly axis.
						.ticks(40).orient(d));
			});

		console.log("added axis");
		d3.select(this.shadowRoot).select(this.container)
			.selectAll(".horizon")
			.data([self.metric, self.metric])
			.enter()
			.insert("div", ".bottom")        // Insert the graph in a div. Turn the div into
			.attr("class", "horizon")        // a horizon graph and format to 2 decimals places.
			.call(this.context.horizon());

		this.context.on("focus", function (i) {
			d3.select(this.shadowRoot).selectAll(".value").style("right",   // Make the rule coincide with the mouse
				i == null ? null : self.context.size() - i + "px");
		});


	}
}