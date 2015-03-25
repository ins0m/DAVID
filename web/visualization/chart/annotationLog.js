/**
 * Created by ins0m on 19.01.14.
 */
/**
 * Created by waldmann on 13.01.14.
 */
AnnotationLog.prototype = new ViewPoint();

AnnotationLog.prototype.constructor = AnnotationLog;

function AnnotationLog() {
	this.margin = null;
	this.width = null;
	this.height = null;
	this.table=null;
	this.overlayLibrary = new ViewPointOverlay();
	this.overlayLibrary.setParent(this);


	this.setContainer = function (containerName) {
		this.container = containerName;
	};


	this.setData = function (inputData) {
		// we ignore the data that enters this chart completely. This chart only gives a handle to a generated table of values
		// Data: For this chart the only visible data is the parents annotationelement.
		// This gets published by the datadocument everytime it changes. We grep these events and extract the data out of it
	};


	this.onRender = function (context) {
		context.shadowRoot.getElementById('graph').innerHTML = '<table class="ui inverted table segment" id="annotationTable"></table>';
        var table = context.shadowRoot.getElementById('annotationTable');
        var head = table.createTHead();
        var row = head.insertRow();
        row.appendChild(document.createElement("th")).innerHTML ="Time";
        row.appendChild(document.createElement("th")).innerHTML ="Name";
        row.appendChild(document.createElement("th")).innerHTML ="Code";
        row.appendChild(document.createElement("th")).innerHTML ="Key";
        row.appendChild(document.createElement("th")).innerHTML ="Type";
        row.appendChild(document.createElement("th")).innerHTML ="Task";
        row.appendChild(document.createElement("th")).innerHTML ="Target";
        row.appendChild(document.createElement("th")).innerHTML ="Coder";
        row.appendChild(document.createElement("th")).innerHTML ="Action";
        context.table = table.appendChild(document.createElement("tbody"))
	};

	// when a time tick occures this event is fired
	this.onTick = function (context,type, value, extraObject)  {
		switch(type){
			case context.TICK_TIME_MANUAL_EVENT:
			case context.TICK_TIME_EVENT:
			case context.PAUSE_EVENT:
				break;
			case context.ANNOTATION_ADD_EVENT:
				console.log(JSON.stringify(extraObject));
				if (extraObject && extraObject != null && extraObject.annotation.hasOwnProperty("annotationName")){
                    var row = context.table.insertRow();
                    row.className="annotation-"+extraObject.annotation.annotationTime;
                    row.insertCell(0).innerHTML =extraObject.annotation.annotationTime;
                    row.insertCell(1).innerHTML =extraObject.annotation.annotationName;
                    row.insertCell(2).innerHTML =extraObject.annotation.annotationCode;
                    row.insertCell(3).innerHTML =extraObject.annotation.annotationKey;
                    row.insertCell(4).innerHTML =extraObject.annotation.annotationType;
                    row.insertCell(5).innerHTML =extraObject.annotation.annotationTask;
                    row.insertCell(6).innerHTML =extraObject.annotation.annotationTarget;
                    row.insertCell(7).innerHTML =extraObject.annotation.coder;
                    var control = row.insertCell(8);
                    var button = document.createElement("div");
                    button.onclick = function (){
                        var elements;
                        while ((elements = context.shadowRoot.getElementsByClassName("annotation-"+extraObject.annotation.annotationTime)).length>0){
                            console.log(elements);
                            for (var i=0; i<elements.length;i++){
                                context.table.removeChild(elements[i]);
                            }
                        }
						extraObject.callback(extraObject.annotation.annotationTime);
                    };
                    button.className="ui button mini negative";
                    button.textContent = "Delete";
                    control.appendChild(button);
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