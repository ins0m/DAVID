/**
 * Created by waldmann on 11.12.13.
 */
function ViewPoint() {
    this.controller = null;
    this.data = null;
    this.container=null;
    this.shadowRoot=null;
	this.windowEndpoints = null;
    this.initDrag = false;
	this.overlayLibrary = new ViewPointOverlay();
	this.overlayLibrary.setParent(this);
	this.currentDataPointCache = null;
	this.currentTimeCache = null;
	this.extraObjectCache = null;
	this.timeCallback = null;

	this.chartDimmer = null;
    this.jsArea = null;
    this.CssArea = null;
    this.OverlayMenu = null;
    this.OverlayArea = null;
    this.ConnectionMenu = null;
	this.PlaySettingsMenu = null;
	this.containerArea = null;
	this.Play = null;

    /**
     * The following functions are supplied on a "per source" basis and describe how data is put into graphs
     */
	// manipulate initial data
    this.dataMetric = "";
	// make datalinkage happen
	this.reverseDataMetric = "";
    // the function that gets applied to the received data
    this.dataManipulator = "";
	// will be dynamically added once the soure arrives. still, we add it this way that it is discoverable
	this.renderAction = "";
	this.tickAction = "";

	// this method holds the source for setting and unsetting the following actions. It _could_ use
	// or return a configuration object for this. But at this point we simply supply "self"
	this.modifiedSource = null;
	// skip to the end of the file to see how it is preloaded. Needs to be done this way since javascript evalutes func line
	// by line, not per scope

	// tick events. come from the controller
	this.TICK_TIME_EVENT = 0;
	this.TICK_TIME_MANUAL_EVENT = 5;

	// interaction events, come  from visualization in one or the other way and need to be propagated
	this.ANNOTATION_ADD_EVENT = 2;
	this.ANNOTATION_DELETE_EVENT = 6;
	this.PAUSE_EVENT = 3;
	this.RESUME_EVENT = 4;
	this.OVERLAY_EVENT = 7

	// the events that javascript triggers on the controller
	this.mouseOverCallback = null;
	this.annotationDeleteCallback = null;

	Messenger.options = {
		extraClasses: 'messenger-fixed messenger-on-bottom messenger-on-right',
		theme: 'air'
	}

	// saves the corresponding dart controller that maanges the content and internal behaviour of this viewpoint
	this.setController = function (dartController) {
		this.controller = dartController;
	}

	// this may be unnecessary due to event conventions
	this.setControllerCallback = function (dartControllerCallback) {
		this.controllerCallback = dartControllerCallback;
	}

	// this may be unnecessary due to event conventions
	this.setShadowRoot = function (shadowRoot) {
		this.shadowRoot = shadowRoot;
	}

	// this may be unnecessary due to event conventions
	this.setTimeCallback = function (timeCallback) {
		this.timeCallback = timeCallback;
	}

	// this may be unnecessary due to event conventions
	this.setContainer = function (container) {
		this.container = container;
	}


	// The data to be visualized
	this.setData = function (data) {
		throw("setData is not implemented");
	}

	this.manipulateData = function(data){
		console.log("activating manipualte data");
		var msg = Messenger().run({
			errorMessage: 'Loading dataset',
			action: function(opts) {
					return opts.error({
						status: 500,
						readyState: 0,
						responseText: 0
					});
			}
		});
		console.log("Evaling manipualte func");
		var func = eval("("+this.dataManipulator+")");
		msg.update({
			message: 'Dataresponse loaded',
			type: 'success',
			actions: false
		});
		return func(this, data);
	}

	this.getDataPoint = function(time){
		var func = eval("("+this.dataMetric+")");
		return func(this, time);
	}

	this.getTimePoint = function(datapoint){
		var func = eval("("+this.reverseDataMetric+")");
		return func(this, datapoint);
	}

	this.reConfigure = function (source) {
		var func = eval("("+source+")");
		this.modifiedSource = func;
		// IMPORTANT: we supply the self object as a reference so that the values can be reset!
		func(this);
	}

	this.render = function () {
		this.shadowRoot.getElementById('graph').innerHTML = "";
		if (!this.renderAction){
			this.onRender(this);
		} else {
			var func = eval("("+this.renderAction+")");
			func(this);
		}
		if (this.shadowRoot.querySelector('#load-spinner')!=null){
			this.shadowRoot.querySelector('#load-spinner').remove();
		}
	}

	this.tick = function (type, value, extraObject) {
		this.currentTimeCache = value;
		if (extraObject != null){
			this.extraObjectCache = extraObject;
		} else {
			extraObject = this.extraObjectCache;
		}
		if (!this.tickAction){
			this.onTick(this,type, value, extraObject);
		} else {
			var func = eval("("+this.tickAction+")");
			func(this,type, value, extraObject);
		}
		this.overlayLibrary.executeOverlays();
	}

	// the time baseline (or whatever is used as a baseline) to sync up viewPoints
	this.setBaseline = function (timeLineData) {
		throw("setBaseline is not implemented");
	}

	this.setUpEndpoint = function (dartAddCallback, dartDeleteCallback){

		if (this.windowEndpoints != null && this.windowEndpoints.length>0){
			return;
		} else {
			this.windowEndpoints = [];
		}
		console.log("endpoint created for "+this.container);
		$(this.shadowRoot.getElementsByClassName("dropdown-toggle")).dropdown();
		var self = this;
		var sourceAnchors = [
			[ 0.25, 1, 0, 1 ],
			[ 0.75, 1, 0, 1 ],
			[ 0.25, 0, 0, -1 ],
			[ 0.75, 0, 0, -1 ]
		];
		var endpointOptions = {
			isSource:true,
			isTarget:true,
			paintStyle:{
				lineWidth:2,
				strokeStyle:"#fff",
				fillStyle:"#fff"
			},
			endpoint: ["Rectangle",{width:15,height:15}],
            endpointStyle: {
                fillStyle: "#5b9ada"
            },

			connector :  ["Flowchart", {cornerRadius:5}],
			connectorStyle: { lineWidth:5, strokeStyle:'#000' },
            connectorPaintStyle:{ strokeStyle:"blue", lineWidth:10 },

            hoverPaintStyle:{ fillStyle:"#5bc0de" },
			maxConnections:-1,
			anchor: sourceAnchors
		 };
		jsPlumb.bind("connection", function(i,c) {
			// make sure this only gets executed for the parent, not the child
			console.log(self.container+" -> "+i.connection.sourceId);
			if (self.container == i.connection.sourceId) {
				console.log(i.connection);
				dartAddCallback(i.connection.targetId);
                var overlay = i.connection.getOverlay("label");
                overlay.setLabel(self.container+" -> "+i.connection.targetId)
			}
		});
		jsPlumb.bind("click", function(conn) {
			jsPlumb.detach(conn);
		});
		// bind beforeDetach interceptor: will be fired when the click handler above calls detach, and the user
		// will be prompted to confirm deletion.
		jsPlumb.bind("beforeDetach", function(conn) {
			// make sure this only gets executed for the parent, not the child
			console.log("Deleting "+self.container+" -> "+conn.sourceId);
			dartDeleteCallback(conn.sourceId,conn.targetId)
			return true;
		});
		var concreteEndpoint = [
			[ "PlainArrow", { width:15, length:20, location:1, id:"arrow" }],
            [ "Label", { label:"", id:"label", cssClass: "connection-label" } ]
		];
		this.windowEndpoints.push(jsPlumb.addEndpoint(this.container, { anchor: sourceAnchors[0], connectorOverlays: concreteEndpoint}, endpointOptions ));
		this.windowEndpoints.push(jsPlumb.addEndpoint(this.container, { anchor: sourceAnchors[1], connectorOverlays: concreteEndpoint }, endpointOptions ));
		this.windowEndpoints.push(jsPlumb.addEndpoint(this.container, { anchor: sourceAnchors[2], connectorOverlays: concreteEndpoint }, endpointOptions ));
		this.windowEndpoints.push(jsPlumb.addEndpoint(this.container, { anchor: sourceAnchors[3], connectorOverlays: concreteEndpoint }, endpointOptions ));

	}

	this.toggleDraggable = function () {

        if (this.chartDimmer==null){
            this.chartDimmer = $(this.shadowRoot.querySelector('#chart-container')).dimmer({
                transition: 'slide down',
                closable: false
            });
        }
        this.chartDimmer.dimmer('toggle').dimmer('add content', '<div class="content"><div class="center"><i class="icon move"></i>Move component</div></div>');

		if (!this.initDrag){
			jsPlumb.draggable(this.container);
			this.initDrag = true;

        } else {
			jsPlumb.toggleDraggable(this.container);
        }


	}

	// Events for the subclasses
	this.onDataSet = function () {
		throw("onDataSet is not implemented");
	}

	this.onExternalSelect = function (selectedDataObject, timeLineDataElement) {
		throw("select is not implemented");
	}

	// this is the corresponding event when this viewPoint has been selected
	this.onSelect = function (selectedDataObject, timeLineDataElement) {
		throw("selecteD is not implemented");
	}

	// when a time tick occures this event is fired
	this.onTick = function (context, type, value, extraObject) {
		throw("Tick is not implemented");
	}

	// this event is called whenever the view needs to be redrawn
	this.onRender = function (context) {
		throw("render is not implemented");
	}

	// this event is called whenever the view needs to be redrawn
	this.init = function (context) {
		throw("init is not implemented");
	}

	// UI interaction
	this.toggleJsArea = function (text){
        this.genericFadeTransition(this.jsArea);
	};

    this.toggleCssArea = function (text){
        this.genericFadeTransition(this.CssArea);
    };

    this.toggleOverlayMenu = function (){
        this.genericFadeTransition(this.OverlayMenu);
    };

    this.toggleOverlayArea = function (){
        this.genericFadeTransition(this.OverlayArea);
    };

    this.toggleConnectionMenu = function (){
        this.genericFadeTransition(this.ConnectionMenu);
    };

	this.toggleAnnotationMenu = function (){
		this.genericFadeTransition(this.AnnotationMenu);
	};

	this.togglePlaySettingsMenu = function (){
		this.genericFadeTransition(this.PlaySettingsMenu);
	};

	this.toggleBackground = function (){
		$(this.shadowRoot.querySelector('#graph')).toggleClass('transparent-chart');
	};

	this.togglePresentation = function (on){
		var self = this;

		[$(this.ConnectionMenu),
		$(this.OverlayMenu),
		$(this.CssArea),
		$(this.jsArea),
		$(this.AnnotationMenu),
		$(this.ConnectionMenu)].forEach( function (elem){
			if (elem.transition('is visible') && !elem.transition('is animating')  && on ){
				self.genericFadeTransition(elem);
			}
		});

		console.log(on);
		[$("#dataview-settings"),
		$("#master-top-bar"),
		$(this.shadowRoot.querySelector('#options-bar')),
		$("#master-sidebar-small"),
		$("#master-sidebar-big")].forEach( function (elem){
			if (elem.transition('is visible') && !elem.transition('is animating') && on ){
				self.genericFadeTransition(elem);
			} else if  (!elem.transition('is visible') && !on &&  elem != $("#master-sdebar-big")){
				self.genericFadeTransition(elem);
			}
		});

		[$(".connection-label"),
		$("._jsPlumb_endpoint")].forEach( function (groups){
				console.log('foreach');
				groups.each( function(i,elem){
					if ($(elem).transition('is visible') && !$(elem).transition('is animating') && on ){
						self.genericFadeTransition($(elem));
					} else if (!$(elem).transition('is visible') && !on ){
						self.genericFadeTransition($(elem));
					}
				});
			});

	};

	this.toggleContainer = function (){
		this.genericFadeTransition(this.containerArea);
	};



	this.genericFadeTransition = function(elem){
        var self = this;
        elem.transition({
            animation : 'slide down',
            complete: function(){
                jsPlumb.repaint(self.container);
            }
        });
        jsPlumb.repaint(self.container);
    }

	this.toggleZoom = function (){

		var theBigBar = $('#master-sidebar-big');
		var theSmallBar =$('#master-sidebar-small');
		if (theBigBar.sidebar('is open')){
			theBigBar.sidebar('toggle');
			$('#master-sidebar-expand-icon').removeClass().addClass("right arrow icon");
		} else if (theSmallBar.sidebar('is open')) {
			theSmallBar.sidebar('toggle');
			$('#master-sidebar-expand-icon').removeClass().addClass("right arrow icon");
		}
		zoom.to({element: document.querySelector('#'+this.container)
		});
	}

    this.initUi =function(){

        this.jsArea = $(this.shadowRoot.querySelector('#javascript-container'))
            .transition({
                animation : 'slide down',
                duration  : '100ms'});
        this.CssArea = $(this.shadowRoot.querySelector('#css-container'))
            .transition({
                animation : 'slide down',
                duration  : '100ms'});
        this.OverlayMenu = $(this.shadowRoot.querySelector('#overlay-menu'))
            .transition({
                animation : 'slide down',
                duration  : '100ms'});
        this.OverlayArea = $(this.shadowRoot.querySelector('#overlay-area'))
            .transition({
                animation : 'slide down',
                duration  : '100ms'});
        this.ConnectionMenu = $(this.shadowRoot.querySelector('#connection-bar'))
           .transition({
               animation : 'slide down',
               duration  : '100ms'});
		this.AnnotationMenu = $(this.shadowRoot.querySelector('#annotation-codes'))
			.transition({
				animation : 'slide down',
				duration  : '100ms'});
		this.PlaySettingsMenu = $(this.shadowRoot.querySelector('#play-settings'))
			.transition({
				animation : 'slide down',
				duration  : '100ms'});

		this.containerArea = $(this.shadowRoot.querySelector('#chart-container'));
		$(this.shadowRoot.querySelectorAll('.play-setting-popup'))
			.popup({
				on: 'focus'
			});
		hljs.highlightBlock(this.shadowRoot.querySelector('#overlay-area-content'));
    }

	// we create a overwriteable function here and prelaod the functions content:
	this.createReConfigureString = function(context){
		var func = "function(root) {\n"+
			"/*\n"+
			" change the current rendering\n"+
			" */\n"+
			"root.renderAction = "+(context.onRender.toString().isEmpty ? "null" : context.onRender.toString())+"\n"+
			"/*\n"+
			" change the ticking\n"+
			" */\n"+
			"root.tickAction = "+(context.onTick.toString().isEmpty ? "null" : context.onTick.toString())+"\n"+
			"/*\n"+
			" manipulate initial data\n"+
			" */\n"+
			"/* root.dataMetric = "+(context.dataMetric.toString().isEmpty ? "null" : context.dataMetric.toString())+"*/\n"+
			"/*\n"+
			" make datalinkage happen\n"+
			" */\n"+
			"/* root.reverseDataMetric = "+(context.reverseDataMetric.toString().isEmpty ? "null" : context.reverseDataMetric.toString())+"*/\n"+
			"/*\n"+
			" the function that gets applied to the received data\n"+
			" */\n"+
			"/* root.dataManipulator = "+(context.dataManipulator.toString().isEmpty ? "null" : context.dataManipulator.toString())+"*/\n"+
			"}";
		console.log(func);
		return func;
	};

}