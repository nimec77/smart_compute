import 'package:dartz/dartz.dart';
import 'package:smart_compute/src/smart_api/smart_api.dart';

class SmartCompute {
  factory SmartCompute() => _singleton;

  SmartCompute._internal();

  final _smartDelegate = SmartAPI();

  static final _singleton = SmartCompute._internal();

  bool get isRunning => _smartDelegate.isRunning;

  Future<void> turnOn() async {
    return _smartDelegate.turnOn();
  }

  Future<Either<Error, R>> compute<P, R>(
    Function fn, {
    P? param,
  }) async {
    return _smartDelegate.compute<P, R>(fn, param: param);
  }

  Future<void> turnOff() async {
    return _smartDelegate.turnOff();
  }
}
