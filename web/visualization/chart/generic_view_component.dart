part of visualizer;

class GenericViewValues extends ViewPointValues{
  String gridRoot = "snap-top-right";

  String selector = 'genericview';

  GenericViewValues(){
    name="Generic view";
    description = "none";
  }

}

/**
* This class is the entry point for the dom connection. It serves only as a bridge class and does not have a strong semantic meaning
*/
@NgComponent(
    selector: 'genericview',
    templateUrl: '../component/container_chart.html',
    cssUrls: DavidConstants.davidCssBase,
    applyAuthorStyles: true,
    publishAs: 'ctrl',
    map: const {
        'values' : '<=>values'
    }
)
class GenericViewComponent extends  NgShadowRootAware{
  GenericViewValues values = null;

  Compiler compiler;
  Injector injector;

  GenericViewComponent() {
  }

  onShadowRoot(ShadowRoot root){
    values.chart = new js.Proxy(js.context.GenericView);
    values.observableController.setUpViewPoint(root);
  }

}
