part of visualizer;

class BarChartValues extends ViewPointValues{
  String gridRoot = "snap-top-right";

  String selector = 'barchart';

  BarChartValues(){
    name="Bar chart";
    description = "none";
  }

}

/**
* This class is the entry point for the dom connection. It serves only as a bridge class and does not have a strong semantic meaning
*/
@NgComponent(
    selector: 'barchart',
    templateUrl: '../component/container_chart.html',
    cssUrls: DavidConstants.davidCssBase,
    applyAuthorStyles: true,
    publishAs: 'ctrl',
    map: const {
        'values' : '<=>values'
    }
)
class BarChartComponent extends  NgShadowRootAware{
  BarChartValues values = null;

  Compiler compiler;
  Injector injector;

  BarChartComponent() {
  }

  onShadowRoot(ShadowRoot root){
    values.chart = new js.Proxy(js.context.BarChart);
    values.observableController.setUpViewPoint(root);
  }

}
