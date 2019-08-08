import 'package:flutter/material.dart';
import 'package:hashnode/pages/home/home.dart';
import 'package:hashnode/providers/client_provider.dart';
import 'package:hashnode/providers/settings.dart';
import 'package:provider/provider.dart';

final String apiUri = 'https://api.hashnode.com';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          builder: (_) => Settings(),
        ),
      ],
      child: Consumer<Settings>(
        builder: (context, settings, _) {
          return ClientProvider(
            uri: apiUri,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: settings.theme == AppTheme.light
                  ? ThemeData(
                      brightness: Brightness.light,
                      primaryColor: Colors.white,
                      scaffoldBackgroundColor: Colors.white,
                    )
                  : ThemeData(
                      brightness: Brightness.dark,
                    ),
              home: HomePage(title: 'Hashnode'),
            ),
          );
        },
      ),
    );
  }
}
