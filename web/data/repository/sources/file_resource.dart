part of visualizer;

/**
 * Handles postgres data that is send via nodejs. This class might be very special to the way it retrieves data from nodejs
 */
class FileResource{

  String username;
  String password;
  String baseUrl;

  FileResource({this.baseUrl,this.username, this.password}){
  }


  Future<Object> request({String query}){
    var url = baseUrl+":8080/file/"+query;
    return HttpRequest.getString(url).then(
            (resp){
          onDataLoaded("Loaded data: "+query);
          return resp;
        }
    ).catchError(
            (e) => handleGenericError(e),test: true
    );
  }

  onDataLoaded(String response){
    Log.getInstance().success(response);
  }

  /**
   * Gets always called for all errors
   */
  handleGenericError(e){
    Log.getInstance().error("postgres request failed with error: "+(e as Error).stackTrace);
  }

}