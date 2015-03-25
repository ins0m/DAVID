MapView.prototype = new ViewPoint();

MapView.prototype.constructor = MapView;

function MapView() {
	this.margin = null;
	this.width = null;
	this.height = null;
	this.chart=null;
	this.markers= [];
	this.map = null;
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

		var mapOptions = {
			zoom: 3,
			center: new google.maps.LatLng(42.460123, -180),
			mapTypeId: google.maps.MapTypeId.TERRAIN
		};

		context.map = new google.maps.Map(context.shadowRoot.querySelector('#graph'),
			mapOptions);

		context.data.forEach( function(dataGroup){
			var pathCoord = [];
			dataGroup.data.forEach(function(geoObject){
				if (pathCoord.length==0){
					// its empty, create a starting position
					console.log("empty marker: "+dataGroup.name);
					console.log("adding marker: "+dataGroup.name);
					context.markers.push({
						name:dataGroup.name,
						marker:new google.maps.Marker(
							{position: new google.maps.LatLng(geoObject.lat, geoObject.lng), map: context.map} )});

					context.map.setCenter(new google.maps.LatLng(geoObject.lat, geoObject.lng));
					context.map.setZoom(19);
				}
				pathCoord.push(new google.maps.LatLng(geoObject.lat, geoObject.lng));
			});
			var aCompletePath = new google.maps.Polyline({
				path: pathCoord,
				geodesic: true,
				strokeColor: '#FF0000',
				strokeOpacity: 1.0,
				strokeWeight: 2
			});

			// this happens vor every subject in the dataset
			aCompletePath.setMap(context.map);
			google.maps.event.addListener(aCompletePath, 'click', function(polymouse) {
				var needle = {
					minDistance: 10000000, //silly high
					index: -1,
					latlng: null
				};
				aCompletePath.getPath().forEach(function(routePoint, index){
					var dist = google.maps.geometry.spherical.computeDistanceBetween(polymouse.latLng, routePoint);
					if (dist < needle.minDistance){
						needle.minDistance = dist;
						needle.index = index;
						needle.latlng = routePoint;
					}
				});
				console.log(JSON.stringify({time: dataGroup.data[needle.index].time, point:dataGroup.data[needle.index]}));
				var timePoint = {time: dataGroup.data[needle.index].time, point:dataGroup.data[needle.index]};
				context.overlayLibrary.overlays['onSelectArea'].overlayAction(
					context.overlayLibrary.overlays['onSelectArea'].isActive,
					timePoint
				);
				context.timeCallback(timePoint.time);
				context.onTick(context, context.TICK_TIME_MANUAL_EVENT, timePoint.time,null);
			});
		})
	};

	// when a time tick occures this event is fired
	this.onTick = function (context, type, value, extraObject)  {
		var self=this;
		switch(type){
			case context.TICK_TIME_MANUAL_EVENT:
			case context.TICK_TIME_EVENT:
				// FIXME: Again, we do this on our own. refactor this
				// First, find the value we need
				context.data.forEach( function (aDataGroup){
					context.markers.forEach(function (aMarker){
						if (aDataGroup.name == aMarker.name){
							// we foun a pair, now bring in the next data element we need
							for (var i=0; i< aDataGroup.data.length-1; i++){
								if (aDataGroup.data[i].time <= value && aDataGroup.data[i+1].time>= value){
									// this is our next data object
									aMarker.marker.setPosition( new google.maps.LatLng( aDataGroup.data[i].lat, aDataGroup.data[i].lng ) );
									context.map.setCenter(new google.maps.LatLng( aDataGroup.data[i].lat, aDataGroup.data[i].lng));
									break;
								}
							}
						}
					});
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

