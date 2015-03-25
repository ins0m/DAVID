part of visualizer;

@NgController(
    selector: '[landing]',
    publishAs: 'ctrl'
)
class LandingController {

  List<DataCoder> coders = (new AgeLabCoders()).getValidCoders();
  Router router;

  LandingController(Router router, RouteProvider routeProvider) {
    this.router = router;
    if (DataCoder.coderSet()){
      router.go('dataviews', {});
    }
  }

  setDataCoder(DataCoder c){
    if (c.isValid()){
      DataCoder.setToCurrentCoder(c);
      router.go('dataviews', {});
    }
  }
}
