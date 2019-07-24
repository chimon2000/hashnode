import 'package:flutter/material.dart';
import 'package:hashnode/client_provider.dart';
import 'package:hashnode/story/story_detail_page.dart';
import 'package:hashnode/story/story_page.dart';

void main() {
  runApp(MyApp());
}

final String apiUri = 'https://api.hashnode.com';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ClientProvider(
      uri: apiUri,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.white,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: HomePage(title: 'Hashnode'),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0.0,
      ),
      body: StoryPage(),
    );
  }
}
