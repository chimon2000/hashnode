import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hashnode/app.dart';
import 'package:hashnode/core/util/config.dart';
import 'package:catcher/catcher_plugin.dart';

Future main() async {
  await setupConfig();
  final dsn = DotEnv().env['DSN'];

  final sentryHandler = SentryHandler(dsn);
  final consoleHandler = ConsoleHandler();

  CatcherOptions debugOptions =
      CatcherOptions(SilentReportMode(), [consoleHandler]);

  CatcherOptions releaseOptions =
      CatcherOptions(DialogReportMode(), [sentryHandler]);

  Catcher(MyApp(), debugConfig: debugOptions, releaseConfig: releaseOptions);
}
