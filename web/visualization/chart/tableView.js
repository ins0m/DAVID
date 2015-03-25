/**
 * Created by waldmann on 13.01.14.
 */
TableView.prototype = new ViewPoint();

TableView.prototype.constructor = TableView;

function TableView() {
    this.margin = null;
    this.width = null;
    this.height = null;
    this.table=null;
	this.overlayLibrary = new ViewPointOverlay();
	this.overlayLibrary.setParent(this);
	this.lastTr=null;

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
		context.shadowRoot.getElementById('graph').innerHTML = '<table class="ui table inverted segment" id="tableView-'+context.container+'"></table>';
		context.data.items = context.data.items.map( function(d){
			return context.getDataPoint(d);
		});
		context.table = $(context.shadowRoot.querySelector('#tableView-'+context.container)).dataTable( {
			"aaData":  context.data.items,
			"aoColumns": context.data.header
		});

		var elem = context.data.header.length-1;
		var min = context.getDataPoint(context.data.items[0])[elem];
		var max = context.getDataPoint(context.data.items[0])[elem];
		var minTr;
		var maxTr;
		context.data.items.forEach(function ( dataObj) {
			console.log("looking at "+dataObj);
			if (parseFloat(context.getDataPoint(dataObj)[elem]) < parseFloat(min)){
				min = parseFloat(context.getDataPoint(dataObj)[elem]);
			}
			if (parseFloat(context.getDataPoint(dataObj)[elem]) > parseFloat(max)){
				console.log("performing onMaxMin on"+min+" max:"+max);
				max = parseFloat(context.getDataPoint(dataObj)[elem]);
			}
		});


		context.overlayLibrary.overlays['onMaxMin'] = {
			isActive : false,
			overlayAction : function(on){
				console.log("performing onMaxMin on"+min+" max:"+max);
				// tricky: this method will be called each tick. so we check if it is an init or not
				if (!this.isActive && on){
					minTr = context.table.fnGetNodeWithNumerical(min);
					if (minTr){
						minTr.className = "success";
					}
					maxTr = context.table.fnGetNodeWithNumerical(max);
					if (maxTr){
						maxTr.className = "error";
					}
				} else if (this.isActive && !on) {
					minTr = context.table.fnGetNodeWithNumerical(min);
					if (minTr){
						minTr.className = minTr.className.replace("success","");
					}
					maxTr = context.table.fnGetNodeWithNumerical(max);
					if (maxTr){
						maxTr.className = maxTr.className.replace("error","");
					}
				}
				minTr = null;
				maxTr = null;
				this.isActive = on;
			}
		};
	};

	// when a time tick occures this event is fired
	this.onTick = function (context, type, value, extraObject)  {
		switch(type){
			case context.TICK_TIME_MANUAL_EVENT:
			case context.TICK_TIME_EVENT:
				if (context.lastTr!=null){
					context.lastTr.className = context.lastTr.className.replace("warning","")
				}

				context.lastTr = context.table.fnGetNodeWithNumericalRange(value);
				if (context.lastTr!=null){
					context.lastTr.className = "warning";
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