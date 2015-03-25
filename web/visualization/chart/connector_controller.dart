part of visualizer;

class ConnectorController extends ViewPointController {

  WebSocket ws;
  Serialization serializationRules;
  List<String> knownNetworkEndpoints = [];
  var selectedNetworkEndpoint = DataCoder.getCoder().name;

  ConnectorController(){
    serializationRules = new Serialization()
      ..addDefaultRules()
      ..addRuleFor(new DataviewValues())
      ..addRuleFor(new DataAnnotation())
      ..addRuleFor(new ViewPointValues())
      ..addRuleFor(new ViewPointEvents());
    ws = new WebSocket('ws://localhost:8081');
    ws.onOpen.first.then((_) {
      Log.getInstance().info('Connected');

      // this is where it gets ridiculous. apparently nodejs ws server has a hughe buffering problem. Sometimes messages are simply not read until the are extremely big. This is why we write this shit here (buffer)
      // You are welcome to fix this but please increment the following counter once you give up:
      // totalWastedHours: 3
      ws.sendString(JSON.encode(
          {
              // TODO: Make this selectable by userlist
              'name': DataCoder.getCoder().name,
              'register':true,
              'buffer1': 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.Section 1.10.32 of "de Finibus Bonorum et Malorum", written by Cicero in 45 BCSed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?1914 translation by H. RackhamBut I must explain to you how all this mistaken idea of denouncing pleasure and praising pain was born and I will give you a complete account of the system, and expound the actual teachings of the great explorer of the truth, the master-builder of human happiness. No one rejects, dislikes, or avoids pleasure itself, because it is pleasure, but because those who do not know how to pursue pleasure rationally encounter consequences that are extremely painful. Nor again is there anyone who loves or pursues or desires to obtain pain of itself, because it is pain, but because occasionally circumstances occur in which toil and pain can procure him some great pleasure. To take a trivial example, which of us ever undertakes laborious physical exercise, except to obtain some advantage from it? But who has any right to find fault with a man who chooses to enjoy a pleasure that has no annoying consequences, or one who avoids a pain that produces no resultant pleasure?Section 1.10.33 of "de Finibus Bonorum et Malorum", written by Cicero in 45 BCAt vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident, similique sunt in culpa qui officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio cumque nihil impedit quo minus id quod maxime placeat facere possimus, omnis voluptas assumenda est, omnis dolor repellendus. Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet ut et voluptates repudiandae sint et molestiae non recusandae. Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus maiores alias consequatur aut perferendis doloribus asperiores repellat.1914 translation by H. RackhamOn the other hand, we denounce with righteous indignation and dislike men who are so beguiled and demoralized by the charms of pleasure of the moment, so blinded by desire, that they cannot foresee the pain and trouble that are bound to ensue; and equal blame belongs to those who fail in their duty through weakness of will, which is the same as saying through shrinking from toil and pain. These cases are perfectly simple and easy to distinguish. In a free hour, when our power of choice is untrammelled and when nothing prevents our being able to do what we like best, every pleasure is to be welcomed and every pain avoided. But in certain circumstances and owing to the claims of duty or the obligations of business it will frequently occur that pleasures have to be repudiated and annoyances accepted. The wise man therefore always holds in these matters to this principle of selection: he rejects pleasures to secure other greater pleasures, or else he endures pains to avoid worse pains.'
          })
      );
      Log.getInstance().info("Send ws string");

      ws.onMessage.listen((MessageEvent e) {
        Log.getInstance().info('s: ${e.data}');
        Log.getInstance().info('d: ${JSON.decode(e.data)}');
        var data = JSON.decode(e.data);
        if (data is List){

          Log.getInstance().info('List message: ${data}');
          knownNetworkEndpoints = data;
        } else {
          data = serializationRules.read(data['data']);
          Log.getInstance().info('Received message: ${data}');
          Log.getInstance().info('Received values: ${data['tickEvent']},${data['absoluteValue']},${data['relativeValue']},${data['dataValue']},');
          // let the chart tick with this stuff. But in a special way. send a network event
          propagateTick(data['tickEvent'],absoluteValue:data['absoluteValue'],relativeValue:data['relativeValue'],linkValue:data['linkValue'], dataValue:data['dataValue']);
        }
      });

      ws.onClose.listen((e) {
        Log.getInstance().info('Websocket closed');
      });

      ws.onError.listen((e) {
        Log.getInstance().info("Error connecting to ws");

      });
    });
  }


  propagateTick(int tickEvent, {int absoluteValue:0, int relativeValue:0, linkValue:0 ,dataValue:0}){
    values.observer.forEach( (ViewPointConnector vpc){
      // we propagate all values. Each observer can define for himself how to handle the data dependent on its state
      vpc.dst.receiveTick(vpc, tickEvent,
      absoluteValue:absoluteValue,
      relativeValue:relativeValue,
      linkValue:linkValue,
      dataValue:dataValue);
    });
  }


  propagateTickToNetwork(int tickEvent, {int absoluteValue:0, int relativeValue:0, linkValue:0 ,dataValue:0}){

    switch (tickEvent) {
      case ViewPointEvents.ANNOTATION_ADD_EVENT:
      case ViewPointEvents.ANNOTATION_DELETE_EVENT:
        dataValue.parent = null;
    }

    ws.sendString(
        JSON.encode(
            {
                'name':DataCoder.getCoder().name,
                'target':selectedNetworkEndpoint,
                'data':serializationRules.write({
                  'tickEvent':tickEvent,
                  'absoluteValue':absoluteValue,
                  'relativeValue':relativeValue,
                  'dataValue': dataValue,
                  'linkValue':linkValue
                })
            }
        )
    );
  }


  setUpEndpoint(){
    super.setUpEndpoint();

  }

    /**
   * Called whenever an observed chart propagates a tick. The tick propagates an event and corresponding values
   * TODO: datavalue is not used or sent yet.
   */
  receiveTick(ViewPointConnector vpc, int tickEvent, {int absoluteValue:0, int relativeValue:0, linkValue:0, dataValue:0}){
    // now make sure to propagate the tick to the component implementation
    if (vpc!=null){
      Log.getInstance().info("chart ${values.domID} got a tick after $relativeValue with absolute dif $absoluteValue");
      propagateTick(tickEvent,absoluteValue:absoluteValue,relativeValue:relativeValue, dataValue:dataValue);
      propagateTickToNetwork(tickEvent,absoluteValue:absoluteValue,relativeValue:relativeValue, dataValue:dataValue, linkValue:linkValue);
      // let the chart tick with this stuff. But in a special way. send a network event
    }
  }

  setTarget (String name){
    selectedNetworkEndpoint = name;
  }

}



