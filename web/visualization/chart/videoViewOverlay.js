/**
 * Created by ins0m on 18.01.14.
 */
VideoViewOverlay.prototype = new ViewPointOverlay();

VideoViewOverlay.prototype.constructor = VideoViewOverlay;

function VideoViewOverlay() {
	this.parentViewPoint = null;
	this.overlays = {};
	var self = this;
	// stop execution of overlay by: overlays['onAverage'].isActive = false;

	this.overlays['onAverage'] = {
		isActive : false,
		overlayAction : function(on){
			this.isActive = on;
			console.log('onAverage would be over '+self.parentViewPoint.data.length+' values');
		}
	}

	this.overlays['onSelect'] =  {
		isActive : false,
		overlayAction : function(on, selectedPoint){
			this.isActive = on;

		}
	}

	this.overlays['onMaxMin'] =  {
		isActive : false,
		overlayAction : function(on){
			this.isActive = on;
			console.log('onMaxMin would be over '+self.parentViewPoint.data.length+' values');
		}
	}

	this.overlays['onCurrentValue'] =  {
		isActive : false,
		overlayAction : function(on){
			this.isActive = on;
			self.parentViewPoint.shadowRoot.querySelector('#graph-info1').innerHTML = self.parentViewPoint.currentTime;
		}
	}

	this.overlays['onMedian'] =  {
		isActive : false,
		overlayAction : function(on){
			this.isActive = on;
			console.log('onCurrentValue would be over '+self.parentViewPoint.data.length+' values');
		}
	}

	this.overlays['onLabels'] =  {
		isActive : false,
		overlayAction : function(on){
			this.isActive = on;
			console.log('onCurrentValue would be over '+self.parentViewPoint.data.length+' values');
		}
	}


	this.overlays['onAnnotation']= {
		isActive : false,
		overlayAction : function(on){
			this.isActive = on;
			console.log('onCurrentValue would be over '+self.parentViewPoint.data.length+' values');
		}
	}
}