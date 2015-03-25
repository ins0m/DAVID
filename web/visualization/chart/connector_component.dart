part of visualizer;

class ConnectorValues extends ViewPointValues{
  String gridRoot = "snap-top-right";

  String selector = 'connector';

  ConnectorValues(){
  name="Socket connector";
  description = "none";
  }
}

/**
* This class is the entry point for the dom connection. It serves only as a bridge class and does not have a strong semantic meaning
*/
@NgComponent(
  selector: 'connector',
  templateUrl: '../component/container_connector.html',
  cssUrls: DavidConstants.davidCssBase,
  applyAuthorStyles: true,
  publishAs: 'ctrl',
  map: const {
  'values' : '<=>values'
  }
)
class ConnectorComponent extends  NgShadowRootAware{
  ConnectorValues values = null;

  Compiler compiler;
  Injector injector;

  ConnectorComponent() {
  }

  onShadowRoot(ShadowRoot root){
    values.observableController = new ConnectorController();
    values.observableController.setValues(values);
    values.chart = new js.Proxy(js.context.Connector);
    values.observableController.setUpViewPoint(root);
  }

}
