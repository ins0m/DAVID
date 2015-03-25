part of visualizer;

/*
  This class holds logic that all viewPoints share that are observable, such as the logic of the play (ticking) and the generation
  of the overlays. It is also responsible for setting up the connection between different visualizations. It triggers events based on the behaviour of the user. This
  includes hnadling the annotations. Showing the current annotation is a task which the special annotation/table component does
 */
class ViewPointController extends ViewPointObservable {



  ViewPointValues values;
  var myCssMirror;
  var myJavascriptMirror;
  DateTime startTime = new DateTime.now();
  Timer timer;
  Stopwatch watch;
  int _lastTimeTick =0;
  int _lastTimeOffset = 0;
  var _annotationsSelected = false;
  var _presentationMode = false;
  var _justInit = true;



  setValues(ViewPointValues values) {
    this.values = values;
    Log.getInstance().info("Created values for domID: ${values.domID}");
  }

  addObserverById(String remoteDomId) {
    Log.getInstance().warning("adding a new observer: "+remoteDomId);
    values.dataSource.parentController.values.dataDocuments.forEach( (dd) {
      dd.viewPoints.forEach( (vp) {
        if (vp.domID == remoteDomId) {
          Log.getInstance().warning("Added dart observer: "+vp.domID);
          values.observer.add(new ViewPointConnector()
          ..connectionType = new ViewPointConnector().CONNECTION_ABSOLUTE
          ..src = this
          ..dst = vp.observableController
          ..connectionName = this.values.domID+"->"+vp.domID);
        }
      });
    });
  }

  addObserver(ViewPointController observable) {
    values.observer.add(new ViewPointConnector()
      ..connectionType = new ViewPointConnector().CONNECTION_ABSOLUTE
      ..src = this
      ..dst = observable
      ..connectionName = this.values.domID+"->"+observable.values.domID);
  }

  removeObserverById(String remoteSourceDomId, String remoteTargetDomId) {
    Log.getInstance().warning("removing a new observer: "+remoteTargetDomId);
    values.dataSource.parentController.values.dataDocuments.forEach( (dd) {
      dd.viewPoints.forEach( (vp) {
        if (vp.domID == remoteTargetDomId) {
          Log.getInstance().warning("Removed dart observer: "+vp.domID);
          List<ViewPointConnector> toRemove = new List();
          values.observer.forEach( (ViewPointConnector vpc){

            Log.getInstance().warning("Src: ${vpc.src.values.domID}, dst: ${vpc.dst.values.domID} , caller ${vp.domID}");
            if (vpc.dst == vp.observableController){
              toRemove.add(vpc);
            }
          });
          Log.getInstance().warning("To remove $toRemove: ");
          toRemove.forEach( (ViewPointConnector vpc){
              values.observer.remove(vpc);
          });

        }
        // this is a failover for a strange behaviour in the returntypes if jsplumbs detach method. sometimes we need it, but not allways
        //if (vp.domID == remoteSourceDomId) {
        //  Log.getInstance().warning("Remove was called oin the wrong element. Prpagating remove dart observer: "+vp.domID);
        //  vp.observableController.removeObserver(this);
        //}
      });
    });
  }

  removeObserver(ViewPointController observable) {
    List<ViewPointConnector> toRemove = new List();
    values.observer.forEach( (ViewPointConnector vpc){
      if (vpc.dst == observable){
        toRemove.add(vpc);
      }
    });
    toRemove.forEach( (ViewPointConnector vpc){
        values.observer.remove(vpc);
    });
  }

/**
  * Propagates a receiveTick() call to all known observers
*/
  propagateTick(int tickEvent, {int absoluteValue:0, int relativeValue:0, dataValue:0}){
    values.observer.forEach( (ViewPointConnector vpc){
      var linkValue = null;
      if (vpc.connectionType == new ViewPointConnector().CONNECTION_VALUE){
        linkValue = values.chart.getDataPoint(values.currentTime);
      } else if (dataValue==null) {
        Log.getInstance().info("else if (dataValue==null) has a reason");

      }

      // we propagate all values. Each observer can define for himself how to handle the data dependent on its state
      vpc.dst.receiveTick(vpc, tickEvent,
      absoluteValue:values.currentTime,
      relativeValue:values.currentTime-values.timeOffset,
      linkValue:linkValue,
      dataValue:dataValue);
    });
  }

/**
  * Called whenever an observed chart propagates a tick. The tick propagates an event and corresponding values
  * TODO: datavalue is not used or sent yet.
*/
  receiveTick(ViewPointConnector vpc, int tickEvent, {int absoluteValue:0, int relativeValue:0, linkValue:0, dataValue:0}){
    // now make sure to propagate the tick to the component implementation
    Log.getInstance().info("chart ${values.domID} got a tick after $relativeValue with absolute dif $absoluteValue");
    handleTickConnection(vpc, tickEvent, absoluteValue:absoluteValue, relativeValue:relativeValue,linkValue:linkValue, dataValue:dataValue);
    propagateTick(tickEvent,absoluteValue:absoluteValue,relativeValue:relativeValue, dataValue:dataValue);

  }

  // FIXME: For now this is fine, but when a tick has a different meaning than to set the time (mouseover, zoom etc.)
  // we need to use the tickActionHandler
  handleTickConnection(ViewPointConnector vpc ,int tickEvent, {int absoluteValue:0, int relativeValue:0, linkValue:0, dataValue:0}){

    // when we set time we want to make sure we have a) a working connection b) the event is supposed to set the time. Annotation or data propagation is not ment to do that just by value
    if (vpc != null && [ViewPointEvents.PAUSE_EVENT, ViewPointEvents.RESUME_EVENT, ViewPointEvents.TICK_TIME_EVENT, ViewPointEvents.TICK_TIME_MANUAL_EVENT].contains(tickEvent)){
     if (vpc.connectionType == new ViewPointConnector().CONNECTION_ABSOLUTE){
          // jump to the same absolute time as the observed counter
          Log.getInstance().info('received absolute val: $absoluteValue');
          values.currentTime = absoluteValue;
     } else if (vpc.connectionType == new ViewPointConnector().CONNECTION_RELATIVE) {
          // add only the offset of the absolute time of the observed counter
          Log.getInstance().info('received relative val: $relativeValue');
          values.currentTime = values.timeOffset + relativeValue;
     } else if (vpc.connectionType == new ViewPointConnector().CONNECTION_VALUE) {
       // now get to the real deal. find the time for the current datapoint
       // this gets the time. we assume that the datapoint is the exact same object that the metric funtion produces
       values.currentTime = values.chart.getTimePoint(linkValue);
       absoluteValue = values.currentTime;
       relativeValue = values.currentTime - values.timeOffset;
     }
    } else if (vpc == null) {
      values.currentTime = absoluteValue;
    }
    handleTickAction(vpc, tickEvent, decidedTime:values.currentTime, dataValue: dataValue);
  }

  handleTickAction(ViewPointConnector vpc ,int tickEvent, {int decidedTime:0, dataValue:0}){
    switch (tickEvent) {
      case ViewPointEvents.TICK_TIME_EVENT:
      case ViewPointEvents.TICK_TIME_MANUAL_EVENT:
      case ViewPointEvents.PAUSE_EVENT:
      case ViewPointEvents.RESUME_EVENT:
        values.chart.tick(tickEvent, decidedTime,
        new js.Proxy(js.context.Object)
          ..tickSpeed = values.tickSpeed
          ..timeOffset = values.timeOffset);
        break;
      case ViewPointEvents.ANNOTATION_ADD_EVENT:
      case ViewPointEvents.ANNOTATION_DELETE_EVENT:
        values.chart.tick(tickEvent, decidedTime, dataValue.toJsProxy());
        break;
      case ViewPointEvents.OVERLAY_EVENT:
        toggleOverlay(dataValue);
        break;
      case ViewPointEvents.PRESENTATION_EVENT:
        values.chart.togglePresentation(dataValue);
        break;
    }
  }


  // This method creates timebased ticks
  startTimeTicker(){
    if (watch == null || !watch.isRunning || !timer.isActive){
      watch = new Stopwatch()
        ..start();
      if (_justInit || _lastTimeOffset != values.timeOffset) {
        _justInit=false;
        _lastTimeOffset = values.timeOffset;
        values.currentTime = values.timeOffset;
      }
      values.chart.tick(ViewPointEvents.RESUME_EVENT, null,null);
      timer = new Timer.periodic(new Duration(milliseconds:values.tickInterval), (Timer timer) => masterTick(
          ViewPointEvents.TICK_TIME_EVENT
      ));
    }
  }

  stopTimeTicker(){

    if (timer!=null){
      timer.cancel();
    }
    if (watch!=null){
      watch.stop();
      watch.reset();
    }
    _lastTimeTick = 0;
    masterTick(ViewPointEvents.PAUSE_EVENT);
    // yes, this is needed two times, since the default behaviour will reasign it once receiving the event in the mastertick
    // dependent graphs are not concerned by this since they dont really "run" but only listen to the events
    _lastTimeTick = 0;
  }

  pauseTimeTicker(){

    if (timer!=null){
      timer.cancel();
    }
    if (watch!=null){
      watch.stop();
      watch.reset();
    }
    _lastTimeTick = 0;
    masterTick(ViewPointEvents.PAUSE_EVENT);
    // yes, this is need two times, since the default behaviour will reasign it once receiving the event in the mastertick
    // dependent graphs are not concerned by this since they dont really "run" but only listen to the events
    _lastTimeTick = 0;
  }



  addAnnotation(DataAnnotationItem item){
    // inly here it will get added. not on the event basis
    item = item.clone();
    item.annotationTime = values.currentTime;
    item.coder = DataCoder.getCoder().name;
    item.coderId = DataCoder.getCoder().id;
    executeAddAnnotation(item);
    values.dataSource.viewPoints.forEach( (ViewPointValues vpv){
      Log.getInstance().warning("Propagation to same parent");
      // make sure we do not call ourself
      if(vpv != values && !(vpv.observableController is AnnotationLogController)){
        Log.getInstance().warning("Calling annotation on neighbour");
        // order is important. first remove, then notify
        vpv.observableController.receiveTick(null,ViewPointEvents.ANNOTATION_ADD_EVENT, dataValue:item);
      }
    });
    masterTick(ViewPointEvents.ANNOTATION_ADD_EVENT, dataValue:item);
    Log.getInstance().info("Propagated annotation ${item.annotationName}");
  }

  removeAnnotation(int time){
    // inly here it will get added. not on the event basis
    executeDeleteAnnotation(time);
    values.dataSource.viewPoints.forEach( (ViewPointValues vpv){
      if(vpv != values){
        vpv.observableController.receiveTick(null,ViewPointEvents.ANNOTATION_DELETE_EVENT, dataValue:time);
      }
    });
    masterTick(ViewPointEvents.ANNOTATION_DELETE_EVENT);
  }
  executeAddAnnotation(DataAnnotationItem item){
    values.dataSource.annotations.addAnnotation(item);
    Log.getInstance().warning("Added a annotation");
  }
  executeDeleteAnnotation(time){
    values.dataSource.annotations.removeAnnotation(time);
    Log.getInstance().warning("Deleted a annotation");
  }

  fastBackward(){
    if (values.tickSpeed>=0){
      values.tickSpeed=-1;
    }
    values.tickSpeed -= 1;
    startTimeTicker();
  }

  fastForward(){
    if (values.tickSpeed<=0){
      values.tickSpeed=1;
    }
    values.tickSpeed +=1;
    startTimeTicker();
  }

  manualTickBackward(){
    stopTimeTicker();
    values.tickSpeed = 1;
    if (_justInit || _lastTimeOffset != values.timeOffset) {
      _justInit=false;
      _lastTimeOffset = values.timeOffset;
      values.currentTime = values.timeOffset;
    }
    masterTick(ViewPointEvents.TICK_TIME_MANUAL_EVENT, elapsedTime:-250);
  }

  manualTickForward(){
    stopTimeTicker();
    values.tickSpeed = 1;
    if (_justInit || _lastTimeOffset != values.timeOffset) {
      _justInit=false;
      _lastTimeOffset = values.timeOffset;
      values.currentTime = values.timeOffset;
    }
    masterTick(ViewPointEvents.TICK_TIME_MANUAL_EVENT, elapsedTime:250);
  }


  masterTick(int tickEvent, {dataValue:null, int elapsedTime}){
    int timerValue = 0;
    if (watch != null && watch.elapsedMilliseconds != null  && watch.elapsedMilliseconds != 0){
      timerValue = watch.elapsedMilliseconds;
    } else if (elapsedTime != null){
      timerValue = elapsedTime;
    } else {
      timerValue = 0;
    }

    int pointInTime = values.currentTime + ((timerValue - _lastTimeTick)*values.tickSpeed);
    Log.getInstance().info("pointInTime: $pointInTime");
    Log.getInstance().info("offset: ${values.timeOffset}");
    _lastTimeTick = timerValue;
    Log.getInstance().info("ct: ${values.currentTime},ltt: $_lastTimeTick,ti: $timerValue, et: $elapsedTime, wes: ${watch != null ? watch.elapsedMilliseconds : "null"}");
    Log.getInstance().info("absolute: $pointInTime, relative: ${(pointInTime-values.timeOffset)}");

    if (dataValue==null) {
      switch (tickEvent){
        case ViewPointEvents.TICK_TIME_MANUAL_EVENT:
        case ViewPointEvents.TICK_TIME_EVENT:
        case ViewPointEvents.RESUME_EVENT:
        case ViewPointEvents.PAUSE_EVENT:
          dataValue =
          {
            'tickSpeed' : values.tickSpeed,
            'timeOffset' : values.timeOffset
          };
          break;

      }
    }
    switch (tickEvent){
      case ViewPointEvents.ANNOTATION_ADD_EVENT:
        Log.getInstance().info("dataValue time:${dataValue.annotationTime}");
        var cache  = dataValue.clone();
        dataValue = cache;
        Log.getInstance().info("new dataValue time:${dataValue.annotationTime}");
        break;
    }

    receiveTick(null,
      tickEvent,
      absoluteValue:pointInTime,
      relativeValue:pointInTime-values.timeOffset,
      dataValue:dataValue);
    // first handle yourself
  }

  editCss(){
    Log.getInstance().info("got the click");
    var codeContainer = values.shadowRoot.querySelector('#css-area');
    Log.getInstance().info(codeContainer.text);

    if (myCssMirror ==null){
      var jsFunc = js.context.CodeMirror;
      myCssMirror = jsFunc(codeContainer, new js.Proxy(js.context.Object)
        ..value = values.savedCss
        ..theme = 'monokai'
        ..mode = 'css'
        ..tabSize = 1
        ..lineNumbers = false);
    }
    values.chart.toggleCssArea();
    myCssMirror.refresh();
  }

  editJs(){
    Log.getInstance().info("got the click");
    var codeContainer = values.shadowRoot.querySelector('#javascript-area');
    Log.getInstance().info(codeContainer.text);

    if (myJavascriptMirror ==null){
      var jsFunc = js.context.CodeMirror;
      myJavascriptMirror = jsFunc(codeContainer, new js.Proxy(js.context.Object)
        ..value = values.chart.modifiedSource.toString()
        ..theme = 'monokai'
        ..mode = 'javascript'
        ..tabSize = 1
        ..lineNumbers = false);
    }
    values.chart.toggleJsArea();
    myJavascriptMirror.refresh();
  }

  editReverseJs(){
    Log.getInstance().info("got the click");
    var codeContainer = values.shadowRoot.querySelector('#javascript-reverse-area');
    Log.getInstance().info(codeContainer.text);

    if (myJavascriptMirror ==null){
      var jsFunc = js.context.CodeMirror;
      myJavascriptMirror = jsFunc(codeContainer, new js.Proxy(js.context.Object)
        ..value = values.chart.modifiedSource.toString()
        ..theme = 'monokai'
        ..mode = 'javascript'
        ..tabSize = 1
        ..lineNumbers = false);
    }
    values.chart.toggleJsArea();
    myJavascriptMirror.refresh();
  }

  applyCss({String styleData}) {
    var styleContainer = values.shadowRoot.querySelector('#stylesheet-area');
    final NodeValidatorBuilder _htmlValidator=new NodeValidatorBuilder.common()
      ..allowElement('style');
    if (styleData!=null && !styleData.isEmpty){
      styleContainer.setInnerHtml("<style> $styleData </style>", validator:_htmlValidator);
    } else {
      styleContainer.setInnerHtml("<style> ${myCssMirror.getValue()} </style>", validator:_htmlValidator);
      values.savedCss = myCssMirror.getValue();
    }
  }

  applyJs() {
    // read the content of the editor and use it to redefine the functions
    // The function we get will just be exeuted and has to make sure that the hook methods are overwritten
    values.chart.reConfigure(myJavascriptMirror.getValue());
    values.savedJs = myJavascriptMirror.getValue();
    // lets use our chart object and coll the render method to reuse the applied js
    values.chart.render();
  }

  String _readCodeMirrorContent(Element e){
    String result ="";
    e.cwldren.forEach( (Element e){
      result = "$result\n${e.text}";
    });
    return result;
  }

  setUpEndpoint(){
    values.chart.setUpEndpoint(
        addObserverById,
        removeObserverById
    );
  }

  markAllDataDocumentNeighbours(){
    values.dataSource.markViewPoints();
  }

  markForDataDocument(String color){
    var infoContainer = values.shadowRoot.querySelector('#neighbour-icon');
    infoContainer.setAttribute("style","background:$color");
  }

  toggleDraggable(){
    values.chart.toggleDraggable();
  }


  toggleOverlayMenu(){
    values.chart.toggleOverlayMenu();
  }


  toggleOverlayArea(){
    values.chart.toggleOverlayArea();
  }


  toggleOverlay(name){
    values.chart.overlayLibrary.toggleOverlay(name);
    propagateTick(ViewPointEvents.OVERLAY_EVENT);
  }

  toggleConnectionMenu(){
    values.chart.toggleConnectionMenu();
  }

  toggleZoom(){
    values.chart.toggleZoom();
  }

  toggleAnnotationMenu(){
    values.chart.toggleAnnotationMenu();
  }

  togglePlaySettingsMenu(){
    values.chart.togglePlaySettingsMenu();
  }

  toggleBackground(){
    values.chart.toggleBackground();
  }

  togglePresentation(){
    _presentationMode = !_presentationMode;
    masterTick(ViewPointEvents.PRESENTATION_EVENT, dataValue: _presentationMode);
  }

  toggleContainer(){
    values.chart.toggleContainer();
  }

  toggleAnnotationBinding(){
    _annotationsSelected = !_annotationsSelected;
    values.dataSource.annotationCodes.selectedCodes.forEach((DataAnnotationItem item){
      if (_annotationsSelected == true) {
        var jsFunc = js.context.Mousetrap.bind;
        myJavascriptMirror = jsFunc( item.annotationKey, (event, key) => addAnnotation(item) );
        values.shadowRoot.querySelector('#annotation-binding').className =
          "${values.shadowRoot.querySelector('#annotation-binding').className} active";

      } else {
        var jsFunc = js.context.Mousetrap.unbind;
        // or .reset for all registered keys
        myJavascriptMirror = jsFunc(item.annotationKey);
        values.shadowRoot.querySelector('#annotation-binding').className =
          values.shadowRoot.querySelector('#annotation-binding').className.replaceAll("active","");
      }
    });
  }

  setCurrentTime(absoluteTime){
    values.currentTime = absoluteTime;
  }

  setUpViewPoint(ShadowRoot root){
    values.shadowRoot = root;
    values.chart.setShadowRoot(root);
    Log.getInstance().success("Values are: "+values.description);
    Log.getInstance().info("now settig the data for a plot");
    values.chart.setContainer(values.domID);
    RepositoryResult repoResult= this.values.dataSource.createRepositoryResult();

    // be carefull here. We dont want to add the default methods but the saved library functions
    values.chart.dataMetric = values.dataMetric;
    values.chart.dataManipulator = values.dataManipulator;
    values.chart.reverseDataMetric = values.reverseDataMetric;
    values.chart.annotationDeleteCallback = removeAnnotation;
    values.chart.overlayLibrary.loadOverlays(reloadOverlays);
    js.Proxy overlayNamesProxy = values.chart.overlayLibrary.overlayNames;
    for (var i = 0; i < overlayNamesProxy.length ; i++) {
      values.overlayNames.add(overlayNamesProxy[i].name);
    }


    Log.getInstance().success("My overlays are: ${values.overlayNames}");

    values.dataSource.annotationCodes = repoResult.annotationCodes;

    Log.getInstance().success("My metric is: ${values.chart.dataMetric}");
    Log.getInstance().success("My reverse metric is: ${values.chart.reverseDataMetric}");
    Log.getInstance().success("My manipulator is: ${values.chart.dataManipulator}");

    values.chart.init();
    values.chart.initUi();
    querySelector('#view-name').text = values.dataSource.parentController.values.name;

    // load the saved scripts and values
    if (values.savedJs!= null && !values.savedJs.isEmpty){
      values.chart.reConfigure(values.savedJs);
    }

    if (values.savedCss!= null && !values.savedCss.isEmpty){
      applyCss(styleData:values.savedCss);
    }

    // the function that gets applied to the received data
    if (values.dataSource.fetched==false){
      repoResult.dataFutureFunction().then( (theData){
        executeDataSetter();
        values.chart.setTimeCallback(setCurrentTime);
      });
    } else {
      executeDataSetter();
      values.chart.setTimeCallback(setCurrentTime);
    }

  }

  executeDataSetter(){
    values.chart.setData(this.values.dataSource.data);
    var foundOffset =values.chart.currentTimeCache;
    if (foundOffset!=null){
      values.currentTime = foundOffset;
      values.timeOffset = foundOffset;
    } else {
      // take the parameter offest
      foundOffset = values.dataSource.methodParams[new Symbol("startTime")];
      if (foundOffset!=null){
        values.currentTime = foundOffset;
        values.timeOffset = foundOffset;
      } else {
        // fallback to zero
        values.currentTime = 0;
        values.timeOffset = 0;
      }
    }
    // now make sure we apply the correct metrics
    values.chart.render();
  }

  reloadOverlays(){
    values.overlayNames = new List();
    js.Proxy overlayNamesProxy = values.chart.overlayLibrary.overlayNames;
    for (var i = 0; i < overlayNamesProxy.length ; i++) {
      values.overlayNames.add(overlayNamesProxy[i].name);
    }
  }


}
