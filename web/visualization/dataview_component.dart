part of visualizer;

@NgComponent(
    selector: 'dataviewmini',
    publishAs: 'dataviewmini',
    templateUrl: '../component/container_dataview.html',
    cssUrls: DavidConstants.davidCssBase,
    applyAuthorStyles: true,
    map: const {
    'outercontroller': '<=>outercontroller',
    'values' : '<=>values'
    }
)
class DataviewComponent extends NgShadowRootAware {
  DataviewValues values = null;
  DataviewsController outercontroller = null;

  var shadowRoot;

  DataviewComponent() {
    Log.getInstance().info("Loaded the dataview component");
  }

  onShadowRoot(root){
    shadowRoot = root;
    Log.getInstance().success("Values are: ${values.description}");
    values.dataDocuments.forEach( (DataDocument dd){
      Log.getInstance().success("DataDocument are: ${dd.descripion}");
      dd.viewPoints.forEach( (ViewPointValues val){
        Log.getInstance().success("ViewPointValues are: ${val.name}");
      });
    });
  }

  delete(){
    outercontroller.values.dataviewValues.remove(values);
    DataviewStorage storage = new DataviewStorage();
    storage.open()
    .then( (waitForEmptyReturn) => storage.remove(values));
    outercontroller.sortBy("");
  }

}