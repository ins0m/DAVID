part of visualizer;

class DataviewStorage {

  String DATAVIEW_STORE = "dataviewDB";
  String USER_STORE = "userDB";
  int DATAVIEW_STORE_VERSION = 1;
  String DATAVIEW_STORE_MODE_RW = "readwrite";
  String DATAVIEW_STORE_MODE_R = "readonly";
  Database db;
  Serialization serializationRules;

  DataviewStorage({String databaseName}) {
    if (databaseName != null && databaseName.isNotEmpty == true){
      DATAVIEW_STORE = databaseName;
    }
    serializationRules = new Serialization()
      ..addDefaultRules()
      ..addRuleFor(new DataviewValues());
  }

  createRulesForMethod(MethodMirror methodMirror){
    serializationRules.addRuleFor(methodMirror);
  }

  Future open({userStore:false}) {
    Log.getInstance().info("Opening a database");
    return window.indexedDB.open( (userStore? USER_STORE : DATAVIEW_STORE),
    version: DATAVIEW_STORE_VERSION,
    onUpgradeNeeded: _initializeNewDatabase).then( (Database loadedDb) {
      Log.getInstance().info("Opened a database ${loadedDb.name}");
      db = loadedDb;
    });
  }

  void _initializeNewDatabase(VersionChangeEvent e) {
    Database toBe = (e.target as Request).result;
    var objectStore = toBe.createObjectStore(DATAVIEW_STORE,
    autoIncrement: true);
    db = toBe;
  }

  Future<DataviewValues> add(DataviewValues values) {
    Log.getInstance().info("Trying to save");
    Map output = serializationRules.write(values);
    var transaction = db.transaction(DATAVIEW_STORE, DATAVIEW_STORE_MODE_RW);
    var objectStore = transaction.objectStore(DATAVIEW_STORE);

    objectStore.add(output).then((addedKey) {
      values.dbKey = addedKey;
    });

    return transaction.completed.then((_) {
      return values.dbKey;
    });
  }

  Future<Database> clear() {
    var transaction = db.transaction(DATAVIEW_STORE, DATAVIEW_STORE_MODE_RW);
    transaction.objectStore(DATAVIEW_STORE).clear();
    return transaction.completed.then((_) {
      Log.getInstance().info("Cleared complete db");
    });
  }

  Future<List<DataviewValues>> loadDataViews() {
    Log.getInstance().info("Reading the dataview db");
    var trans = db.transaction(DATAVIEW_STORE, DATAVIEW_STORE_MODE_R);
    var store = trans.objectStore(DATAVIEW_STORE);
    List<DataviewValues> dataViews = new List();
    var cursors = store.openCursor(autoAdvance: true).asBroadcastStream();
    cursors.listen((cursor) {
      Log.getInstance().info("Got a dataview. ");
      var dataView = serializationRules.read(cursor.value);
      dataView.dbKey = cursor.key;
      dataViews.add(dataView);
    });

    return cursors.length.then((_) {
      Log.getInstance().info("Read the dataview db. Returning the data.");
      return dataViews;
    });
  }

  Future<List<DataviewValues>> loadUser() {
    if (db==null){
      return null;
    }
    Log.getInstance().info("Reading the dataview db");
    var trans = db.transaction(USER_STORE, DATAVIEW_STORE_MODE_R);
    var store = trans.objectStore(USER_STORE);
    List<DataCoder> dataCoder = new List();
    var cursors = store.openCursor(autoAdvance: true).asBroadcastStream();
    cursors.listen((cursor) {
      Log.getInstance().info("Got a dataview. ");
      var user = serializationRules.read(cursor.value);
      user.dbKey = cursor.key;
      dataCoder.add(user);
    });

    return cursors.length.then((_) {
      Log.getInstance().info("Read the dataview db. Returning the data.");
      return dataCoder;
    });
  }

  Future<DataviewValues> loadDataViewWithId(int _dbKey){
    Log.getInstance().info("Reading concrete dataview");
    var trans = db.transaction(DATAVIEW_STORE, DATAVIEW_STORE_MODE_R);
    var store = trans.objectStore(DATAVIEW_STORE);
    var dataView = null;
    var cursors = store.openCursor(autoAdvance: true).asBroadcastStream();
    cursors.listen((cursor) {
      if (_dbKey == cursor.key) {
        dataView = serializationRules.read(cursor.value);
        dataView.dbKey = cursor.key;
      }
    });
    return cursors.length.then((_) {
      return dataView;
    });
  }

  Future<DataviewValues> loadData(DataviewValues val){
    return loadDataViewWithId(val.dbKey);
  }

  Future<DataviewValues> removeDataViewWithId(int dbKey){
    Log.getInstance().info("Deleting concrete dataview");
    var trans = db.transaction(DATAVIEW_STORE, DATAVIEW_STORE_MODE_RW);
    var store = trans.objectStore(DATAVIEW_STORE);
    store.delete(dbKey);

    return trans.completed.then((_) {
      Log.getInstance().info("Deleted");
    });
  }

  Future<DataviewValues> remove(DataviewValues dataview){
    Log.getInstance().info("Deleting concrete dataview");
    var trans = db.transaction(DATAVIEW_STORE, DATAVIEW_STORE_MODE_RW);
    var store = trans.objectStore(DATAVIEW_STORE);
    store.delete(dataview.dbKey);

    return trans.completed.then((_) {
      Log.getInstance().info("Deleted");
      dataview.dbKey = null;
    });
  }

  Future createDatabaseFixtures(){
    var fix1 = new DataviewValues()
      ..dataDocuments.add(
        new DataDocument()
          ..addViewPoint(new HorizonChartValues()))
      ..dataDocuments.add(
        new DataDocument()
          ..addViewPoint(new LineChartValues()))
      ..description = "Specific data view 3"
      ..published = true;

    var fix2 = new DataviewValues()
      ..dataDocuments.add(
        new DataDocument()
          ..addViewPoint(new HorizonChartValues()))
      ..description = "Specific data view 2"
      ..published = true;

    return add(fix1)
    .then( (waitForReturn) => add(fix2) );
  }


}
