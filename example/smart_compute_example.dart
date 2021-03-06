//ignore_for_file: avoid_print

import 'package:dartz/dartz.dart';
import 'package:smart_compute/smart_compute.dart';

typedef EitherInt = Either<Error, int>;

void main() async {
  final smartCompute = SmartCompute();
  await smartCompute.turnOn();

  final a = await smartCompute.compute<int, int>(eitherAsyncFib, param: 40);
  print('Calculate a:$a');

  final b = await smartCompute.compute<int, int>(eitherFib, param: 30);
  print('Calculate b:$b');

  final c = await smartCompute.compute<int, int>(fib, param: 20);
  print('Calculate c:$c');

  final d = await smartCompute.compute<int, int>(fib, param: null);
  print('Calculate: d:$d');


  await smartCompute.turnOff();
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

Future<EitherInt> eitherAsyncFib(int n) async {
  return Right(await asyncFib(n));
}

Future<int> asyncFib(int n) async {
  await Future<void>.delayed(const Duration(seconds:  2));

  return fib(n);
}

int errorFib(int n) {
  throw Exception('Something went wrong');
}
