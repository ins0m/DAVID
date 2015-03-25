part of visualizer;

class HorizonChartValues extends ViewPointValues{
  String gridRoot = "snap-top-left";

  String selector = 'horizonchart';

  HorizonChartValues(){
    name="Horizon chart";
    description = "none";
  }

}

/**
* This class is the entry point for the dom connection. It serves only as a bridge class and does not have a strong semantic meaning
*/
@NgComponent(
    selector: 'horizonchart',
    templateUrl: '../component/container_chart.html',
    cssUrls: DavidConstants.davidCssBase,
    applyAuthorStyles: true,
    publishAs: 'ctrl',
    map: const {
    'values' : '<=>values'
    }
)
class HorizonChartComponent extends NgShadowRootAware {

  HorizonChartValues values = null;

  Compiler compiler;
  Injector injector;

  HorizonChartComponent(){
  }

  onShadowRoot(ShadowRoot root){
    values.chart = new js.Proxy(js.context.HorizonChart);
    values.observableController.setUpViewPoint(root);
  }

}
