part of visualizer;

@NgController(
    selector: '[dataview-edit]',
    publishAs: 'ctrl'
)
class DataviewEditController {


  List<ViewPointValues> knownViewPoints = new List<ViewPointValues>();
  List<Repository> knownRepositories = new List<Repository>();
  Repository currentRepository;
  List<MethodMirror> currenDataCalls = new List<MethodMirror>();
  MethodMirror currentDataCall;

  List<ViewPointValues> selectedViewPoints = new List<ViewPointValues>();
  DataviewValues valueObject;


  DataviewEditController(RouteProvider routeProvider) {
    Log.getInstance().info("Loaded the dataview controller ${routeProvider.routeName}}");

    int _dbKey = int.parse(routeProvider.parameters['viewName']);

    DataviewStorage storage = new DataviewStorage();
    storage.open()
    .then( (waitForEmptyReturn) => storage.loadDataViewWithId(_dbKey))
    .then( (dataviewValues) {
      valueObject = dataviewValues;
      valueObject.dataDocuments.forEach( (DataDocument ddOfVo){
        Log.getInstance().info("Adding: ${ddOfVo.dataRepository.name}");
        addRepository(ddOfVo.dataRepository);
      });
      addRepository(new AgeLabOnrdRepositoryMock());
      addRepository(new AgeLabSimRepositoryMock());
    });


    Log.getInstance().info("In the DataviewEditController view");
    knownViewPoints.add(new LineChartValues());
    knownViewPoints.add(new HorizonChartValues());
    knownViewPoints.add(new TableViewValues());
    knownViewPoints.add(new VideoViewValues());
    knownViewPoints.add(new AnnotationLogValues());
    knownViewPoints.add(new BarChartValues());
    knownViewPoints.add(new MapViewValues());
    knownViewPoints.add(new PieChartValues());
    knownViewPoints.add(new GenericViewValues());
    knownViewPoints.add(new SpeedViewValues());
    knownViewPoints.add(new SteeringWheelValues());
    knownViewPoints.add(new ConnectorValues());
  }

  addRepository(Repository repo){
    bool add = true;
    knownRepositories.forEach((repoInList){
      if (repoInList.name == repo.name){
        Log.getInstance().info("Equals: ${repo.name} ${repoInList.name}");
        add=false;
      }
    });
    if (add==true){
      Log.getInstance().info("Added: ${repo.name}");
      knownRepositories.add(repo);
    }
  }


  selectRepository(Repository selectedRepo){
    Log.getInstance().info("current repo: ${selectedRepo.name}");
    currentRepository = selectedRepo;
    selectedViewPoints.forEach( (ViewPointValues vpv){
      Log.getInstance().info("Toggling vpv to true");
      destroyCodeContainer(vpv);
    });
    selectedViewPoints = new List<ViewPointValues>();
    currentDataCall = null;
    getRepositoryDataCalls();
  }

  getRepositoryDataCalls(){
    InstanceMirror instance = reflect(currentRepository);
    // may currentRepository.runtimeType work as well ?
    ClassMirror cm = instance.type;
    Iterable<DeclarationMirror> decls = cm.declarations.values.where(
            (dm) => dm is MethodMirror && dm.isRegularMethod);
    currenDataCalls = new List<MethodMirror>();
    decls.forEach((MethodMirror mm) {
      currenDataCalls.add(mm);
      Log.getInstance().info("current dataCalls: ${MirrorSystem.getName(mm.simpleName)}");
    });
  }

  /**
  * called when a method is selected in the userinterface. now we have to make sure
  * that the content of all the interesting fields is set. this could be done by
  * angular if it were able to use internal classes. but its not. thats why we set them here
  * and let angular take car of the rendering.
*/
  prepareMethod(MethodMirror mm){
    selectedViewPoints.forEach( (ViewPointValues vpv){
      destroyCodeContainer(vpv);
    });
    selectedViewPoints = new List<ViewPointValues>();
    Log.getInstance().info("got the click");
    currentDataCall = mm;
  }

  prepareMetric(ViewPointValues selectedViewpoint){
    var metrics = getMetricLibraryForVp(selectedViewpoint);
    if (metrics != null){
      String dme = metrics.dataMetric;
      Log.getInstance().info("Data metric: $dme");
      createCodeContainer(selectedViewpoint, "metric", dme);
    }
  }

  prepareReverseMetric(ViewPointValues selectedViewpoint){
    var metrics = getMetricLibraryForVp(selectedViewpoint);
    if (metrics != null){
      String rdme = metrics.reverseDataMetric;
      Log.getInstance().info("Data metric: $rdme");
      createCodeContainer(selectedViewpoint, "reversemetric", rdme);
    }
  }

  prepareManipulator(ViewPointValues selectedViewpoint){
    var metrics = getMetricLibraryForVp(selectedViewpoint);
    if (metrics != null){
      String dma = metrics.dataManipulator;
      Log.getInstance().info("Data manipulator: $dma");
      createCodeContainer(selectedViewpoint, "manipulator", dma);
    }
  }

  createCodeContainer(ViewPointValues selectedViewpoint, String codeType, String code) {
    Log.getInstance().info("Preparing $codeType for #$codeType-area-${selectedViewpoint.name.replaceAll(' ','-')}");
    String oldCode = _readCodeMirrorContent(querySelector("#$codeType-area-${selectedViewpoint.name.replaceAll(' ', '-')} .CodeMirror-code"));
    if (!oldCode.isEmpty){
      Log.getInstance().info("already has code");
      return;
    }
    var codeContainer = querySelector("#$codeType-area-${selectedViewpoint.name.replaceAll(' ', '-')}");
    if (codeContainer!=null){
      codeContainer.children.clear();
    }
    var manipulatorMirror = js.context.CodeMirror;
    var theEditor = manipulatorMirror(codeContainer, new js.Proxy(js.context.Object)
      ..value = code
      ..theme = 'monokai'
      ..mode = 'javascript'
      ..lineNumbers = false);

    const dur = const Duration(milliseconds:700);
    new Timer(dur, () => theEditor.refresh());
  }

  destroyCodeContainer(ViewPointValues selectedViewpoint) {
    var codeContainer1 = querySelector("#manipulator-area-${selectedViewpoint.name.replaceAll(' ', '-')}");
    var codeContainer2 = querySelector("#metric-area-${selectedViewpoint.name.replaceAll(' ', '-')}");
    var codeContainer3 = querySelector("#reversemetric-area-${selectedViewpoint.name.replaceAll(' ', '-')}");
    if (codeContainer1 !=null && codeContainer2!=null && codeContainer3!=null){
      codeContainer1.children.clear();
      codeContainer2.children.clear();
      codeContainer3.children.clear();
    }
  }

  MetricLibrary getMetricLibraryForVp(ViewPointValues selectedViewpoint) {
    InstanceMirror cm = reflect(currentRepository);
    InstanceMirror instanceResult = cm.invoke(new Symbol(MirrorSystem.getName(currentDataCall.simpleName)), []);
    RepositoryResult repoResult = instanceResult.reflectee;
    MetricLibrary metrics = repoResult.getMetric(selectedViewpoint);
    return metrics;
  }


  /**
  * Gets called whenever the save button is hit
  */
  addDataDocument() {
    Log.getInstance().info("Adding DataDocument");
    DataDocument dd = new DataDocument();

    selectedViewPoints.forEach( (ViewPointValues vp) {
      // lets create a completely new vpv, otherwise they are mixed up between different dd's
      InstanceMirror instance = reflect(vp);
      ClassMirror cm = instance.type;

      Log.getInstance().info("Looking at ${vp.name}");
      Iterable<DeclarationMirror> decls =
      cm.declarations.values.where(
              (dm) => dm is MethodMirror && dm.isConstructor);

      // there should be only one root constructor. The super constructor will get called automatically
      InstanceMirror newInstance = cm.newInstance(new Symbol(''),[]);
      ViewPointValues theVp= newInstance.reflectee;

      theVp.dataMetric=_readCodeMirrorContent(querySelector('#metric-area-${vp.name.replaceAll(' ','-')} .CodeMirror-code'));
      theVp.dataManipulator=_readCodeMirrorContent(querySelector('#manipulator-area-${vp.name.replaceAll(' ','-')} .CodeMirror-code'));;
      theVp.reverseDataMetric=_readCodeMirrorContent(querySelector('#reversemetric-area-${vp.name.replaceAll(' ','-')} .CodeMirror-code'));



      if (theVp.dataMetric == null || theVp.dataMetric.trim().isEmpty){
        var concreteMetric = getMetricLibraryForVp(theVp);
        if (concreteMetric != null){
          theVp.dataMetric = concreteMetric.dataMetric;
        }
      }
      if (theVp.dataManipulator == null || theVp.dataManipulator.trim().isEmpty){
        var concreteMetric = getMetricLibraryForVp(theVp);
        if (concreteMetric != null){
          theVp.dataManipulator = concreteMetric.dataManipulator;
        }
      }
      if (theVp.reverseDataMetric == null || theVp.reverseDataMetric.trim().isEmpty){
        var concreteMetric = getMetricLibraryForVp(theVp);
        if (concreteMetric != null){
          theVp.reverseDataMetric = concreteMetric.reverseDataMetric;
        }
      }

      Log.getInstance().info("inserting metric ${theVp.dataMetric}");
      Log.getInstance().info("inserting metric ${theVp.dataManipulator}");
      dd.addViewPoint(
        theVp
      );
      Log.getInstance().info("With vp ${vp.name} and instance: ${newInstance.reflectee.name}");
    });

    Map<Symbol, dynamic> params = new Map<Symbol,dynamic>();
    List<Element> parametersEntrys = querySelectorAll('.params');
    parametersEntrys..forEach( (Element e){
      if (e is InputElement){
       InputElement ie = e as InputElement;
       Log.getInstance().info("${ie.type}");
       if (ie.value != null && !ie.value.isEmpty){
         params[new Symbol("${ie.id.split("\"")[1]}")] = ie.value;}
      }
    });

    Log.getInstance().info("$params");

    dd
      ..dataCall = MirrorSystem.getName(currentDataCall.simpleName)
      ..methodParams = params
      ..setRepository(currentRepository);

    valueObject.dataDocuments.add(
      dd
    );
    selectedViewPoints.forEach( (ViewPointValues vpv){
      Log.getInstance().info("Toggling vpv to true");
      destroyCodeContainer(vpv);
    });
    selectedViewPoints = new List<ViewPointValues>();
    currentDataCall = null;
    currentRepository = null;
    ElementList list = querySelectorAll('.repository');
    list.classes.remove('active');
  }

  String getMethodName(Symbol s){
    var name = MirrorSystem.getName(s);
    // make it more readable based on dart conventions
    List<int> chars = name.codeUnits;
    String readable = "";
    chars.forEach( (int c){
      if (c<97){
        // found a uppercase letter
        readable +=" ${new String.fromCharCode(c)}";
      } else {
        readable += "${new String.fromCharCode(c)}";
      }
    });
    return readable;
  }

  String _readCodeMirrorContent(Element e){
    String result ="";
    if (e != null && e.children!=null){
      e.children.forEach( (Element e){
        result = "$result\n${e.text}";
      });
    }
    return result;
  }

  removeDataDocument(DataDocument dd){
    Log.getInstance().info("Removing DataDocument ${dd.descripion} with repo ${dd.dataRepository.name}}");
    valueObject.dataDocuments.remove(
        dd
    );
  }

  toggleVisualizationMetrics(ViewPointValues vp){
    Log.getInstance().info("Toggling toggleVisualizationMetrics");
    prepareManipulator(vp);
    prepareMetric(vp);
    prepareReverseMetric(vp);
  }

  toggleVisualization(ViewPointValues vp){
    if (selectedViewPoints.contains(vp)){
      selectedViewPoints.remove(vp);
      Log.getInstance().info("Toggling vpv to true");
      destroyCodeContainer(vp);
    } else {
      selectedViewPoints.add(vp);
      Log.getInstance().info("Toggling vpv to false");
      prepareManipulator(vp);
      prepareMetric(vp);
      prepareReverseMetric(vp);
    }
  }

  saveDataView(){
    DataviewStorage storage = new DataviewStorage();
    storage.open()
    .then( (waitForEmptyReturn) => storage.remove(valueObject) )
    .then( (waitForEmptyReturn) => storage.add(valueObject) );

  }

  methodMirrorToString(MethodMirror theMirror){
    return MirrorSystem.getName(theMirror.simpleName);
  }

}
