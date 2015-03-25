part of visualizer;

/**
* This class facilitates access to the data sources itself.
* It pprovides an easy access to a set of resources. If those are not sufficient
* a user might use the generic method to access via the bridge pattern resources
*/

// This might be refactored into the query pattern. So we can create Heartrate querys etc. indipendent on this class but very specific to the corresponding query

abstract class Repository {
  Future loadRequest(String request);
  String name = "Empty repository";
  MetricLibrary implementation;

/**
  * Querys a generic string as an SQL query
  */
  Future<List> loadGenericRequest({String genericRequest}) {
    return futureRequest(
        genericRequest
    );
  }

  /**
  * Leave the content of the request up to the implementation of the repository
  */
  futureRequest(String request);

  injectImplementation();

  createMetricBlock(RepositoryResult result, {groupName, timestampName, val1, val2, val3, val4}){

    result
      ..addMetric(new TableViewValues(),
    new MetricLibrary()
      ..dataManipulator = implementation.createTableManipulator(null,["time",timestampName],null)
      ..dataMetric = implementation.createTableMetric
      ..reverseDataMetric = implementation.createTableReverseMetric
    )
      ..addMetric(new LineChartValues(),
    new MetricLibrary()
      ..dataManipulator = implementation.createHighchartsManipulator(["name",groupName], ["x",timestampName], ["y",val1])
      ..dataMetric = implementation.createHighchartsMetric(["x"])
      ..reverseDataMetric = implementation.createHighchartsReverseMetric(["x"],["y"],1)
    )
      ..addMetric(new MapViewValues(),
    new MetricLibrary()
      ..dataManipulator = implementation.createHighchartsManipulator(["name",groupName], ["time",timestampName], ["lat",val1], val2NamePair:["lng",val2])
      ..dataMetric = implementation.createHighchartsMetric(["time"])
      ..reverseDataMetric = implementation.createHighchartsReverseMetric(["time"],["lat"],0.001,val2NamePair:["lng"])
    )
      ..addMetric(new HorizonChartValues(),
    new MetricLibrary()
      ..dataManipulator = implementation.DEFAULT_MANIPULATOR
      ..dataMetric = implementation.createDefaultMetric(timestampName,val1)
      ..reverseDataMetric = implementation.createDefaultReverseMetric()
    )
      ..addMetric(new BarChartValues(),
    new MetricLibrary()
      ..dataManipulator = implementation.createHighchartsManipulator(["name",groupName], ["x",timestampName], ["y",val1])
      ..dataMetric = implementation.createHighchartsMetric(["x"])
      ..reverseDataMetric = implementation.createHighchartsReverseMetric(["x"],["y"],0.5)
    )
      ..addMetric(new PieChartValues(),
    new MetricLibrary()
      ..dataManipulator = implementation.createHighchartsManipulator(["name",groupName], ["x",timestampName], ["y",val1])
      ..dataMetric = implementation.createHighchartsMetric(["x"])
      ..reverseDataMetric = implementation.createHighchartsReverseMetric(["x"],["y"],0.5)
    )
      ..addMetric(new SteeringWheelValues(),
    new MetricLibrary()
      ..dataManipulator = implementation.createHighchartsManipulator(["name",groupName], ["x",timestampName], ["y",val1])
      ..dataMetric = implementation.createHighchartsMetric(["x"])
      ..reverseDataMetric = implementation.createHighchartsReverseMetric(["x"],["y"],0.5)
    )
      ..addMetric(new SpeedViewValues(),
    new MetricLibrary()
      ..dataManipulator = implementation.createHighchartsManipulator(["name",groupName], ["x",timestampName], ["y",val1], val2NamePair:["z",val2])
      ..dataMetric = implementation.createHighchartsMetric(["x"])
      ..reverseDataMetric = implementation.createHighchartsReverseMetric(["x"],["y"],0.5)
    )
      ..addMetric(new GenericViewValues(),
    new MetricLibrary()
      ..dataManipulator = implementation.createHighchartsManipulator(["name",groupName], ["x",timestampName], ["y",val1])
      ..dataMetric = implementation.createHighchartsMetric(["x"])
      ..reverseDataMetric = implementation.createHighchartsReverseMetric(["x"],["y"],0.5)
    )
      ..addMetric(new VideoViewValues(),
    new MetricLibrary()
      ..dataManipulator = implementation.DEFAULT_MANIPULATOR
      ..dataMetric = "//not used"
      ..reverseDataMetric = "//not used"
    )
      ..addMetric(new AnnotationLogValues(),
    new MetricLibrary()
      ..dataManipulator = implementation.DEFAULT_MANIPULATOR
      ..dataMetric = "//not used"
      ..reverseDataMetric = "//not used"
    );
  }
}