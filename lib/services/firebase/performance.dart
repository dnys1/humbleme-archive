import 'dart:async';

import 'package:firebase_performance/firebase_performance.dart';
import 'package:meta/meta.dart';

import '../api/models.dart';

class FirebasePerformanceRepository extends PerformanceMonitoringRepository {
  final FirebasePerformance performance;
  Map<String, Trace> runningTraces = Map<String, Trace>();

  FirebasePerformanceRepository({
    @required this.performance,
  }) : assert(performance != null);

  @override
  FirebasePerformance getInstance() => performance;

  @override
  Future<void> startTrace(String name) async {
    Trace trace = performance.newTrace(name);
    runningTraces.putIfAbsent(name, () => trace..start());
    return;
  }

  @override
  Future<void> stopTrace(String name) async {
    return runningTraces.remove(name)?.stop();
  }
}
