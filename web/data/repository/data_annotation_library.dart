part of visualizer;

/**
* This class holds all annotationcodes for a repository. It gets subclassed per concrete repository. A generic subclass allows to use and define own annotationcodes
* that are not already provided in the database
*/
class DataAnnotationLibrary {

  List<DataAnnotationItem> defaultCodes = [
    new DataAnnotationItem()
      ..annotationCode = 0
      ..annotationName = "defaultCode"
      ..annotationTime = 0
      ..annotationKey = "a"
      ..annotationType = "genericAnnotations"
      ..annotationTask = "genericTask"
      ..annotationTarget = -1
  ];

  List<DataAnnotationItem> selectedCodes = null;
}
