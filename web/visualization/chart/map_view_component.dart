part of visualizer;

class MapViewValues extends ViewPointValues{
  String gridRoot = "snap-top-right";

  String selector = 'mapview';

  MapViewValues(){
    name="Map chart";
    description = "none";
  }

}

/**
* This class is the entry point for the dom connection. It serves only as a bridge class and does not have a strong semantic meaning
*/
@NgComponent(
    selector: 'mapview',
    templateUrl: '../component/container_chart.html',
    cssUrls: DavidConstants.davidCssBase,
    applyAuthorStyles: true,
    publishAs: 'ctrl',
    map: const {
        'values' : '<=>values'
    }
)
class MapViewComponent extends  NgShadowRootAware{
  MapViewValues values = null;

  Compiler compiler;
  Injector injector;

  MapViewComponent() {
  }

  onShadowRoot(ShadowRoot root){
    values.chart = new js.Proxy(js.context.MapView);
    values.observableController.setUpViewPoint(root);
  }

}
