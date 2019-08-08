import 'package:flutter/material.dart';
import 'package:hashnode/core/providers/settings.dart';
import 'package:hashnode/ui/pages/about/about_page.dart';
import 'package:hashnode/ui/pages/story/story_query.dart';
import 'package:hashnode/ui/pages/story_detail/story_detail_page.dart';
import 'package:provider/provider.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class StoryPage extends StatefulWidget {
  final StoryListType listType;
  final String listTitle;

  StoryPage({
    Key key,
    this.listType = StoryListType.featured,
    this.listTitle = 'Featured stories',
  }) : super(key: key);

  @override
  _StoryPageState createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  bool isFetchingMore = false;
  int nextPage = 2;

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<Settings>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listTitle),
        leading: Consumer<Settings>(
          builder: (context, settings, _) {
            return IconButton(
              icon: Image(
                image: settings.theme == AppTheme.dark
                    ? AssetImage('images/hashnode_light_32.png')
                    : AssetImage('images/hashnode_dark_32.png'),
              ),
              onPressed: () => settings.toggleTheme(),
            );
          },
        ),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (value) {
              if (value is AppTheme) {
                settings.toggleTheme();
              }

              if (value is DisplayDensity) {
                settings.setDisplayDensity(value);
              }

              if (value == 'about') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return AboutPage();
                    },
                  ),
                );
              }
            },
            itemBuilder: (context) {
              final settings = Provider.of<Settings>(context);
              final themeText = settings.theme == AppTheme.dark
                  ? "Disable dark mode"
                  : "Enable dark mode";

              final displayDensity = settings.displayDensity;
              final isDisplayComfortable =
                  displayDensity == DisplayDensity.comfortable;
              final displayDensityText = isDisplayComfortable
                  ? 'Enable compact mode'
                  : 'Disable compact mode';

              return [
                PopupMenuItem<AppTheme>(
                  value: settings.theme,
                  child: Text(themeText),
                ),
                PopupMenuItem<DisplayDensity>(
                  value: isDisplayComfortable
                      ? DisplayDensity.compact
                      : DisplayDensity.comfortable,
                  child: Text(displayDensityText),
                ),
                PopupMenuItem<String>(
                  value: 'about',
                  child: Text('About'),
                ),
              ];
            },
          )
        ],
        elevation: 0.0,
      ),
      body: StoryQuery(
        listType: widget.listType,
        builder: (context, stories, {refetch, fetchMore}) {
          return RefreshIndicator(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: StoryList(
                    stories: stories,
                    isFetchingMore: isFetchingMore,
                    onFetchMore: () async {
                      final options = buildFetchMoreOpts(page: nextPage);
                      setState(() {
                        isFetchingMore = true;
                      });

                      await fetchMore(options);

                      setState(() {
                        isFetchingMore = false;
                        nextPage = nextPage + 2;
                      });
                    },
                    onStoryTap: (story) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return StoryDetailPage(
                              cuid: story.cuid,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            onRefresh: () async =>
                Future.delayed(Duration(seconds: 1), refetch),
          );
        },
      ),
    );
  }
}

FetchMoreOptions buildFetchMoreOpts({page = 2}) {
  FetchMoreOptions options = FetchMoreOptions(
    variables: {'currentPage': page, 'nextPage': page + 1},
    updateQuery: (previousResultData, fetchMoreResultData) {
      final List<Object> currentPage = [
        ...previousResultData.data['current'] as List<Object>,
        ...previousResultData.data['next'] as List<Object>,
      ];
      final List<Object> nextPage = [
        ...fetchMoreResultData.data['current'] as List<Object>,
        ...fetchMoreResultData.data['next'] as List<Object>,
      ];

      fetchMoreResultData['current'] = currentPage;
      fetchMoreResultData['next'] = nextPage;

      return fetchMoreResultData;
    },
  );

  return options;
}
