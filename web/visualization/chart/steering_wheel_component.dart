part of visualizer;

class SteeringWheelValues extends ViewPointValues{
  String gridRoot = "snap-top-right";

  String selector = 'steeringwheel';

  SteeringWheelValues(){
    name="steeringwheel chart";
    description = "none";
  }

}

/**
* This class is the entry point for the dom connection. It serves only as a bridge class and does not have a strong semantic meaning
*/
@NgComponent(
    selector: 'steeringwheel',
    templateUrl: '../component/container_chart.html',
    cssUrls: DavidConstants.davidCssBase,
    applyAuthorStyles: true,
    publishAs: 'ctrl',
    map: const {
        'values' : '<=>values'
    }
)
class SteeringWheelComponent extends  NgShadowRootAware{
  SteeringWheelValues values = null;

  Compiler compiler;
  Injector injector;

  SteeringWheelComponent() {
  }

  onShadowRoot(ShadowRoot root){
    values.chart = new js.Proxy(js.context.SteeringWheel);
    values.observableController.setUpViewPoint(root);
  }

}
