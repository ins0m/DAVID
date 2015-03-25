part of visualizer;

class DataviewsValues {
  List<DataviewValues> dataviewValues = new List<DataviewValues>();
  String description = "Index of all data views";
  List<DataviewSort> sortedValues = new List<DataviewSort>();
}

@NgController(
    selector: '[dataviews]',
    publishAs: 'ctrl',
    map: const {
     'values' : '<=>values'
    }
)
class DataviewsController {
  Http _http;
  DataviewsValues values = null;
  DataviewStorage storage;
  String lastSort = "";

  DataviewsController() {
    Log.getInstance().info("Loaded the dataviews");
    storage = new DataviewStorage();
    loadDataViewsFromDb();
  }


  loadDataViewsFromDb(){
    // FIXME: this is async and by this it will race against the document update
    // I have to implement a listener to this class or at least let this method block
    storage.open()
    .then( (waitForEmptyReturn) => storage.loadDataViews() )
    .then( (List dataViews) {
        values = new DataviewsValues()
          ..dataviewValues = dataViews;
        Log.getInstance().info("Read all dataviews into the controller (${dataViews.length})");
        sortBy('name');
     });
  }

  loadDataFixtures() {
    Log.getInstance().warning("Loading data fixtures");
    storage.open()
      .then( (waitForEmptyReturn) => storage.clear())
      .then( (waitForEmptyReturn) => storage.createDatabaseFixtures() )
    .then( (waitForEmptyReturn) => loadDataViewsFromDb())
      .then( (waitForEmptyReturn) => sortBy('name'));

  }

  resetData() {
    Log.getInstance().warning("Loading data fixtures");
    storage.open()
      .then( (waitForEmptyReturn) => storage.clear())
      .then( (waitForEmptyReturn) => loadDataViewsFromDb())
      .then( (waitForEmptyReturn) => sortBy('name'));
  }

  sortBy(String by){
    if (!by.isEmpty){
      lastSort = by;
    } else {
      by = lastSort;
    }
    Log.getInstance().info("sorting");
    Map<String,List<DataviewValues>> tempSort = new Map<String,List<DataviewValues>>();
    if (by == "description" || by == "name"){
      values.dataviewValues.forEach( (DataviewValues val){
        String letter;
        if (by == "name"){
          letter = val.name[0];
        } else {
          letter = val.description[0];
        }
        if (!tempSort.containsKey(letter.toUpperCase())){
          tempSort[letter.toUpperCase()] = new List<DataviewValues>();
        }
        tempSort[letter.toUpperCase()].add(val);
      });
    }
    values.sortedValues = new List<DataviewSort>();
    tempSort.forEach( (k, v){
      values.sortedValues.add(
          new DataviewSort()
          ..key = k
          ..val = v);
    });
    values.sortedValues.sort( (DataviewSort a,DataviewSort b) {
      if (a.key == b.key) {
        return 0;
      } else if (a.key.codeUnitAt(0) > b.key.codeUnitAt(0)) {
        return 1;
      } else {
        return -1;
      } });
  }

}

class DataviewSort{
  String key;
  List<DataviewValues> val = new DataviewValues();
}