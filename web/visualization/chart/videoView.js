/**
 * Created by waldmann on 13.01.14.
 */
VideoView.prototype = new ViewPoint();

VideoView.prototype.constructor = VideoView;

function VideoView() {
	this.margin = null;
	this.width = null;
	this.height = null;
	this.players = [];
	this.currentPlayerObject = null;

	this.overlayLibrary = new VideoViewOverlay();
	this.overlayLibrary.setParent(this);

	this.setContainer = function (containerName) {
		this.container = containerName;
	};


	this.setData = function (inputData) {
		// now get the data into a pure array with associative naming
		this.data = this.manipulateData(JSON.parse(inputData));
		console.log("Data: "+JSON.stringify(this.data));
		if (this.data[0]!=null){
			this.currentTimeCache=parseFloat(this.data[0].timestamp);
			console.log(this.currentTimeCache);
		} else {
			this.currentTimeCache = 0;
		}
	};


	this.onRender = function (context) {
		// keep in mind to reset the view if we re-render this shit
		context.shadowRoot.querySelector('#graph').innerHTML ='';
		context.data.forEach( function (videoObject){
			console.log("preparing: "+JSON.stringify(videoObject));
			var url = "http://127.0.0.1:8080/video/"+JSON.stringify(videoObject);
            console.log("adding new player");
			context.players.push({
				url: url,
				data: videoObject,
				player: null
			});
		})
	};


	// when a time tick occures this event is fired
	this.onTick = function (context, type, value, extraObject)  {
		switch(type){
			case context.TICK_TIME_MANUAL_EVENT:
			case context.TICK_TIME_EVENT:
				// first find the correct video container

                // this is only correct for the very first video
				var timeIntoVideo = (value-extraObject.timeOffset);
				var currentPlayer = null;

				if (context.currentPlayerObject == null ||
					context.currentPlayerObject.player == null ||
					context.currentPlayerObject.data.timestamp>value ||
					context.currentPlayerObject.player.duration()<=timeIntoVideo){
					// we need to switch to a different video. First we need to find it
					for (var i=0;i<context.players.length;i++){
						context.players[i].data.timestamp = parseFloat(context.players[i].data.timestamp);
						if (i+1<context.players.length &&
							context.players[i].data.timestamp<=value &&
							context.players[i+1].data.timestamp>value+timeIntoVideo){

							// finds the player that is able to play the current time frame based on the absolut timestamp and
							// the current position in the video
							if (context.players[i].player == null){
                                console.log("adding new player");
								$(context.shadowRoot.querySelector('#graph')).append('<div id="player-'+i+'"></div>');
								context.players[i].player = Popcorn.smart(context.shadowRoot.querySelector('#player-'+i), context.players[i].url );
							}
                            // set the player variable
                            context.currentPlayerObject = context.players[i];
                            timeIntoVideo = (value-context.players[i].data.timestamp);

							currentPlayer = context.currentPlayerObject.player;
							currentPlayer.autoplay(false);
							currentPlayer.controls(false);
						} else if (i+1==context.players.length &&
							context.players[i].data.timestamp<=value){
							// finds the player that is able to play the current time frame based on the absolut timestamp and
							// the current position in the video
							if (context.players[i].player == null){
                                console.log("adding new player");
								$(context.shadowRoot.querySelector('#graph')).append('<div id="player-'+i+'"></div>');
								context.players[i].player = Popcorn.smart(context.shadowRoot.querySelector('#player-'+i), context.players[i].url );
                            }
                            // set the player variable
                            context.currentPlayerObject = context.players[i];
                            timeIntoVideo = (value-context.players[i].data.timestamp);

							// it gets tricky when we look at the last video
                            // FIXME: Is that correct ? i am pretty sure timeIntoVideo is way to high by now
							if (context.players[i].data.timestamp+
                                context.players[i].player.duration()*1000>timeIntoVideo){
								currentPlayer = context.currentPlayerObject.player;
								currentPlayer.autoplay(false);
								currentPlayer.controls(false);
							}
						} else {
							context.players[i].player = null;
							var container = context.shadowRoot.querySelector('#player-'+i);
							if (container !=null){
								container.innerHTML= "";
							}
						}
					}
				}

				if (currentPlayer!=null){
					var rate = extraObject.tickSpeed;
					currentPlayer.playbackRate(rate);
					if(rate>0 && type!=context.TICK_TIME_MANUAL_EVENT){
                        // check if we are more than 0.5 second off. that would be a real problem
                        if (Math.abs(currentPlayer.currentTime() - (timeIntoVideo/1000)) > 0.5){
                            currentPlayer.currentTime(timeIntoVideo/1000);
                        }
						currentPlayer.play();
					} else {
                        currentPlayer.currentTime(timeIntoVideo/1000);
						currentPlayer.pause();
					}
				}
				break;
			case context.PAUSE_EVENT:
				console.log("pause");
				if (context.currentPlayerObject != null && context.currentPlayerObject.player !=null){
					context.currentPlayerObject.player.pause();
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