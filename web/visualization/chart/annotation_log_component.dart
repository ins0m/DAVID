part of visualizer;

class AnnotationLogValues extends ViewPointValues{
  String gridRoot = "snap-top-left";

  String selector = 'annotationlog';

  AnnotationLogValues(){
    name="Annotation log";
    description = "none";
  }

}

/**
* This class is the entry point for the dom connection. It serves only as a bridge class and does not have a strong semantic meaning
*/
@NgComponent(
    selector: 'annotationlog',
    templateUrl: '../component/container_annotation.html',
    cssUrls: DavidConstants.davidCssBase,
    applyAuthorStyles: true,
    publishAs: 'ctrl',
    map: const {
        'values' : '<=>values'
    }
)
class AnnotationLogComponent extends NgShadowRootAware {

  AnnotationLogValues values = null;

  Compiler compiler;
  Injector injector;

  AnnotationLogComponent(){
  }

  onShadowRoot(ShadowRoot root){
    values.observableController = new AnnotationLogController();
    values.observableController.setValues(values);
    values.chart = new js.Proxy(js.context.AnnotationLog);
    values.observableController.setUpViewPoint(root);
  }

}
