part of visualizer;

abstract class ViewPointObservable {
  addObserverById(String remoteDomId);
  addObserver(ViewPointController observable);
  removeObserverById(String remoteSourceDomId, String remoteTargetDomId);
  removeObserver(ViewPointController observable);
  propagateTick(int tickEvent, {int absoluteValue:0, int relativeValue:0, dataValue:0});
  receiveTick(int tickEvent, {int absoluteValue:0, int relativeValue:0, dataValue:0});

}
