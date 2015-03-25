library visualizer;


// general pacakges
import 'dart:html';
import 'dart:collection';
import 'dart:convert';
import 'dart:async';
import 'dart:indexed_db';
import 'dart:mirrors';
import 'package:serialization/serialization.dart';
import 'package:logging/logging.dart';
import 'package:js/js.dart' as js;
import 'package:perf_api/perf_api.dart';


// angular
import 'package:angular/angular.dart';
import 'package:angular/routing/module.dart';
import 'package:di/di.dart';


/*
 // FIXME
 Note: It is clear that the library packaging used in DAVID is a bad practice. While the individual
 parts of the system are built as if they were a library, this is not reflected in the structure
 dart provides for this. This shall be refactored and is an inherited debt from the first vertical
 prototype
 */
// constants
part 'david_constants.dart';

// logging
part '../utils/log_component.dart';

// utils
part '../utils/color_tools.dart';

// data
part '../data/data_document.dart';
part '../data/data_filter.dart';
part '../data/storage/dataview_storage.dart';
part '../data/data_annotation.dart';


part '../data/repository/sources/postgres_ws_resource.dart';
part '../data/repository/sources/file_resource.dart';
part '../data/repository/sources/ws_resource.dart';
part '../data/repository/repository.dart';
part '../data/repository/agelab/age_lab_onrd_repository_mock.dart';
part '../data/repository/agelab/age_lab_sim_repository_mock.dart';
part '../data/repository/database_tags.dart';
part '../data/repository/data_annotation_library.dart';
part '../data/repository/metric_library.dart';
part '../data/repository/agelab/age_lab_annotation_library.dart';
part '../data/repository/agelab/age_lab_metric_library.dart';
part '../data/repository/repository_result.dart';

// user
part '../data/data_coder.dart';
part '../data/repository/agelab/age_labe_coder.dart';
part 'landing_controller.dart';

// routing
part '../core/routing/core_router.dart';

// visualization
part 'visualization_tags.dart';
part 'chart/view_point_values.dart';
part 'chart/line_chart_component.dart';
part 'chart/horizon_chart_component.dart';
part 'chart/table_view_component.dart';
part 'chart/annotation_log_component.dart';
part 'chart/bar_chart_component.dart';
part 'chart/map_view_component.dart';
part 'chart/pie_chart_component.dart';
part 'chart/speed_view_component.dart';
part 'chart/steering_wheel_component.dart';
part 'chart/generic_view_component.dart';
part 'chart/connector_component.dart';
part 'chart/connector_controller.dart';
part 'chart/view_point_observable.dart';
part 'chart/video_view_component.dart';
part 'chart/view_point_controller.dart';
part 'chart/annotation_log_controller.dart';
part 'chart/view_point_events.dart';
part 'chart/view_point_connector.dart';

// controller
part 'dataviews_controller.dart';
part 'dataview_controller.dart';
part 'dataview_new_controller.dart';
part 'dataview_edit_controller.dart';
// components
part 'dataview_component.dart';


void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });
  ngBootstrap(module: new VisualizerModule());
}

class VisualizerModule extends Module {
  VisualizerModule() {
    type(DataviewComponent);

    type(DataviewsController);
    type(DataviewController);
    type(DataviewNewController);
    type(DataviewEditController);
    type(LandingController);

    type(HorizonChartComponent);
    type(LineChartComponent);
    type(TableViewComponent);
    type(VideoViewComponent);
    type(AnnotationLogComponent);
    type(BarChartComponent);
    type(MapViewComponent);
    type(PieChartComponent);
    type(GenericViewComponent);
    type(SpeedViewComponent);
    type(SteeringWheelComponent);
    type(ConnectorComponent);
    type(Log);
    //type(Profiler, implementedBy: Profiler); // comment out to enable profiling
    type(RouteInitializer, implementedBy: CoreRouter);
    factory(NgRoutingUsePushState,
        (_) => new NgRoutingUsePushState.value(false));
  }
}