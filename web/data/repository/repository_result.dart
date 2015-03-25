part of visualizer;


class RepositoryResult {

  // This function will return Future<List>
  Function dataFutureFunction;
  DataAnnotationLibrary annotationCodes;
  Map<ClassMirror ,MetricLibrary> metrics;

  RepositoryResult() {
    metrics = new Map<ClassMirror ,MetricLibrary>();
  }


  addMetric(viewPoint, MetricLibrary configuredLib){
    InstanceMirror im = reflect(viewPoint);
    metrics[im.type] = configuredLib;
  }

  MetricLibrary getMetric(viewPoint){
    InstanceMirror im = reflect(viewPoint);
    return metrics[im.type];
  }
}
