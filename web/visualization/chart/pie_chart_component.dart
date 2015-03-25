part of visualizer;

class PieChartValues extends ViewPointValues{
  String gridRoot = "snap-top-right";

  String selector = 'piechart';

  PieChartValues(){
    name="Pie chart";
    description = "none";
  }

}

/**
* This class is the entry point for the dom connection. It serves only as a bridge class and does not have a strong semantic meaning
*/
@NgComponent(
    selector: 'piechart',
    templateUrl: '../component/container_chart.html',
    cssUrls: DavidConstants.davidCssBase,
    applyAuthorStyles: true,
    publishAs: 'ctrl',
    map: const {
        'values' : '<=>values'
    }
)
class PieChartComponent extends  NgShadowRootAware{
  PieChartValues values = null;

  Compiler compiler;
  Injector injector;

  PieChartComponent() {
  }

  onShadowRoot(ShadowRoot root){
    values.chart = new js.Proxy(js.context.PieChart);
    values.observableController.setUpViewPoint(root);
  }

}
