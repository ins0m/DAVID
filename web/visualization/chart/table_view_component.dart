part of visualizer;

class TableViewValues extends ViewPointValues{
  String gridRoot = "snap-top-right";

  String selector = 'tableview';

  TableViewValues(){
    name="Tableview";
    description = "none";
  }
}

/**
* This class is the entry point for the dom connection. It serves only as a bridge class and does not have a strong semantic meaning
*/
@NgComponent(
    selector: 'tableview',
    templateUrl: '../component/container_chart.html',
    cssUrls: DavidConstants.davidCssBase,
    applyAuthorStyles: true,
    publishAs: 'ctrl',
    map: const {
        'values' : '<=>values'
    }
)
class TableViewComponent extends  NgShadowRootAware{
  TableViewValues values = null;

  Compiler compiler;
  Injector injector;

  TableViewComponent() {
  }

  onShadowRoot(ShadowRoot root){
    values.chart = new js.Proxy(js.context.TableView);
    values.observableController.setUpViewPoint(root);
  }

}
