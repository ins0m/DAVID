part of visualizer;

/**
* Encapsulates the data fetched. In this object he data is parsed to create a clean and accessable variant of it
*/

class DataDocument {

  Repository dataRepository;
  String dataCall;
  Map<Symbol, dynamic> methodParams;
  List data;
  bool fetched = false;

  // Holds the annotations. Its the only part of this system that assumes and requires you to have a timestamped data.
  // keep in mind that this does not mean that data has to have a timestamp. If it doesnt, you should'nt use
  // the annotations though (just assign null to the repoResult)
  DataAnnotation annotations;
  DataAnnotationLibrary annotationCodes;

  List<ViewPointValues> viewPoints;
  DataviewController parentController;

  String descripion = "Standard data holder based on a method of the specified repository";
  static int domIdCounter = 0;

  DataDocument({this.data}) {
    Log.getInstance().info("DataDocument created");
    viewPoints = new List<ViewPointValues>();
    annotations = new DataAnnotation();
    annotations.parent = this;
  }

  markViewPoints(){
    var goldenRatio = 0.618033988749895;
    var distinctiveColor = parentController.values.dataDocuments.indexOf(this)*goldenRatio;
    distinctiveColor %= 1;
    List<int> rgbColor = ColorTools.hsvToRgb(distinctiveColor, 0.5, 0.95);
    String color = ColorTools.rgbToHex(rgbColor.elementAt(0), rgbColor.elementAt(1), rgbColor.elementAt(2));

    parentController.values.dataDocuments.forEach( (DataDocument ddoc){
      if (ddoc.dataRepository.name == this.dataRepository.name){
        ddoc.viewPoints.forEach( (ViewPointValues vpv){
          vpv.observableController.markForDataDocument(color);
        });
      }
    });
  }

  setRepository(Repository repo) {
    dataRepository = repo;
  }

  HashMap<int, Object> getDataForTimeStamp(int timestamp) {
    HashMap<int, Object> returnData = new HashMap<int, Object>();
    data.forEach((element) {
      if (element.containsKey(database_tags.TAG_TIMESTAMP) && element[database_tags.TAG_TIMESTAMP] == timestamp) {
        returnData[element[database_tags.TAG_TIMESTAMP]] = element;
      }
    });
    return returnData;
  }

  addViewPoint(ViewPointValues v) {
    domIdCounter++;
    // FIXME: This leads to trouble when the viewpoints are not re-initialized (in the creation of the view)
    v.domID="${v.domID}-${domIdCounter}";
    viewPoints.add(v);
    v.dataSource = this;
  }

  removeVisualization(ViewPointValues v) {
    v.dataSource = null;
    viewPoints.remove(v);
  }

  // TODO: This is only a mock. We should read the provided datacall and call the corresponding method
  RepositoryResult createRepositoryResult() {
    // FIXME: It is unclear if this will work. this was once inside the future but obviously the visualization should, with their properties already be available before loading the data.

    Log.getInstance().success("will supply: ${methodParams}");
    InstanceMirror cm = reflect(dataRepository);
    InstanceMirror instanceResult = cm.invoke(new Symbol(dataCall), new List(), methodParams);
    RepositoryResult result = instanceResult.reflectee;

    Function futureFunc = result.dataFutureFunction;
    result.dataFutureFunction = null;
    result.dataFutureFunction = () => futureFunc().then((theData) {
      this.data = theData;
      this.fetched = true;
      Log.getInstance().success("Received data. Adding defined viewPoints to array");
      // we return the data in case somebody wants to wait for it
      return theData;
    });

    return result;
  }

}