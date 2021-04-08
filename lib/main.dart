import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hashnode/app.dart';
import 'package:hashnode/core/providers/client_provider.dart';
import 'package:hashnode/core/providers/settings.dart';
import 'package:hashnode/core/util/config.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future main() async {
  await setupConfig();
  final dsn = env['DSN'];

  final ValueNotifier<GraphQLClient> client = clientFor(
    uri: apiUri,
  );

  await SentryFlutter.init(
    (options) => options.dsn = dsn,
    appRunner: () => runApp(HashnodeApp(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Settings(),
        ),
        ValueListenableProvider.value(value: client),
      ],
    )),
  );
}
