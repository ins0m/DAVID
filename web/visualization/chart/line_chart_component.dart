part of visualizer;

class LineChartValues extends ViewPointValues{
  String gridRoot = "snap-top-right";

  String selector = 'linechart';

  LineChartValues(){
    name="Line chart";
    description = "none";
  }

}

/**
* This class is the entry point for the dom connection. It serves only as a bridge class and does not have a strong semantic meaning
*/
@NgComponent(
    selector: 'linechart',
    templateUrl: '../component/container_chart.html',
    cssUrls: DavidConstants.davidCssBase,
    applyAuthorStyles: true,
    publishAs: 'ctrl',
    map: const {
        'values' : '<=>values'
    }
)
class LineChartComponent extends  NgShadowRootAware{
  LineChartValues values = null;

  Compiler compiler;
  Injector injector;

  LineChartComponent() {
  }

  onShadowRoot(ShadowRoot root){
    values.chart = new js.Proxy(js.context.LineChart);
    values.observableController.setUpViewPoint(root);
  }

}
