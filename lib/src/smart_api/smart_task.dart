import 'dart:isolate';

class SmartTask {
  SmartTask({
    required this.task,
    required this.param,
    required this.capability,
  });

  final Function task;
  final dynamic param;

  final Capability capability;
}
