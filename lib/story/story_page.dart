import 'package:flutter/material.dart';
import 'package:hashnode/about/about_page.dart';
import 'package:hashnode/providers/settings.dart';
import 'package:hashnode/story/story_detail_page.dart';
import 'package:hashnode/story/story_query.dart';
import 'package:provider/provider.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class StoryPage extends StatefulWidget {
  final StoryListType listType;
  final String listTitle;

  StoryPage({
    this.listType = StoryListType.featured,
    this.listTitle = 'Featured stories',
  });

  @override
  _StoryPageState createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  bool isFetchingMore = false;

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
                      final options = buildFetchMoreOpts(page: 1);
                      setState(() {
                        isFetchingMore = true;
                      });

                      await fetchMore(options);

                      setState(() {
                        isFetchingMore = false;
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

FetchMoreOptions buildFetchMoreOpts({page = 1}) {
  FetchMoreOptions options = FetchMoreOptions(
    variables: {'page': page},
    updateQuery: (previousResultData, fetchMoreResultData) {
      final List<Object> repos = [
        ...previousResultData.data['storiesFeed'] as List<Object>,
        ...fetchMoreResultData.data['storiesFeed'] as List<Object>
      ];

      fetchMoreResultData['storiesFeed'] = repos;

      return fetchMoreResultData;
    },
  );

  return options;
}
