import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hashnode/presentation/ui/pages/story/story_page.dart';
import 'package:hashnode/presentation/ui/pages/story/story_query.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';

class HomePage extends StatefulWidget {
  HomePage({
    Key? key,
    this.title,
    this.initial = 'trending',
    this.slug,
    this.hostname,
  }) : super(key: key);

  final String? title;
  final String initial;
  final String? slug;
  final String? hostname;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final controller = PageController(initialPage: _pageFromRoute);

  @override
  Widget build(BuildContext context) {
    final deviceType = getDeviceType(MediaQuery.of(context).size);

    print(MediaQuery.of(context).viewInsets.top);
    print(MediaQuery.of(context).padding.top);
    return Provider.value(
      value: deviceType,
      child: PageView(
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
      ),
    );
  }

  int get _pageFromRoute {
    final value = StoryListType.values
        .singleWhere((element) => describeEnum(element) == widget.initial);

    switch (value) {
      case StoryListType.trending:
        return 0;
      case StoryListType.featured:
        return 1;
      case StoryListType.recent:
        return 2;
      default:
        return 0;
    }
  }
}
