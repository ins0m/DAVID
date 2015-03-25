BarChart.prototype = new ViewPoint();

BarChart.prototype.constructor = BarChart;

function BarChart() {
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
		console.log(JSON.stringify(context.data));
		console.log($(context.shadowRoot.querySelector('#graph')));

		// get the first dataset for Each gataGroup and show it
		var startSeries = [];
		context.data.forEach(function (aDataGroup, index){
			// take aDatagroup and select for dataset:
			var startData = {};
			startData.name = aDataGroup.name;
			startData.data = [];
			var dataToInsert = aDataGroup.data[0];
			if (dataToInsert.y){
				startData.data.push({y:dataToInsert.y});
			}
			if (dataToInsert.z){
				startData.data.push({y:dataToInsert.z});
			}
			startSeries.push(startData);
		});
		console.log(JSON.stringify(startSeries));
		context.chart = new Highcharts.Chart(
			{
				chart: {
					type: 'column',
					animation: false,
					marginRight: 10,
					renderTo: context.shadowRoot.querySelector('#graph')
				},plotOptions: {
					series: {
						turboThreshold: 0
					}
				},
				series: startSeries
			});

		var min = context.data[0].data[0].y;
		var max = context.data[0].data[0].y;
		context.data.forEach(function ( dataGroup) {
			dataGroup.data.forEach(function (dataEntry){
				if (dataEntry.y < min){
					min = dataEntry.y;
				}
				if (dataEntry.y > max){
					max = dataEntry.y;
				}
			})
		});

		context.overlayLibrary.overlays['onMaxMin'] = {
			isActive : false,
			overlayAction : function(on){
				// tricky: this method will be called each tick. so we check if it is an init or not
				if (!this.isActive && on){
					console.log("values : "+min+" "+max);
					context.chart.yAxis[0].addPlotLine({
						value : min,
						id: 'min',
						color : 'green',
						dashStyle : 'shortdash',
						width : 2,
						label : {
							text : 'Minimum'
						}});
					context.chart.yAxis[0].addPlotLine ({
						value : max,
						id: 'max',
						color : 'red',
						dashStyle : 'shortdash',
						width : 2,
						label : {
							text : 'Maximum'
						}});
				} else if (this.isActive && !on)  {
					console.log("deleting onMaxMin");
					context.chart.yAxis[0].removePlotLine('min');
					context.chart.yAxis[0].removePlotLine('max');
				}
				this.isActive = on;

			}
		};

		context.overlayLibrary.overlays['onAverage'] = {
			isActive : false,
			overlayAction : function(on){
				// tricky: this method will be called each tick. so we check if it is an init or not
				if (!this.isActive && on){
					console.log("values : "+min+" "+max);

					context.chart.yAxis[0].addPlotLine ({
						value : (max+min)/2,
						id: 'avg',
						color : 'yellow',
						dashStyle : 'shortdash',
						width : 2,
						label : {
							text : 'Average'
						}});
				} else if (this.isActive && !on)  {
					console.log("deleting onAvergae");
					context.chart.yAxis[0].removePlotLine('avg');
				}
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

					console.log("time:"+value+", aDatagroup:"+JSON.stringify(aDataGroup));

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
						if (dataToInsert.hasOwnProperty('z') && dataToInsert.z){
							startData.data.push({y:dataToInsert.z});
						}

						console.log("prepared:"+JSON.stringify(startData));

						// our object is ready, now find the series
						context.chart.series.forEach(function (theSeries){
							if (theSeries.name == startData.name){
								theSeries.data.forEach(function(thePoint, pointIndex){
									thePoint.update(startData.data[pointIndex],true,{duration:50});
								})
							}
						})
					};
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

