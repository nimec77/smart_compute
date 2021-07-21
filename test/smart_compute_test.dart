import 'package:dartz/dartz.dart';
import 'package:smart_compute/smart_compute.dart';
import 'package:smart_compute/src/errors.dart';
import 'package:test/test.dart';

typedef EitherInt = Either<Exception, int>;

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
    final result = await smartCompute.compute<int, EitherInt>(eitherFib, param: 20);
    expect(result, equals(Right(fib20())));
    await smartCompute.turnOff();
  });

  test('Execute function with param', () async {
    final smartCompute = SmartCompute();
    await smartCompute.turnOn();

    final result = await smartCompute.compute<int, EitherInt>(eitherFib, param: 20);
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
        (_) async => await smartCompute.compute<int, EitherInt>(eitherFib, param: 30),
      ),
    );

    final forComparison = List<EitherInt>.generate(numOfTasks, (_) => const Right(832040));

    expect(result, forComparison);

    await smartCompute.turnOff();
  });

  test('Execute function without params', () async {
    final smartCompute = SmartCompute();
    await smartCompute.turnOn();

    final result = await smartCompute.compute<int, EitherInt>(eitherFib20);

    expect(result, equals(eitherFib20()));
    await smartCompute.turnOff();
  });

  test('Execute static method', () async {
    final smartCompute = SmartCompute();
    await smartCompute.turnOn();

    final result = await smartCompute.compute<int, EitherInt>(Fibonacci.eitherFib, param: 20);

    expect(result, equals(Fibonacci.eitherFib(20)));
    await smartCompute.turnOff();
  });

  test('Execute async method', () async {
    final smartCompute = SmartCompute();
    await smartCompute.turnOn();

    final result = await smartCompute.compute<int, EitherInt>(eitherFibAsync, param: 20);

    expect(result, equals(await eitherFibAsync(20)));
    await smartCompute.turnOff();
  });

  test('Left method', () async {
    final smartCompute = SmartCompute();
    await smartCompute.turnOn();

    final result = await smartCompute.compute<int, EitherInt>(eitherErrorFib, param: 20);

    expect(result.isLeft(), equals(true));
    result.leftMap((exception) {
      expect(exception, isA<Exception>());
      expect(exception.toString(), 'Exception: Something went wrong');
    });
    await smartCompute.turnOff();
  });

  test('Error method', () async {
    final smartCompute = SmartCompute();
    await smartCompute.turnOn();

    expect(
      () async => await smartCompute.compute<int, int>(errorFib, param: 20),
      throwsA(isA<RemoteExecutionError>()),
    );
  });

  test('SmartCompute is a singleton', () async {
    final smartCompute1 = SmartCompute();
    final smartCompute2 = SmartCompute();

    expect(smartCompute1 == smartCompute2, equals(true));
  });
}

EitherInt eitherFib(int n) {
  return Right(fib(n));
}

int fib(int n) {
  if (n < 2) {
    return n;
  }

  return fib(n - 2) + fib(n - 1);
}

EitherInt eitherErrorFib(int n) {
  try {
    return Right(errorFib(n));
  } on Exception catch (e) {
    return Left(e);
  }
}

int errorFib(int n) {
  throw Exception('Something went wrong');
}

Future<EitherInt> eitherFibAsync(int n) async {
  return Right(await fibAsync(n));
}

Future<int> fibAsync(int n) async {
  await Future<void>.delayed(const Duration(milliseconds: 100));

  return fib(n);
}

EitherInt eitherFib20() {
  return Right(fib20());
}

int fib20() {
  return fib(20);
}

abstract class Fibonacci {
  static EitherInt eitherFib(int n) {
    return Right(fib(n));
  }

  static int fib(int n) {
    if (n < 2) {
      return n;
    }

    return fib(n - 2) * fib(n - 1);
  }
}
