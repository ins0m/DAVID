part of visualizer;

abstract class DataCoders {
  List<DataCoder> getValidCoders();

}

abstract class DataCoder {
  static DataCoder _instance;
  String name;
  String id;
  int dbKey;

  static bool setToCurrentCoder(instance){
    // this should be presisted!
    _instance = instance;
    return true;
  }

  static bool coderSet(){
    // first: try loading a user
    fetchUser();
    return (_instance!=null);
  }

  static DataCoder getCoder(){
    fetchUser();
    return _instance;
  }

  static resetCoder(){
    _instance = null;
  }

  bool isValid();

  static Future fetchUser(){
    if (_instance==null){
      DataviewStorage storage = new DataviewStorage();
      storage.open(userStore:true)
      .then( (waitForEmptyReturn) => storage.loadUser() )
      .then( (List<DataCoder> userList) {
        if (userList.length==1){
          _instance = userList.elementAt(0);
        }
      });
    }
  }

}