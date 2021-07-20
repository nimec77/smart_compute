import 'package:dartz/dartz.dart';
import 'package:smart_compute/smart_compute.dart';
import 'package:test/test.dart';

void main() {
  test('Smart compute turn on', () async {
    final smartCompute = SmartCompute();
    await smartCompute.turnOn();
    expect(smartCompute.isRunning, equals(true));
    await smartCompute.turnOff();
  });

  test('Smart compute initially turned off', () async {
    final smartCompute = SmartCompute();
    expect(smartCompute.isRunning, equals(false));
  });

  test('Smart compute turn off', () async {
    final smartCompute = SmartCompute();
    await smartCompute.turnOn();
    await smartCompute.turnOff();
    expect(smartCompute.isRunning, equals(false));
  });

  test('Smart compute reload', () async {
    final smartCompute = SmartCompute();
    await smartCompute.turnOn();
    expect(smartCompute.isRunning, equals(true));
    await smartCompute.turnOff();
    expect(smartCompute.isRunning, equals(false));
    await smartCompute.turnOn();
    expect(smartCompute.isRunning, equals(true));
    final result = await smartCompute.compute<int, Either<Exception, int>>(eitherFib, param: 20);
    expect(result, equals(Right(fib20())));
    await smartCompute.turnOff();
  });

  test('Execute function with param', () async {
    final smartCompute = SmartCompute();
    await smartCompute.turnOn();

    final result = await smartCompute.compute<int, Either<Exception, int>>(eitherFib, param: 20);
    expect(result, equals(Right(fib20())));
    await smartCompute.turnOff();
  });

  test('Stress test', () async {
    final smartCompute = SmartCompute();
    await smartCompute.turnOn();

    const numOfTasks = 500;
    final result = await Future.wait(
      List<Future<Either<Exception, int>>>.generate(
        numOfTasks,
        (_) async => await smartCompute.compute<int, Either<Exception, int>>(eitherFib, param: 30),
      ),
    );

    final forComparison = List<Either<Exception, int>>.generate(numOfTasks, (_) => const Right(832040));

    expect(result, forComparison);

    await smartCompute.turnOff();
  });
}

Either<Exception, int> eitherFib(int n) {
  return Right(fib(n));
}

int fib(int n) {
  if (n < 2) {
    return n;
  }

  return fib(n - 2) + fib(n - 1);
}

int errorFib(int n) {
  throw Exception('Something went wrong');
}

Future<int> fibAsync(int n) async {
  await Future<void>.delayed(const Duration(milliseconds: 100));

  return fib(n);
}

int fib20() {
  return fib(20);
}

abstract class Fibonacci {
  static int fib(int n) {
    if (n < 2) {
      return n;
    }

    return fib(n - 2) * fib(n - 1);
  }
}
