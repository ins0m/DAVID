LineChart.prototype = new ViewPoint();

LineChart.prototype.constructor = LineChart;

function LineChart() {
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
		context.data.forEach( function (obj){
			obj.lineWidth = 1
		});
		context.chart = new Highcharts.StockChart( {
			rangeSelector : {
				selected : 1
			},
			chart: {
				renderTo: context.shadowRoot.querySelector('#graph'),
				backgroundColor: null
			},
			plotOptions: {
				series: {
					turboThreshold: 0,
					cursor: 'pointer',
					point: {
						events: {
							click: function() {
								var timePoint = {time: this.x, point:{x: this.x,y:this.y}};
								context.overlayLibrary.overlays['onSelectArea'].overlayAction(
									context.overlayLibrary.overlays['onSelectArea'].isActive,
									timePoint
								);
								context.timeCallback(timePoint.time);
								context.onTick(context, context.TICK_TIME_MANUAL_EVENT, timePoint.time,null);
							}
						}
					}
				}
			},
			scrollbar : {
				enabled : false
			},
			series : context.data,
			tooltip: {
				pointFormat: '<span style="color:{series.color}">{series.name}</span>: <b>{point.y}</b> ({point.change}%)<br/>',
				valueDecimals: 2
			}
		});

        var min = context.data[0].data[0].y;
        var max = context.data[0].data[0].y;
		var avg = 0;
		var avgBase = 0;
        context.data.forEach(function ( dataGroup) {
            dataGroup.data.forEach(function (dataEntry){
                if (dataEntry.y < min){
                    min = dataEntry.y;
                }
                if (dataEntry.y > max){
                    max = dataEntry.y;
                }
				avg = avg + dataEntry.y;
				avgBase++;
            })
        });

        context.overlayLibrary.overlays['onMaxMin'] = {
            isActive : false,
            overlayAction : function(on){
                console.log("performing onMaxMin : "+on);

                // tricky: this method will be called each tick. so we check if it is an init or not
				if (!this.isActive && on){
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

		context.overlayLibrary.overlays['onLine'] = {
			isActive : false,
			overlayAction : function(on){
				console.log("performing onLine : "+on);

				// tricky: this method will be called each tick. so we check if it is an init or not
				if (!this.isActive && on){
					context.chart.series.forEach( function (obj){
						obj.update({
							lineWidth : 0,
							marker : {
								enabled : true,
								radius : 2
							}
						});
					});
				} else if (this.isActive && !on)  {
					context.chart.series.forEach( function (obj){
						obj.update({
							lineWidth : 1,
							marker : {
								enabled : true,
								radius : 0
							}
						});
					});
				}
				this.isActive = on;

			}
		};

		context.overlayLibrary.overlays['onAverage'] = {
			isActive : false,
			overlayAction : function(on){
				console.log("performing onMaxMin : "+on);

				// tricky: this method will be called each tick. so we check if it is an init or not
				if (!this.isActive && on){
					context.chart.yAxis[0].addPlotLine({
						value : avg/avgBase,
						id: 'avg',
						color : 'yellow',
						dashStyle : 'shortdash',
						width : 2,
						label : {
							text : 'Average'
						}});
				} else if (this.isActive && !on)  {
					console.log("deleting onAverage");
					context.chart.yAxis[0].removePlotLine('avg');
				}
				this.isActive = on;

			}
		};
		console.log(context.overlayLibrary.overlays.hasOwnProperty('onLine') );
		context.overlayLibrary.loadOverlays();

	};

	// when a time tick occures this event is fired
	this.onTick = function (context, type, value, extraObject)  {
		switch(type){
			case context.TICK_TIME_MANUAL_EVENT:
			case context.TICK_TIME_EVENT:
				$.each(context.chart.xAxis[0].plotLinesAndBands,function(){
					if(this.id==='currentDataMarker')
					{
						this.destroy();
					}
				});
				context.chart.xAxis[0].addPlotLine({
					value: value,
					width: 1,
					color: 'red',
					//dashStyle: 'dash',
					id: 'currentDataMarker'
				});
				break;
			case context.ANNOTATION_ADD_EVENT:
			case context.ANNOTATION_DELETE_EVENT:
				if (extraObject && extraObject != null && extraObject.hasOwnProperty("annotationName")){
					console.log("->"+JSON.stringify(extraObject));
					context.overlayLibrary.overlays['onAnnotation'].overlayAction(
						context.overlayLibrary.overlays['onAnnotation'].isActive,
						extraObject
					);
				}
				break;
		}
	};

	this.init = function (context) {
		// if you feel like helping the user, you might want to add the implementations here:
		this.reConfigure(
			this.createReConfigureString(this));
	}
}

