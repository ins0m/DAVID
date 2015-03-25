part of visualizer;

class VideoViewValues extends ViewPointValues{
  String gridRoot = "snap-top-right";

  String selector = 'videoview';

  VideoViewValues(){
  name="Videoview";
  description = "none";
  }
}

/**
* This class is the entry point for the dom connection. It serves only as a bridge class and does not have a strong semantic meaning
*/
@NgComponent(
  selector: 'videoview',
  templateUrl: '../component/container_chart.html',
  cssUrls: DavidConstants.davidCssBase,
  applyAuthorStyles: true,
  publishAs: 'ctrl',
  map: const {
  'values' : '<=>values'
  }
)
class VideoViewComponent extends  NgShadowRootAware{
  VideoViewValues values = null;

  Compiler compiler;
  Injector injector;

  VideoViewComponent() {
  }

  onShadowRoot(ShadowRoot root){
    values.chart = new js.Proxy(js.context.VideoView);
    values.observableController.setUpViewPoint(root);
  }

}
