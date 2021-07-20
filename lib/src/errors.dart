import 'dart:isolate';

class RemoteExecutionError implements Exception {
  RemoteExecutionError(this.message, this.taskCapability);

  final String message;
  final Capability taskCapability;

  @override
  String toString() => message;
}
