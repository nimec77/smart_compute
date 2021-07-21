import 'dart:isolate';

class SmartTask<P> {
  const SmartTask({
    required this.task,
    required this.param,
    required this.capability,
  });

  final Function task;
  final P param;

  final Capability capability;
}
