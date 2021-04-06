import 'package:flutter/material.dart';
import 'package:hashnode/ui/pages/story/story_page.dart';
import 'package:hashnode/ui/pages/story/story_query.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key, this.title}) : super(key: key);
  final String? title;

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
