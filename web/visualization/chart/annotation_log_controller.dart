part of visualizer;

class AnnotationLogController extends ViewPointController {

  DataAnnotation annotations = new DataAnnotation();

  exportToCSV(){
    String csv="time,name,code";
    annotations.itemCollection.forEach( (value){
      csv = "$csv\n${value.annotationTime},${value.annotationName},${value.annotationCode}";
    });
    var theWindow = window.open("","CSV");
    var paragraph = new PreElement();
    paragraph.appendHtml("<code>$csv</code>");
    theWindow.document.body.append(paragraph);
  }

  handleTickAction(ViewPointConnector vpc ,int tickEvent, {int decidedTime:0, dataValue:0}){
    switch (tickEvent) {
      case ViewPointEvents.TICK_TIME_EVENT:
      case ViewPointEvents.TICK_TIME_MANUAL_EVENT:
        values.chart.tick(tickEvent, decidedTime, dataValue);
        break;
      case ViewPointEvents.ANNOTATION_ADD_EVENT:
        var proxy =  new js.Proxy(js.context.Object)
          ..annotation = dataValue.toJsProxy()
          ..callback = removeAnnotation;
        values.chart.tick(tickEvent, decidedTime, proxy);
        addAnnotation(dataValue);
        break;
      case ViewPointEvents.ANNOTATION_DELETE_EVENT:
        values.chart.tick(tickEvent, decidedTime, dataValue);
        removeAnnotation(dataValue);
        break;
    }
  }

  addAnnotation(DataAnnotationItem item){
    executeAddAnnotation(item);

    annotations.itemCollection.forEach( (value){
      Log.getInstance().info("In annotation ${value.annotationTime}");
    });
  }

  // unique overwriting for this specific class. Onyl the annotation log starts to create its own dataset of annotations
  removeAnnotation(int time){
    executeDeleteAnnotation(time);
    Log.getInstance().info("deleted - how much is left ?");
    annotations.itemCollection.forEach( (value){
      Log.getInstance().info("In annotation ${value.annotationTime}");
    });
  }

  executeAddAnnotation(DataAnnotationItem item){
    annotations.addAnnotation(item);
  }

  executeDeleteAnnotation(time){
    DataAnnotationItem item = annotations.getAnnotationItem(time);
    Log.getInstance().info("executeDelete is called again with $item");
    if (item != null){
      item.removeFromParent();
      annotations.removeAnnotationItem(item);
      item.parent.parent.viewPoints.forEach( (ViewPointValues vpv){
        if(vpv != values){
          vpv.observableController.receiveTick(null,ViewPointEvents.ANNOTATION_DELETE_EVENT, dataValue:time);
        }
      });;
    }

  }
}
