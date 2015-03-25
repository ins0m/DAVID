part of visualizer;

class CoreRouter implements RouteInitializer {

  init(Router router, ViewFactory view) {
    router.root
      ..addRoute(
        name: 'view_default',
        defaultRoute: true,
        enter: (_) =>
          router.go('dataviews', {},
            startingFrom: null, replace:true))
      ..addRoute(
        name: 'landing',
        path: '/landing',
        //enter: view('dataviews.html'))
        enter: view('landing.html'))

      ..addRoute(
        name: 'dataviews',
        path: '/dataviews',
        //enter: view('dataviews.html'))
        enter: authView(router, view('dataviews.html')))
      ..addRoute(
        name: 'dataview',
        path: '/dataview',
        mount: (Route route) => route
          ..addRoute(
            name: 'view',
            path: '/:viewName/view',
            enter: authView(router, view('dataview.html')))
          ..addRoute(
            name: 'edit',
            path: '/:viewName/edit',
            enter: authView(router, view('dataview_edit.html')))
          ..addRoute(
            name: 'new',
            path: '/new',
            enter: authView(router, view('dataview_new.html')))
          ..addRoute(
            name: 'chart',
            path: '/:viewName/chart/:chartId',
            enter: authView(router, view('dataview_chart.html')))
          ..addRoute(
            name: 'view_default',
            defaultRoute: true,
            enter: (_) =>
              router.go('view', {'viewName': ':viewName'},
                startingFrom: route, replace:true)));
  }

  authView(Router router, ngView) {
    return (RouteEvent e) {
        if (!DataCoder.coderSet()) {
          router.go('landing', {});
          return;
        }
      ngView(e);
    };
  }
}