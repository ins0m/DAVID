part of visualizer;

class visualization_tags {

  static String TAG_GRAPH = "#graph";

  static getGraphTag(int identifier){
    return TAG_GRAPH+"_"+identifier;
  }
}
