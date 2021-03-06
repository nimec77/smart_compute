import 'dart:async';
import 'dart:isolate';

import 'package:dartz/dartz.dart';
import 'package:smart_compute/src/smart_api/smart_task_result.dart';

import 'smart_task.dart';

typedef ReturnType = Either<Exception, dynamic>;

typedef OnResultCallback = void Function(
  SmartTaskResult result,
  Worker worker,
);

enum WorkerStatus { idle, processing }

class IsolateInParams {
  IsolateInParams(this.sendPort);

  final SendPort sendPort;
}

class Worker {
  factory Worker.empty() => Worker('');

  Worker(this.name);

  final String name;

  WorkerStatus status = WorkerStatus.idle;

  late final Isolate _isolate;
  late final SendPort _sendPort;
  late final ReceivePort _receivePort;
  late final Stream _broadcastReceivePort;
  late final StreamSubscription _broadcastPortSubscription;

  Future<void> init({required OnResultCallback onResult}) async {
    _receivePort = ReceivePort();

    _isolate = await Isolate.spawn(
      isolateEntryPoint,
      IsolateInParams(_receivePort.sendPort),
      debugName: name,
      errorsAreFatal: false,
    );

    _broadcastReceivePort = _receivePort.asBroadcastStream();

    _sendPort = await _broadcastReceivePort.first as SendPort;

    _broadcastPortSubscription = _broadcastReceivePort.listen((res) {
      status = WorkerStatus.idle;

      onResult(res as SmartTaskResult, this);
    });
  }

  void execute(SmartTask task) {
    status = WorkerStatus.processing;
    _sendPort.send(task);
  }

  Future<void> dispose() async {
    await _broadcastPortSubscription.cancel();
    _isolate.kill();
    _receivePort.close();
  }

  @override
  int get hashCode => name.hashCode;

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is Worker && name == other.name;
  }
}

Future<void> isolateEntryPoint(IsolateInParams params) async {
  final receivePort = ReceivePort();
  final sendPort = params.sendPort..send(receivePort.sendPort);

  await for (final task in receivePort.cast<SmartTask>()) {
    try {
      final shouldPassParam = task.param != null;

      final computationResult = shouldPassParam ? await task.task(task.param) : await task.task();

      final result = SmartTaskResult(result: computationResult, capability: task.capability);

      sendPort.send(result);
    } on Error catch (error) {
      final remoteError = RemoteError(error.toString(), error.stackTrace.toString());
      final result = SmartTaskResult(result: remoteError, capability: task.capability);
      sendPort.send(result);
    } on Exception catch (exception) {
      final remoteError = RemoteError(exception.toString(), 'Stack trace not available');
      final result = SmartTaskResult(result: remoteError, capability: task.capability);
      sendPort.send(result);
    }
  }
}
