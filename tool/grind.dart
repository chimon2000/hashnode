import 'dart:async';

import 'package:grinder/grinder.dart';

main(args) => grind(args);

@Task('run tests')
Future<void> test() async {
  final args = context.invocation.arguments;
  final genCoverage = args.getFlag('coverage');
  await runTests(genCoverage);
}

@Task('generate coverage report')
Future<void> coverage() async {
  await runTests(true);
  await runAsync('lcov', arguments: [
    '--remove',
    'coverage/lcov.info',
    'lib/main.dart',
    '-o',
    'coverage/lcov.info'
  ]);
}

Future<void> runTests([bool genCoverage = false]) =>
    runAsync('flutter', arguments: ['test', if (genCoverage) '--coverage']);
