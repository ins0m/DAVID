part of visualizer;

/**
* Handles the retrival of json objects from a webservice
*/
class WebserviceSource{

  String username;
  String password;
  String baseUrl;

  WebserviceSource(this.baseUrl,{this.username,this.password}){
  }

  Future<Object> request(String query){
    var url = baseUrl+"/"+query;
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

  handleGenericError(e){
    Log.getInstance().error("webservice request failed");
  }
}