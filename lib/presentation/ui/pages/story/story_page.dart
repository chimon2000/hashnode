import 'package:flutter/material.dart';
import 'package:hashnode/core/providers/settings.dart';
import 'package:hashnode/presentation/ui/pages/about/about_page.dart';
import 'package:hashnode/presentation/ui/pages/story/story_query.dart';
import 'package:hashnode/presentation/ui/pages/story/widgets/widgets.dart';
import 'package:hashnode/presentation/ui/pages/story_detail/story_detail_page.dart';
import 'package:provider/provider.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class StoryPage extends StatefulWidget {
  final StoryListType listType;
  final String listTitle;

  StoryPage({
    Key? key,
    this.listType = StoryListType.featured,
    this.listTitle = 'Featured stories',
  }) : super(key: key);

  @override
  _StoryPageState createState() => _StoryPageState();

  @visibleForTesting
  static const refreshIndicatorKey =
      ValueKey('story_page_refresh_indicator_key');
}

class _StoryPageState extends State<StoryPage> {
  bool isFetchingMore = false;
  int nextPage = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StoryPageHeader(title: widget.listTitle),
      body: StoryQuery(
        listType: widget.listType,
        builder: (context, stories, {refetch, fetchMore}) {
          return RefreshIndicator(
            key: StoryPage.refreshIndicatorKey,
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

                      await fetchMore!(options);

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
                              slug: story.slug,
                              hostname: story.hostname,
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
  FetchMoreOptions options = FetchMoreOptions.partial(
    variables: {'currentPage': page, 'nextPage': page + 1},
    updateQuery: (previousResultData, fetchMoreResultData) {
      final List<Object> currentPage = [
        ...previousResultData!['current'],
        ...previousResultData['next'],
      ];
      final List<Object> nextPage = [
        ...fetchMoreResultData!['current'],
        ...fetchMoreResultData['next'],
      ];

      fetchMoreResultData['current'] = currentPage;
      fetchMoreResultData['next'] = nextPage;

      return fetchMoreResultData;
    },
  );

  return options;
}

@visibleForTesting
class StoryPageHeader extends StatelessWidget implements PreferredSizeWidget {
  const StoryPageHeader({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: Consumer<Settings>(
        builder: (context, settings, _) {
          return IconButton(
            key: themeButtonKey,
            icon: Image(
              image: settings.theme == AppTheme.dark
                  ? AssetImage('images/hashnode_light_32.png')
                  : AssetImage('images/hashnode_dark_32.png'),
            ),
            onPressed: () => settings.toggleTheme(),
          );
        },
      ),
      actions: <Widget>[SettingsMenuButton()],
      elevation: 0.0,
    );
  }

  @visibleForTesting
  static const themeButtonKey = ValueKey('story_list_header_theme_button_key');
}

@visibleForTesting
class SettingsMenuButton extends StatelessWidget {
  const SettingsMenuButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      onSelected: (dynamic value) {
        if (value is AppTheme) {
          context.read<Settings>().toggleTheme();
        }

        if (value is DisplayDensity) {
          context.read<Settings>().setDisplayDensity(value);
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
        final settings = context.read<Settings>();
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
            key: themeButtonKey,
            value: settings.theme,
            child: Text(themeText),
          ),
          PopupMenuItem<DisplayDensity>(
            key: displayButtonKey,
            value: isDisplayComfortable
                ? DisplayDensity.compact
                : DisplayDensity.comfortable,
            child: Text(displayDensityText),
          ),
          PopupMenuItem<String>(
            key: aboutButtonKey,
            value: 'about',
            child: Text('About'),
          ),
        ];
      },
    );
  }

  @visibleForTesting
  static const themeButtonKey = ValueKey('settings_theme_button_key');

  @visibleForTesting
  static const displayButtonKey = ValueKey('settings_display_button_key');

  @visibleForTesting
  static const aboutButtonKey = ValueKey('settings_about_button_key');
}
