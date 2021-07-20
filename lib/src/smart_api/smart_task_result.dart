import 'dart:isolate';

import 'package:dartz/dartz.dart';

class SmartTaskResult {
  SmartTaskResult({required this.result, required this.capability});

  final Either result;
  final Capability capability;
}
