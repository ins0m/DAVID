part of visualizer;

class DataAnnotation {
  List<DataAnnotationItem> itemCollection = new List();
  DataDocument parent;

  /*
  Once added to a dataannotation this item will stay linked to this original. no matter where it is added.
  This allows having one single annotation in multiple logs and documents and remove it in sync from all of them
   */
  DataAnnotationItem addAnnotation(DataAnnotationItem item){
    Log.getInstance().info("${item.annotationName}");
    Log.getInstance().info("${item.parent}");
    if (item.parent==null){
      item.parent = this;
    }
    itemCollection.add(item);
    return item;
  }

  removeAnnotation(int time){
    int i;
    for(i=0; i< itemCollection.length;i++){
      if (itemCollection.elementAt(i).annotationTime == time){
        Log.getInstance().info("time delete :${itemCollection.elementAt(i).annotationTime}");
        itemCollection.removeAt(i);
        Log.getInstance().info("time deleteed :${itemCollection.elementAt(i).annotationTime}");
        i=0;
      }
    }
  }

  DataAnnotationItem getAnnotationItem(int time){
    int i;
    for(i=0; i< itemCollection.length;i++){
      if (itemCollection.elementAt(i).annotationTime == time){
        Log.getInstance().info("$i");
        Log.getInstance().info("time :${itemCollection.elementAt(i).annotationTime}");
        return itemCollection.elementAt(i);
      }
    }
    return null;
  }

  removeAnnotationItem(DataAnnotationItem item){
    int i;
    for(i=0; i< itemCollection.length;i++){
      if (itemCollection.elementAt(i) == item){
        Log.getInstance().info("time delete :${itemCollection.elementAt(i).annotationTime}");
        itemCollection.removeAt(i);
        i=0;
      }
    }
  }
}

class DataAnnotationItem{
  // TODO: create remove method so each item can kill itself!
  String annotationName;
  int annotationCode;
  int annotationTime;
  String annotationKey;
  // the overall type. this is needed. it defines the context of the codes such as "eye" or "lanechange" etc.
  // this library however abstracts away from that.
  String annotationType;
  // referes to the task the was annotated. A task normaly represents something that the annotated entity had
  // to do. I.e. a nback. This however is not needed. Sometimes we want to annotate interesting datapoints, where no task
  // is directly associated
  String annotationTask;
  // referes to the entity that was annotated. in genereal this will be a subject, but it may also be something else,
  // such as a steering wheel etc. if the database does allow for it
  int annotationTarget;
  String coder;
  String coderId;

  DataAnnotation parent;

  removeFromParent(){
    parent.removeAnnotationItem(this);
  }

  js.Proxy toJsProxy(){
    DataAnnotationItem item = clone();
    return new js.Proxy(js.context.Object)
      ..annotationTime = item.annotationTime
      ..annotationName = item.annotationName
      ..annotationCode = item.annotationCode
      ..annotationKey = item.annotationKey
      ..annotationType = item.annotationType
      ..annotationTask = item.annotationTask
      ..annotationTarget = item.annotationTarget
      ..coder = item.coder
      ..coderId = item.coderId
      ..parent = item.parent;
  }

  DataAnnotationItem clone(){
    DataAnnotationItem item = new DataAnnotationItem()
      ..annotationTime = this.annotationTime
      ..annotationCode = this.annotationCode
      ..annotationName = this.annotationName
      ..annotationKey = this.annotationKey
      ..annotationType = this.annotationType
      ..annotationTask = this.annotationTask
      ..annotationTarget = this.annotationTarget
      ..coder = this.coder
      ..coderId = this.coderId
      ..parent = this.parent;

    return item;
  }
}