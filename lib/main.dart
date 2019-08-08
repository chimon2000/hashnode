import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hashnode/app.dart';
import 'package:hashnode/util/config.dart';
import 'package:catcher/catcher_plugin.dart';
import 'dart:async';

Future main() async {
  await setupConfig();
  final dns = DotEnv().env['DNS'];
  final sentryHandler = SentryHandler(dns);
  final consoleHandler = ConsoleHandler();

  CatcherOptions debugOptions =
      CatcherOptions(SilentReportMode(), [consoleHandler]);

  CatcherOptions releaseOptions =
      CatcherOptions(DialogReportMode(), [sentryHandler]);

  Catcher(MyApp(), debugConfig: debugOptions, releaseConfig: releaseOptions);
}
