import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hashnode/story/story.dart';

const query = '''
{
  storiesFeed{
    cuid,
    title,
    brief,
    dateAdded
  }
}
''';

typedef BuilderFn = Widget Function(BuildContext context, List<Story> stories);

class StoryQuery extends StatelessWidget {
  final BuilderFn builder;

  StoryQuery({
    @required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(document: query),
      builder: (result, {refetch}) {
        if (result.errors != null) {
          return Text(result.errors.toString());
        }

        if (result.loading) {
          return Center(child: CircularProgressIndicator());
        }
        final List<Object> storiesFeed = result.data['storiesFeed'];

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
        Text(story.title),
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
          Text(story.brief),
        ],
      ),
    );

    return ListTile(
      // dense: true,
      title: tileTitle,
      subtitle: subTitle,
      onTap: () {
        onStoryTap(story);
      },
    );
  }
}
