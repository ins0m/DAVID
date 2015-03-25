var pg      = require('pg'),
    express = require('express'),
	fs 		= require('fs');

var app = express();
var conString = "postgres://<postgreString>";
var client = new pg.Client(conString);
var clientMap = [];

app.all('*', function(req, res, next) {
	res.header("Access-Control-Allow-Origin", "*");
	res.header("Access-Control-Allow-Headers", "X-Requested-With");
	res.setHeader('Content-Type', 'text/plain');
	next();
});

client.connect(function(err) {
	if(err) {
		return console.error('could not connect to postgres', err);
	} else {
		app.get('/sql/:query', function(req, res){
			console.log("SQL command");
			querySQL(req.params.query, function(val){
				res.send(JSON.stringify(val));
			});
		});
	}
});

app.get('/file/:file', function(req, res){
	console.log("File request");
	loadFile(req.params.file, function(val){
		res.send(JSON.stringify(
			{data: val}
		));
	});
});

app.get('/video/:file', function(req, res){
	console.log("File request " +req.params.file.replace(/\|/g,"/"));
	// the information tag of the file was transmitted. the supplied object contains everything we need to search the index
	var result = loadVideoFromIndex(req.params.file.replace(/\|/g,"/"),
		function(result){
			if (result != null){
				console.log("sending video");
				res.sendfile(result.relative);
			}
		});
});

// call this to update the index
app.get('/videoIndex/update', function(req, res){
	console.log("requesting update");
	// the information tag of the file was transmitted. the supplied object contains everything we need to search the index
	updateVideoIndex(function (val){
		res.send(JSON.stringify(
			val
		));
	});
});


app.listen(8080);
console.log('NodeJS shell started');


var WebSocketServer = require('ws').Server
	, wss = new WebSocketServer({port: 8081,
        autoAcceptConnections: false});
wss.on('connection', function(ws) {
	console.log("request");
	/**
	 * when receiving messages from the net connector the message has to ahve this form:
	 * a) register: { register:true, name:"myname" }
	 * b) data: { name:"myname", target:"target", data:SERIALIZED_DART_DATA }
	 */
	ws.on('message', function(message) {
		console.log('received: %s', message);
		var messageObject =JSON.parse(message);
		console.log('received: %s', messageObject);
		if (messageObject.register!=null && messageObject.register==true){
			for (var i=0;i<clientMap.length;i++){
				if (clientMap[i].name == messageObject.name){
					clientMap.splice(i,1);
					i--;
				}
			}
			clientMap.push({
				name:messageObject.name,
				socket: ws
			});
			clients = [];
			clientMap.forEach( function (client){
				clients.push(client.name);
			});
			ws.send(JSON.stringify(clients));
			console.log("saved connection");
		} else {
			// we assume a correct message. error free distributed apps is out of the scope of this thesis
			// first find the target
			clientMap.forEach(function(targetObject){
				if (targetObject.name==messageObject.target){
					console.log("sending to target");
					// found it. this happens only once because the array does not contain duplicates
					targetObject.socket.send(JSON.stringify(messageObject));
				}
			})
		}
	});

    console.log("request finished");
});


function querySQL(query,callback){
     client.query(query, function(err, result) {
        console.log("Answering SQL query: "+query);
        if(err) {
            console.error('error running query: ', err);
            return ;
        }
        console.log("Data log:\n "+JSON.stringify(result.rows));
        callback(result.rows);
     });
}

function loadFile(query,callback){
	var stat = fileSystem.statSync(query);
	fs.readFile(query, function (err, data) {
		console.log("Reading file: "+query);
		if (err) {
			throw err;
		}
		console.log(data);
		callback(data);
	});
}

// Things are highly domain specific from here on. I open source them but assume that any programmer
// working on data fetching will replace them with mure elaborate methods.

// convert using ffmpeg to ogg:

function loadVideoFromIndex(video, callback){
	var  fs  = require('fs')
	var result = null;
	fs.readFile('./videoIndex.json', function (err, data) {
		// Walker options
		var index = {};
		var videoObject =  JSON.parse(video);
		if (data!=null) {
			index =  JSON.parse(data);
			index.forEach( function (indexObject){

				if (indexObject.study.year==parseInt(videoObject.year) &&
					indexObject.study.letter==videoObject.letter.toLowerCase() &&
					indexObject.subject==parseInt(videoObject.subject) &&
					indexObject.part==parseInt(videoObject.part) &&
					indexObject.segment==videoObject.segment.toLowerCase() &&
					indexObject.cam==parseInt(videoObject.cam)){
					// we can still have multiple files. namely: the broken files
					console.log("found file");
					result = indexObject;
				}
			});
		}
		console.log(JSON.stringify(result));
		callback(result);
	});
}


/**
 */
function updateVideoIndex(callback){
	var walk    = require('walk')
		,fs  = require('fs')

	fs.readFile('./videoRepository.json', function (err, data) {
		// Walker options
		var configData =  JSON.parse(data);
		configData.files.forEach( function(startpath, index) {
			console.log("Searching in: "+startpath)
			indexFolder(startpath, function(collected){
				// collected all files
				if (index == 0){
					// now save the date to the directory. Use a static file for that
					fs.writeFile("./videoIndex.json",JSON.stringify(collected) , function(err) {
						if(err) {
							// collected not filled
						} else {
							// collected filled
						}
						callback(collected);
					});
				}
			});
		});
	});
}

function indexFolder(path, callback){
	var walk    = require('walk')
		,fs         = require('fs');
	var files   = [];

	var walker = walk.walk(path, { followLinks: false });
	walker.on('file', function(root, stat, next) {
		if (stat.name.match(/.*\.(ogv?)/i)) {
			// stat contains all the file information
			var fullPath = root+'/'+stat.name;
			stat.root = root;
			stat.relative = fullPath.substr(path.length+1,fullPath.length);
			stat.subject = parseInt(stat.name.split("_")[1]);
			stat.segment =  stat.name.split("_")[2].toLowerCase();
			stat.study =  { year: parseInt(stat.name.split("_")[0].match(/[0-9]+/g)[0]),
							letter:stat.name.split("_")[0].match(/[A-Za-z]+/g)[0].toLowerCase()};
			stat.cam = parseInt(stat.name.split("_")[4]);
			stat.part = parseInt(stat.name.split("_")[5].replace(".ogv",""));
			console.log('root:'+root+' relative:'+stat.relative+' file:'+stat.name);
			files.push(stat);
		}
		next();
	});
	walker.on('end', function() {
		callback(files);
	});
}