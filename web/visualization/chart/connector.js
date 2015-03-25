Connector.prototype = new ViewPoint();

Connector.prototype.constructor = Connector;

function Connector() {
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


	};

	// when a time tick occures this event is fired
	this.onTick = function (context, type, value, extraObject)  {
		var self = this;
		switch(type){
			case context.TICK_TIME_MANUAL_EVENT:
			case context.TICK_TIME_EVENT:

				break;
		}
	};

	this.init = function (context) {
		// if you feel like helping the user, you might want to add the implementations here:
		this.reConfigure(
			this.createReConfigureString(this));
	};

	this.setData = function (data) {
		return null;
	};

	this.manipulateData = function(data){
		return null;
	};

	this.getDataPoint = function(time){
		return null;
	};

	this.getTimePoint = function(datapoint){
		return null;
	}

}

