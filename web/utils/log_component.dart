part of visualizer;

@NgComponent(
    selector: 'console',
    templateUrl: '../component/container_log.html',
    cssUrls: DavidConstants.davidCssBase,
    applyAuthorStyles: true,
    publishAs: 'ctrl'
)

class Log extends NgShadowRootAware {
  static var instance;
  var successConsole;
  bool activated = false;
  var shadowRoot;
  List<List<String>>queuedMessages;

  static Log getInstance() {
    if (instance == null ){
        new Log();
    }
    return instance;
  }

  Log() {
    instance = this;
    queuedMessages = new List<List<String>>();
  }

  onShadowRoot(root){
    shadowRoot = root;
    success("Log initialized. Printing queue");
  }

  success(message){
    _log(message,"positive");
  }
  error(message){
    _log(message,"error");
  }
  warning(message){
    _log(message,"warning");
  }
  info(message){
    _log(message,"");
  }
  message(message){
    _log(message,"");
  }

  _log(message, level){
    // we drop all log information if the console hasn't been opened. we save a _lot_ of overhead here.
    if (!activated){ return;}
    if(shadowRoot!=null){

      String time =  (new DateTime.now()).toString();
      successConsole = shadowRoot.query("#console");

      for (String oldMessage in queuedMessages) {
        Element oldMessageElement = new Element.tag('tr')
          ..append(
            new Element.tag('td')
              ..innerHtml = "before init")
          ..append(
            new Element.tag('td')
              ..className = level
              ..innerHtml = oldMessage[0])
          ..append( new Element.tag('td')
              ..style.wordWrap = 'break-word'
              ..innerHtml = oldMessage[1]);
        successConsole.nodes.add(oldMessageElement);
      };
      queuedMessages.clear();


      Element messageElement = new Element.tag('tr')
        ..append(
          new Element.tag('td')
            ..innerHtml = time)
        ..append(
          new Element.tag('td')
            ..className = level
            ..innerHtml = level)
        ..append( new Element.tag('td')
        ..style.wordWrap = 'break-word'
        ..innerHtml = message);
      successConsole.nodes.add(messageElement);
    } else {
      var msgList = new List();
      msgList.add(level);
      msgList.add(message);
      queuedMessages.add(msgList);
}
  }

  toggleConsole(){
    var consoleContainer = shadowRoot.querySelector('#console-area');
    var consoleButton = shadowRoot.querySelector('#console-toggle');
    consoleContainer.classes.toggle("hidden");
    consoleButton.innerHtml = consoleContainer.classes.contains("hidden") ? "Show" : "Hide";
    activated = true;
  }
}
