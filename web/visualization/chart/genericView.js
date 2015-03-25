GenericView.prototype = new ViewPoint();

GenericView.prototype.constructor = GenericView;

function GenericView() {
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
		// My viewPoint is: context;
		// My data is: context.data;
		// My container is : $(context.shadowRoot.querySelector('#graph'));
		// Draw me
	};

	// when a time tick occures this event is fired
	this.onTick = function (context, type, value, extraObject)  {
		var self = this;
		switch(type){
			case context.TICK_TIME_MANUAL_EVENT:
			case context.TICK_TIME_EVENT:
			case context.ANNOTATION_ADD_EVENT:
			case context.ANNOTATION_DELETE_EVENT:
			case context.PAUSE_EVENT:
			case context.RESUME_EVENT:
			case context.SELECTION_EVENT:
			case context.MOUSE_OVER_EVENT:
				// Give me some behaviour
				break;
		}
	};

	this.init = function (context) {
		// if you feel like helping the user, you might want to add the implementations here:
		this.reConfigure(
			this.createReConfigureString(this));
	}
}

