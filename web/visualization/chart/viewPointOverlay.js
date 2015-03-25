/**
 * Created by ins0m on 18.01.14.
 */
function ViewPointOverlay() {
	this.parentViewPoint = null;
	this.overlays = {};
	this.overlayNames=[];
	this.notifier=null;
	this._annotationCache = [];

	this.setParent = function(val){
		this.parentViewPoint = val;
	};

	// TODO: Refere to the overlay categories found in the stanford paper
	// standard implementation. Can be overwritten. Even in the onRender action or the datamanipulator
	// the standard implementation works with the surrounding document areas
	var self = this;
	this.executeOverlays = function (){
		for(var overlay in this.overlays){
			if (this.overlays.hasOwnProperty(overlay) && this.overlays[overlay].isActive){
				this.overlays[overlay].overlayAction(this.overlays[overlay].isActive);
				hljs.highlightBlock(self.parentViewPoint.shadowRoot.querySelector('#overlay-area-content'));
			}
		}
	};

	this.loadOverlays = function(callback){
		this.overlayNames = [];
		for(var overlay in this.overlays){
			if (this.overlays.hasOwnProperty(overlay)){
				this.overlayNames.push(
					{
						name:overlay
					}
				)
			}
		}
		if (callback){
			this.notifier = callback;
		} else {
			this.notifier();
		}
	};

	this.toggleOverlay = function(name){
		console.log(this.overlays[name].isActive);
		console.log(name+" is now "+this.overlays[name].isActive);
        this.overlays[name].overlayAction(!this.overlays[name].isActive);
		hljs.highlightBlock(self.parentViewPoint.shadowRoot.querySelector('#overlay-area-content'));
	};



	this.overlays['onSelectArea'] = {
		isActive : false,
		/**
		 * We expect a point on the form of : { time: timeData in miliseconds, point: an arbitrarily designed point}
		 * @param on
		 * @param selectedPoint
		 */
		pointCache : null,
		overlayAction : function(on, selectedPoint){
			if (selectedPoint){
				console.log("saving point");
				this.pointCache = selectedPoint;
			}
			if (on && this.pointCache){
				var area;
				self.parentViewPoint.shadowRoot.querySelector('#overlay-area-top').innerHTML = "Selected time: "+this.pointCache.time;
				self.parentViewPoint.shadowRoot.querySelector('#overlay-area-content').innerHTML= "{ \"linkedData\":"+JSON.stringify(self.parentViewPoint.getDataPoint(this.pointCache.time)) +" , \"setData\": "+JSON.stringify(this.pointCache.point)+"}";
				// TODO: We need to propagate such a tick. Problem: We need a handle back to dart for this. This changes to controlflow a bit to much
				// A structure for callbacks might be a good idea at this point.
			} else if (this.isActive && !on){
				self.parentViewPoint.shadowRoot.querySelector('#overlay-area-top').innerHTML = "";
				self.parentViewPoint.shadowRoot.querySelector('#overlay-area-content').innerHTML= "";
			}
			this.isActive = on;
		}
	};

	this.overlays['onMaxMin'] = {
		isActive : false,
		overlayAction : function(on){
			var area;
			if (!this.isActive && on){
				var min,max;
				var minObj = {prop : null, data:self.parentViewPoint.data[0].data[0]};
				if (minObj.data.hasOwnProperty('y')){
					minObj.prop = 'y';
					min = minObj.data.y} else
				if (minObj.data.hasOwnProperty('z')){
					minObj.prop = 'z';
					min = minObj.data.z}

				var maxObj = {prop : null, data:self.parentViewPoint.data[0].data[0]};
				if (maxObj.data.hasOwnProperty('y')){
					maxObj.prop = 'y';
					max = maxObj.data.y} else
				if (maxObj.data.hasOwnProperty('z')){
					maxObj.prop = 'z';
					max = maxObj.data.z}
				self.parentViewPoint.data.forEach(function ( dataObj) {
					dataObj.data.forEach( function (entry) {
						if (entry[minObj.prop] < min){
							min = entry[minObj.prop];
						}
						if (entry[maxObj.prop] > max){
							max = entry[maxObj.prop];
						}
					});
				});

				self.parentViewPoint.shadowRoot.querySelector('#overlay-area-top').innerHTML = "Selected time: "+this.pointCache.time;
				self.parentViewPoint.shadowRoot.querySelector('#overlay-area-content').innerHTML= "Minimum value: "+min+" ;Maximum value: "+max;
			} else if (this.isActive && !on){
				self.parentViewPoint.shadowRoot.querySelector('#overlay-area-top').innerHTML = "";
				self.parentViewPoint.shadowRoot.querySelector('#overlay-area-content').innerHTML= "";

			}
			this.isActive = on;
		}
	};

	this.overlays['onAverage'] = {
		isActive : false,
		overlayAction : function(on){
			var area;
			if (!this.isActive && on){
				var avg=0, avgBase;
				var avgObj = {prop : null, data:self.parentViewPoint.data[0].data[0]};
				if (avgObj.data.hasOwnProperty('y')){
					avgObj.prop = 'y';} else
				if (avgObj.data.hasOwnProperty('z')){
					avgObj.prop = 'z';}
				self.parentViewPoint.data.forEach(function ( dataObj) {
					dataObj.data.forEach( function (entry) {
						avg += entry[avgObj.prop];
						avgBase++;
					});
				});

				self.parentViewPoint.shadowRoot.querySelector('#overlay-area-top').innerHTML = "Selected time: "+this.pointCache.time;
				self.parentViewPoint.shadowRoot.querySelector('#overlay-area-content').innerHTML= "Avg value: "+(avg/avgBase);
			} else if (this.isActive && !on){
				self.parentViewPoint.shadowRoot.querySelector('#overlay-area-top').innerHTML = "";
				self.parentViewPoint.shadowRoot.querySelector('#overlay-area-content').innerHTML= "";

			}
			this.isActive = on;
		}
	}

	this.overlays['onCurrentValue'] = {
		isActive : false,
		overlayAction : function(on){
			this.isActive = on;
			var area
			if (on){

				self.parentViewPoint.shadowRoot.querySelector('#overlay-area-top').innerHTML = "time: "+self.parentViewPoint.currentTimeCache;
				self.parentViewPoint.shadowRoot.querySelector('#overlay-area-content').innerHTML= JSON.stringify(self.parentViewPoint.getDataPoint(self.parentViewPoint.currentTimeCache));

			} else if (this.isActive && !on){
				self.parentViewPoint.shadowRoot.querySelector('#overlay-area-top').innerHTML = "";
				self.parentViewPoint.shadowRoot.querySelector('#overlay-area-content').innerHTML= "";

			}
		}
	}


	this.overlays['onAnnotation']= {
		isActive : false,
		overlayAction : function(on, annotationData){
			this.isActive = on;
			console.log("unimplemented");
		}
	}

}