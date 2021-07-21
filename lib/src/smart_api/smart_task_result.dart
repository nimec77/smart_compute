import 'dart:isolate';

class SmartTaskResult {
  SmartTaskResult({required this.result, required this.capability});

  final dynamic result;
  final Capability capability;
}
