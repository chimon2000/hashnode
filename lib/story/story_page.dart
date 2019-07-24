import 'package:flutter/material.dart';
import 'package:hashnode/providers/settings.dart';
import 'package:hashnode/story/story_detail_page.dart';
import 'package:hashnode/story/story_query.dart';
import 'package:provider/provider.dart';

class StoryPage extends StatelessWidget {
  final StoryListType listType;
  final String listTitle;

  StoryPage({
    this.listType = StoryListType.featured,
    this.listTitle = 'Featured stories',
  });

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<Settings>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(listTitle),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (value) {
              if (value is AppTheme) {
                settings.toggleTheme();
              }

              if (value is DisplayDensity) {
                settings.setDisplayDensity(value);
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
              ];
            },
          )
        ],
        elevation: 0.0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: StoryQuery(
              listType: listType,
              builder: (context, stories) {
                return StoryList(
                  stories: stories,
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
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
