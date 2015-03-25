SteeringWheel.prototype = new ViewPoint();

SteeringWheel.prototype.constructor = SteeringWheel;

function SteeringWheel() {
	this.margin = null;
	this.width = null;
	this.height = null;
	this.chart=null;
	this.overlayLibrary = new ViewPointOverlay();
	this.overlayLibrary.setParent(this);

	// this is the way to access the nTr of a certain datafiled
	// call with (searchString) where searchString has to be equal to the entry (timestamp)


	this.setContainer = function (containerName) {
		this.container = containerName;
	};


	this.setData = function (inputData) {
		// now get the data into a pure array with associative naming
		this.data = JSON.parse(inputData);
		this.data = this.manipulateData(this.data);
};


	this.onRender = function (context) {
		console.log($(context.shadowRoot.querySelector('#graph')));
		context.shadowRoot.querySelector('#graph').innerHTML = "";
		// get the first dataset for Each gataGroup and show it
		context.chart = [];
		var startData = {};
		context.data.forEach(function (aDataGroup, index){
			// take aDatagroup and select for dataset:
			startData.name = aDataGroup.name;
			startData.data = [];
			var dataToInsert = aDataGroup.data[0];
			if (dataToInsert.y){
				startData.data.push({y:dataToInsert.y});
			}
			if (dataToInsert.z){
				startData.data.push({y:dataToInsert.z});
			}

			console.log(JSON.stringify(startData));
			var w = 400, h = 300;

			var svg = d3.select(context.shadowRoot.querySelector('#graph')).insert("svg")
				.attr("width", w).attr("height", h)
				.attr("id", "steering-"+aDataGroup.name);
			context.chart.push({name: aDataGroup.name, chart:svg});

			svg.append("circle").attr("r", 20).attr("cx", w/2)
				.attr("cy", h/2).attr("class", "steeringWheelCenter")

			var container = svg.append("g")
				.attr("transform", "translate(" + w/2 + "," + h/2 + ")")

			container.selectAll("g.steeringWheelOuter").data([startData]).enter().append("g")
				.attr("class", "steeringWheelOuter").each(function(d, i) {
					d3.select(this).append("circle").attr("class", "steeringWheelHandle")
						.attr("r", 100);
					d3.select(this).append("circle").attr("r", 10).attr("cx",100)
						.attr("cy", 0).attr("class", "steeringWheelNorth");
				});
			container.selectAll("g.steeringWheelOuterZoom").data([startData]).enter().append("g")
				.attr("class", "steeringWheelOuterZoom").each(function(d, i) {
					d3.select(this).append("circle").attr("r", 20).attr("cx",50)
						.attr("cy", 0).attr("class", "steeringWheelNorth");
				});
			svg.selectAll(".steeringWheelOuter").attr("transform", function(d) {
				console.log("outer:"+(-90+d.data[0].y));
				return "rotate(" + (-90+d.data[0].y) + ")";
			});
			svg.selectAll(".steeringWheelOuterZoom").attr("transform", function(d) {
				console.log("zoom:"+(-90+(d.data[0].y*10)));
				return "rotate(" + (-90+(d.data[0].y*10)) + ")";
			});
		});



	};

	// when a time tick occures this event is fired
	this.onTick = function (context, type, value, extraObject)  {
		var self = this;
		switch(type){
			case context.TICK_TIME_MANUAL_EVENT:
			case context.TICK_TIME_EVENT:
				var dataGroups = context.data;
				dataGroups.forEach(function (aDataGroup, index){
					// take aDatagroup and select for dataset:
					var dataToInsert = null;
					// FIXME: find the current datapoint. this shall be moved to getdatapoint() but needs parameter refactoring


					for(var i=0;i<=aDataGroup.data.length-1;i++){
						var storedObject = aDataGroup.data[i];
						if ( storedObject.x <= value && aDataGroup.data[i+1].x>= value){
							dataToInsert = 	storedObject;
							console.log("datainsert: "+JSON.stringify(dataToInsert));
							break;
						}
					}
					aDataGroup.data.forEach(function (storedObject,index){

					});
					if (dataToInsert!=null){
						var startData = {};
						startData.name = aDataGroup.name;
						startData.data = [];
						if (dataToInsert.hasOwnProperty('y') && dataToInsert.y){
							startData.data.push({y:dataToInsert.y});
						}
						if (dataToInsert.hasOwnProperty('z')&& dataToInsert.z){
							startData.data.push({y:dataToInsert.z});
						}

						console.log("prepared:"+JSON.stringify(startData));

						// our object is ready, now find the series
						context.chart.forEach(function (theChartObject){
							if (theChartObject.name == aDataGroup.name){
								theChartObject.chart.selectAll(".steeringWheelOuter").attr("transform", function(d) {
									console.log("outer:"+(-90+startData.data[0].y));
									return "rotate(" + (-90+startData.data[0].y) + ")";
								});
								theChartObject.chart.selectAll(".steeringWheelOuterZoom").attr("transform", function(d) {
									console.log("zoom:"+(-90+(startData.data[0].y*10)));
									return "rotate(" + (-90+(startData.data[0].y*10)) + ")";
								});
							}
						})
					}
				});
				break;
		}
	};

	this.init = function (context) {
		// if you feel like helping the user, you might want to add the implementations here:
		this.reConfigure(
			this.createReConfigureString(this));
	}
}

