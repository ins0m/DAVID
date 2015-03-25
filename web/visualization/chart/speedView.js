SpeedView.prototype = new ViewPoint();

SpeedView.prototype.constructor = SpeedView;

function SpeedView() {
	this.margin = null;
	this.width = null;
	this.height = null;
	this.chart=[];
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
		console.log(JSON.stringify(context.data));
		console.log($(context.shadowRoot.querySelector('#graph')));
		// get the first dataset for Each gataGroup and show it
		var startData = {};
		context.data.forEach(function (aDataGroup, index){
			context.shadowRoot.querySelector('#graph').insertAdjacentHTML('beforeend',"<div id=speed-"+aDataGroup.name+"></div>");
			// take aDatagroup and select for dataset:
			startData.name = aDataGroup.name;
			startData.data = [];
			var dataToInsert = aDataGroup.data[0];
			var val = 0;
			if (dataToInsert.y){
				val +=dataToInsert.y
				console.log(val);
			}
			if (dataToInsert.z){
				val +=dataToInsert.z
				console.log(val);
			}
			console.log(val);
			startData.data.push({y:val});
			console.log(JSON.stringify(startData));
            var tempChart = {
                name: aDataGroup.name,
                data: aDataGroup.data,
                chart : new Highcharts.Chart(
                    {
                        chart: {
                            type: 'gauge',
                            plotBorderWidth: 0,
                            plotShadow: false,
                            renderTo:context.shadowRoot.querySelector("#speed-"+aDataGroup.name+""),
                            backgroundColor: null

                        },

                        title : {
                            text : "Subject " + aDataGroup.name
                        },

                        pane: {
                            startAngle: -150,
                            endAngle: 150
                        },

                        // the value axis
                        yAxis: {
                            min: 0,
                            max: 200,

                            minorTickInterval: 'auto',
                            minorTickWidth: 1,
                            minorTickLength: 10,
                            minorTickPosition: 'inside',
                            minorTickColor: '#666',

                            tickPixelInterval: 30,
                            tickWidth: 2,
                            tickPosition: 'inside',
                            tickLength: 10,
                            tickColor: '#666',
                            labels: {
                                step: 2,
                                rotation: 'auto'
                            },
                            title: {
                                text: 'km/h ?'
                            }
                        },

                        series: [startData],
                        plotOptions: {
                            series: {
                                turboThreshold: 0
                            }
                        }
                    })
            };
			context.chart.push(tempChart);

		});

        context.overlayLibrary.overlays['onMaxMin'] = {
            isActive : false,
            overlayAction : function(on){
                console.log("performing onMaxMin");
				var self = this;
                context.chart.forEach(
                    function (chartObject){
						// tricky: this method will be called each tick. so we check if it is an init or not
						if (!self.isActive && on){
							var min = chartObject.data[0].y;
							var max = chartObject.data[0].y;
							chartObject.data.forEach(function ( dataEntry) {
								if (dataEntry.y < min){
									min = dataEntry.y;
								}
								if (dataEntry.y > max){
									max = dataEntry.y;
								}
							});
							chartObject.chart.yAxis[0].addPlotBand({
								from: min,
								to: min+2,
								id: 'min',
								color: 'green' // green
							});
							chartObject.chart.yAxis[0].addPlotBand({
								from: max,
								to: max+2,
								id: 'max',
								color: 'red' // green
							});
						} else if (self.isActive && !on)  {
							chartObject.chart.yAxis[0].removePlotBand('min');
							chartObject.chart.yAxis[0].removePlotBand('max');
						}
                    }
                );
				this.isActive = on;
            }
        };

		context.overlayLibrary.overlays['onAverage'] = {
			isActive : false,
			overlayAction : function(on){
				console.log("performing onAverage");
				var self = this;
				context.chart.forEach(
					function (chartObject){
						// tricky: this method will be called each tick. so we check if it is an init or not
						if (!self.isActive && on){
							var avg = 0;
							var c = 0;
							chartObject.data.forEach(function ( dataEntry) {
								avg += dataEntry.y;
								c++;
							});
							chartObject.chart.yAxis[0].addPlotBand({
								from: (avg)/c,
								to: (avg/c)+2,
								id: 'avg',
								color: 'yellow' // green
							});
						} else if (self.isActive && !on)  {
							chartObject.chart.yAxis[0].removePlotBand('avg');
						}
					}
				);
				this.isActive = on;
			}
		};
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


					for(var i=0;i<aDataGroup.data.length-1;i++){
						var storedObject = aDataGroup.data[i];
						if ( storedObject.x <= value && aDataGroup.data[i+1].x>= value){
							dataToInsert = 	storedObject;
							console.log("datainsert: "+JSON.stringify(dataToInsert));
							break;
						}
					}

					if (dataToInsert!=null){
						var startData = {};
						startData.name = aDataGroup.name;
						startData.data = [];
						var val = 0;
						if (dataToInsert.hasOwnProperty('y') && dataToInsert.y){
							val +=dataToInsert.y
						}
						if (dataToInsert.hasOwnProperty('z') && dataToInsert.z){
							val +=dataToInsert.z
						}
						startData.data.push({y:val});

						//console.log("prepared:"+JSON.stringify(startData));
						// our object is ready, now find the series
						context.chart.forEach(function (dataChart){
							if (dataChart.name == startData.name){
								dataChart.chart.series[0].points[0].update(startData.data[0],true,false);
							}
						});
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

