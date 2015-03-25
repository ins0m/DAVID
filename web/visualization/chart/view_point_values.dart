part of visualizer;

/**
* Holds all the values of a viewPoint. This class is used to introduce inheritance to the hollywood principle based angular.dart
*/
class ViewPointValues{

  DataDocument dataSource = null;
  String domID = "chart";
  ShadowRoot  shadowRoot;

  // this is the chart object of this visualization.
  var chart;
  // overlays of the corresponding chat
  List<String> overlayNames = new List();
  // this is the controller for this observable viewPoint
  ViewPointController observableController;
  // This is the list of all the dependent visualizations that react on certain events (the listeners)
  List<ViewPointConnector> observer = new List<ViewPointConnector>();

  String name ="A chart";
  String description = "A standard viewpoint";

/**
  * the metric function returns a json with corresponding values in the javascript files. This is how we connect the very flexible
  * viewPoints with a certain kind of data.
*/
  String dataMetric = "// nothing was provided by the library";
  String dataManipulator  = "// nothing was provided by the library";
  String reverseDataMetric  = "// nothing was provided by the library";
  String metricExample = """
	 function metric(val) {
	    return {
	      x: data[val]['timestamp'],
	      y: data[val]['HR']
	    }
	  }
	""";

  String savedCss = "";
  String savedJs = "";

  // this might be encapsulated into a separate class ?
  int currentTime = 0;
  // the absolute beginning of the dataset. This is equals to currentTime in the beginning
  int timeOffset = 0;
  // how fast does a second in the data run ? realtime is 1
  int tickSpeed = 1;
  // how often does a tick occure. 1000/24 frames per second = 41,6-> so we tick every 40 milliseconds to be smooth
  int tickInterval = 40;



  ViewPointValues(){
    observableController = new ViewPointController();
    observableController.setValues(this);
  }
}