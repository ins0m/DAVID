part of visualizer;

class SpeedViewValues extends ViewPointValues{
  String gridRoot = "snap-top-right";

  String selector = 'speedview';

  SpeedViewValues(){
    name="Speed view chart";
    description = "none";
  }

}

/**
* This class is the entry point for the dom connection. It serves only as a bridge class and does not have a strong semantic meaning
*/
@NgComponent(
    selector: 'speedview',
    templateUrl: '../component/container_chart.html',
    cssUrls: DavidConstants.davidCssBase,
    applyAuthorStyles: true,
    publishAs: 'ctrl',
    map: const {
        'values' : '<=>values'
    }
)
class SpeedViewComponent extends  NgShadowRootAware{
  SpeedViewValues values = null;

  Compiler compiler;
  Injector injector;

  SpeedViewComponent() {
  }

  onShadowRoot(ShadowRoot root){
    values.chart = new js.Proxy(js.context.SpeedView);
    values.observableController.setUpViewPoint(root);
  }

}
