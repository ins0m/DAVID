part of visualizer;
class ViewPointConnector {

  String CONNECTION_ABSOLUTE ="Absolute values";
  String CONNECTION_RELATIVE ="Relative values";

  // this is hard to implement. Here is how it goes:
  // each viewpoint needs besides its metric a reverse metric. a metric takes a time value and gives you a datapoint
  // -> the reverse function takes a datapoint and gives you a time. the plot then works JUST on time
  String CONNECTION_VALUE ="Data values";
  // these variables manage the current state and how a tick is perceived
  // this is a special way of connecting components. It allows not only to send time as a tick parameter but also the current
  // value of the data to be used as a sync parameter
  String connectionType;
  ViewPointController src;
  ViewPointController dst;

  String connectionName = "Test";

  ViewPointConnector(){
    connectionType = CONNECTION_ABSOLUTE;
  }

  setConnectionType(String connection){
    connectionType = connection;
  }


}
