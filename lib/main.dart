import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hashnode/app.dart';
import 'package:hashnode/core/util/config.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future main() async {
  await setupConfig();
  final dsn = env['DSN'];

  await SentryFlutter.init(
    (options) => options.dsn = dsn,
    appRunner: () => runApp(HashnodeApp()),
  );
}
