import 'package:flutter/material.dart';
import 'package:hashnode/providers/client_provider.dart';
import 'package:hashnode/providers/settings.dart';
import 'package:hashnode/story/story_page.dart';
import 'package:hashnode/story/story_query.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

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

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    final pageView = PageView(
      controller: controller,
      scrollDirection: Axis.horizontal,
      children: <Widget>[
        StoryPage(
          listType: StoryListType.trending,
          listTitle: 'Top stories',
        ),
        StoryPage(),
        StoryPage(
          listType: StoryListType.recent,
          listTitle: 'Recent stories',
        ),
      ],
    );

    return pageView;
  }
}
