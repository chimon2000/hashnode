import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hashnode/story/story.dart';

const queries = {
  StoryListType.featured: '''
    {
      featuredStories {
        cuid,
        title,
        brief,
        dateAdded
      }
    }
  ''',
  StoryListType.recent: '''
    {
      recentStories {
        cuid,
        title,
        brief,
        dateAdded
      }
    }
  ''',
  StoryListType.trending: '''
    {
      trendingStories {
        cuid,
        title,
        brief,
        dateAdded
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

    var tileTitle = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          story.title,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          story.timeAgo,
          style: textTheme.caption,
        ),
      ],
    );

    final subTitle = Container(
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
    );

    return ListTile(
      title: tileTitle,
      subtitle: subTitle,
      onTap: () {
        onStoryTap(story);
      },
    );
  }
}
