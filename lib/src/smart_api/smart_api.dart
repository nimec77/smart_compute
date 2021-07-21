import 'dart:async';
import 'dart:collection';
import 'dart:isolate';

import 'package:dartz/dartz.dart';
import 'package:smart_compute/src/smart_api/smart_task_result.dart';
import 'package:smart_compute/src/smart_api/worker.dart';

import 'smart_task.dart';

class SmartAPI {
  bool isRunning = false;

  Worker _worker = Worker.empty();

  final _taskQueue = Queue<SmartTask>();

  final _activeTaskCompleters = <Capability, Completer>{};

  Future<void> turnOn() async {
    if (_worker == Worker.empty()) {
      _worker = Worker('smart_worker');
    }
    await _worker.init(onResult: _onTaskFinished);

    isRunning = true;
  }

  void _onTaskFinished(SmartTaskResult result, Worker worker) {
    _activeTaskCompleters.remove(result.capability)!.complete(result.result);

    if (_taskQueue.isNotEmpty) {
      final task = _taskQueue.removeFirst();
      _worker.execute(task);
    }
  }

  Future<Either<Error, R>> compute<P, R>(
    Function fn, {
    P? param,
  }) async {
    final taskCapability = Capability();
    final taskCompleter = Completer();

    final task = SmartTask(
      task: fn,
      param: param,
      capability: taskCapability,
    );

    _activeTaskCompleters[taskCapability] = taskCompleter;

    if (_worker.status == WorkerStatus.processing) {
      _taskQueue.add(task);
    } else {
      _worker.execute(task);
    }

    final result = await taskCompleter.future;
    if (result is Either<Error, R>) {
      return result;
    }

    if (result is RemoteError) {
      return Left(result);
    }

    return Right(result);
  }

  Future<void> turnOff() async {
    await _worker.dispose();

    for (final completer in _activeTaskCompleters.values) {
      if (!completer.isCompleted) {
        completer.complete(Left(Exception('Cancel because of smart_compute turn off')));
      }
    }
    _activeTaskCompleters.clear();

    _worker = Worker.empty();
    _taskQueue.clear();

    isRunning = false;
  }
}
