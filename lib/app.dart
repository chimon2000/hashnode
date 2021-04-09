import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hashnode/core/providers/client_provider.dart';
import 'package:hashnode/core/providers/settings.dart';
import 'package:hashnode/presentation/ui/pages/home/home.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

final String apiUri = 'https://api.hashnode.com';

class HashnodeApp extends StatelessWidget {
  HashnodeApp({
    Key? key,
    this.providers = const [],
  }) : super(key: key);

  final List<SingleChildWidget> providers;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: Builder(
        builder: (context) {
          final settings = context.watch<Settings>();
          final graphQLClient = context.watch<GraphQLClient>();

          final themeData = settings.theme == AppTheme.light
              ? ThemeData(
                  brightness: Brightness.light,
                  primaryColor: Colors.white,
                  scaffoldBackgroundColor: Colors.white,
                )
              : ThemeData(brightness: Brightness.dark);

          return ClientProvider(
            client: graphQLClient,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: themeData,
              home: HomePage(title: 'Hashnode'),
            ),
          );
        },
      ),
    );
  }
}
