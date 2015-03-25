part of visualizer;

class DataviewValues {
  List<DataDocument> dataDocuments = new List<DataDocument>();
  String description = "Standard data view //Replace this line";
  String name = "A dataview";
  bool published = true;
  // this line identifies the view throughout the whole visualizer. It has to be set once the view is created or it
  // will overwrite the standardview
  int dbKey;
}

@NgController(
    selector: '[dataview]',
    publishAs: 'dataview'
)
class DataviewController {
  DataviewValues values = null;
  Router router;
  DataviewStorage storage;


  DataviewController(Router router, RouteProvider routeProvider) {
    this.router = router;
    Log.getInstance().info("Loaded the dataview controller ${routeProvider.routeName}}");
    int _dbKey = int.parse(routeProvider.parameters['viewName']);
    DataviewStorage storage = new DataviewStorage();
    storage.open()
    .then( (waitForEmptyReturn) => storage.loadDataViewWithId(_dbKey))
    .then( (dataviewValue) {
      values = dataviewValue;
      values.dataDocuments.forEach( (dd) {
        dd.parentController = this;
      });
      Log.getInstance().info("Read all fixtures");
    });
  }

  void addDataDocument(DataDocument d){
    this.values.dataDocuments.add(d);
  }

  void update(){
    // the contents have been changed. drop the view, recreate it an reload it
    DataviewStorage storage = new DataviewStorage();
    values.dataDocuments.forEach( (dd) {
      dd.parentController = null;
      dd.viewPoints.forEach( (ViewPointValues vpv){
        vpv.observableController = new ViewPointController();
        vpv.observableController.setValues(vpv);

        vpv.observer = new List<ViewPointConnector>();
        vpv.chart = null;
        vpv.shadowRoot = null;
      });
    });
    storage.open()
    .then( (waitForEmptyReturn) => storage.remove(values) )
    .then( (waitForEmptyReturn) => storage.add(values) )
    .then( (waitForEmptyReturn) => router.go('view', { 'viewName': values.dbKey},
        startingFrom: router.root.getRoute('dataview'), replace: true) );
  }

}
