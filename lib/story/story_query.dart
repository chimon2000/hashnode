import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hashnode/providers/settings.dart';
import 'package:hashnode/story/story.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

const queries = {
  StoryListType.featured: '''
    {
      featuredStories {
        author {
          username
        }
        cuid,
        title,
        brief,
        dateAdded,
        totalReactions,
        responseCount
      }
    }
  ''',
  StoryListType.recent: '''
    {
      recentStories {
        author {
          username
        }
        cuid,
        title,
        brief,
        dateAdded,
        totalReactions,
        responseCount
      }
    }
  ''',
  StoryListType.trending: '''
    {
      trendingStories {
        author {
          username
        }
        cuid,
        title,
        brief,
        dateAdded,
        totalReactions,
        responseCount
      }
    }
  '''
};

enum StoryListType { featured, recent, trending }

typedef BuilderFn = Widget Function(BuildContext context, List<Story> stories);

class StoryQuery extends StatelessWidget {
  final BuilderFn builder;
  final StoryListType listType;

  StoryQuery({
    @required this.builder,
    @required this.listType,
  });

  @override
  Widget build(BuildContext context) {
    final query = queries[listType];
    return Query(
      options: QueryOptions(document: query),
      builder: (result, {refetch}) {
        if (result.errors != null) {
          return Text(result.errors.toString());
        }

        if (result.loading) {
          return Center(child: CircularProgressIndicator());
        }

        final typeKey = listType == StoryListType.featured
            ? 'featured'
            : listType == StoryListType.recent ? 'recent' : 'trending';

        final List<Object> storiesFeed = result.data['${typeKey}Stories'];

        final stories =
            storiesFeed.map((story) => Story.fromJson(story)).toList();

        return builder(context, stories);
      },
    );
  }
}

typedef OnStoryTapFn = void Function(Story story);

class StoryList extends StatelessWidget {
  final List<Story> stories;
  final OnStoryTapFn onStoryTap;

  StoryList({
    @required this.stories,
    @required this.onStoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(8.0),
      children: stories
          .map((story) => Container(
                  child: StoryTile(
                story: story,
                onStoryTap: onStoryTap,
              )))
          .toList(),
    );
  }
}

class StoryTile extends StatelessWidget {
  final Story story;
  final OnStoryTapFn onStoryTap;

  StoryTile({
    @required this.story,
    @required this.onStoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final settings = Provider.of<Settings>(context);

    var tileTitle = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          story.title,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${determineCaption(story)}',
          style: textTheme.caption,
        ),
      ],
    );

    final subTitle = settings.displayDensity == DisplayDensity.comfortable
        ? Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  story.brief,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )
        : null;

    return ListTile(
      title: tileTitle,
      subtitle: subTitle,
      contentPadding: EdgeInsets.fromLTRB(8, 0, 16, 8),
      onTap: () {
        onStoryTap(story);
      },
    );
  }
}

String determineCaption(Story story) {
  final reactions = Intl.plural(
    story.totalReactions,
    zero: '',
    one: '${story.totalReactions} reaction',
    many: '${story.totalReactions} reactions',
    other: '${story.totalReactions} reactions',
    name: 'reactions',
    args: [story.totalReactions],
  );

  final comments = Intl.plural(
    story.responseCount,
    zero: '',
    one: '${story.responseCount} comment',
    many: '${story.responseCount} comments',
    other: '${story.responseCount} comments',
    name: 'comments',
    args: [story.responseCount],
  );

  final strings = [
    reactions,
    comments,
  ].where((row) => row.isNotEmpty).toList();

  final totals = list(strings);

  return 'by ${story.author} ${story.timeAgo} ${totals.isEmpty ? "" : ", $totals"}';
}

String list(List<String> values) {
  return values.fold('', (String curr, next) {
    final index = values.indexOf(next);
    final total = values.length - 1;
    if (curr.isEmpty) return next;

    return index == total ? '$curr and $next' : '$curr, $next';
  });
}
