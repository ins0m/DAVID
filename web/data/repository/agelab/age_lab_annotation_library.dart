part of visualizer;

class AgeLabAnnotationLibrary extends DataAnnotationLibrary {

  List<DataAnnotationItem> videoCodes = [
      new DataAnnotationItem()
        ..annotationCode = 0
        ..annotationName = "Looked at dash"
        ..annotationTime = 0
        ..annotationKey = "q"
        ..annotationType = "video"
        ..annotationTask = "agelabTask"
        ..annotationTarget = -1,
      new DataAnnotationItem()
        ..annotationCode = 1
        ..annotationName = "Looked at steeringwheel"
        ..annotationTime = 0
        ..annotationKey = "w"
        ..annotationType = "video"
        ..annotationTask = "agelabTask"
        ..annotationTarget = -1,
      new DataAnnotationItem()
        ..annotationCode = 2
        ..annotationName = "looked at radio"
        ..annotationTime = 0
        ..annotationKey = "e"
        ..annotationType = "video"
        ..annotationTask = "agelabTask"
        ..annotationTarget = -1,
      new DataAnnotationItem()
        ..annotationCode = 3
        ..annotationName = "looked at brake"
        ..annotationTime = 0
        ..annotationKey = "r"
        ..annotationType = "video"
        ..annotationTask = "agelabTask"
        ..annotationTarget = -1,
      new DataAnnotationItem()
        ..annotationCode = 4
        ..annotationName = "looked out window"
        ..annotationTime = 0
        ..annotationKey = "t"
        ..annotationType = "video"
        ..annotationTask = "agelabTask"
        ..annotationTarget = -1
  ];

  List<DataAnnotationItem> stressCodes = [
      new DataAnnotationItem()
        ..annotationCode = 10
        ..annotationName = "High stress level"
        ..annotationTime = 0
        ..annotationKey = "y"
        ..annotationType = "stress"
        ..annotationTask = "agelabTask"
        ..annotationTarget = -1,
      new DataAnnotationItem()
        ..annotationCode = 11
        ..annotationName = "Low stress level"
        ..annotationTime = 0
        ..annotationKey = "x"
        ..annotationType = "stress"
        ..annotationTask = "agelabTask"
        ..annotationTarget = -1,
      new DataAnnotationItem()
        ..annotationCode = 12
        ..annotationName = "Medium stress level"
        ..annotationTime = 0
        ..annotationKey = "c"
        ..annotationType = "stress"
        ..annotationTask = "agelabTask"
        ..annotationTarget = -1
  ];

  List<DataAnnotationItem> streetCodes = [
      new DataAnnotationItem()
        ..annotationCode = 20
        ..annotationName = "left curve"
        ..annotationTime = 0
        ..annotationKey = "a"
        ..annotationType = "video"
        ..annotationTask = "agelabTask"
        ..annotationTarget = -1,
      new DataAnnotationItem()
        ..annotationCode = 21
        ..annotationName = "right curve"
        ..annotationTime = 0
        ..annotationKey = "s"
        ..annotationType = "video"
        ..annotationTask = "agelabTask"
        ..annotationTarget = -1,
      new DataAnnotationItem()
        ..annotationCode = 22
        ..annotationName = "straight"
        ..annotationTime = 0
        ..annotationKey = "d"
        ..annotationType = "video"
        ..annotationTask = "agelabTask"
        ..annotationTarget = -1
  ];



}
