part of visualizer;

/**
* Handles postgres data that is send via nodejs. This class might be very special to the way it retrieves data from nodejs
*/
class PostgresWebserviceSource{

  String username;
  String password;
  String baseUrl;

  PostgresWebserviceSource({this.baseUrl,this.username, this.password}){
  }

  Future<Object> request({String postgresQuery}){
    var url = baseUrl+":8080/sql/"+postgresQuery;
    return HttpRequest.getString(url).then(
        (resp){
          onDataLoaded("Loaded data: "+postgresQuery);
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