import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hashnode/core/models/story.dart';
import 'package:hashnode/core/providers/settings.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

const query = r'''
  query Stories($type: FeedType!, $currentPage: Int, $nextPage: Int) {
    current: storiesFeed(type: $type, page: $currentPage){
      __typename
      id: cuid
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
    next: storiesFeed(type: $type, page: $nextPage){
      __typename
      id: cuid
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
''';

const storyTypeMap = {
  StoryListType.featured: 'FEATURED',
  StoryListType.recent: 'RECENT',
  StoryListType.trending: 'GLOBAL'
};

enum StoryListType { featured, recent, trending }

typedef BuilderFn = Widget Function(BuildContext context, List<Story> stories,
    {RefetchFn refetch, Function(FetchMoreOptions) fetchMore});

typedef RefetchFn = bool Function();

class StoryQuery extends StatelessWidget {
  final BuilderFn builder;
  final StoryListType listType;

  StoryQuery({
    @required this.builder,
    @required this.listType,
  });

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: query,
        variables: {
          'type': storyTypeMap[listType],
          'currentPage': 0,
          'nextPage': 1
        },
        pollInterval: 2000,
      ),
      builder: (result, {refetch, fetchMore}) {
        if (result.errors != null) {
          return Text(result.errors.toString());
        }

        if (result.loading && result.data == null) {
          return Center(child: CircularProgressIndicator());
        }

        final List<Object> storiesFeed = [
          ...result.data['current'],
          ...result.data['next']
        ];

        final stories =
            storiesFeed.map((story) => Story.fromJson(story)).toList();

        return builder(
          context,
          stories,
          refetch: refetch,
          fetchMore: fetchMore,
        );
      },
    );
  }
}

typedef OnStoryTapFn = void Function(Story story);

class StoryList extends StatelessWidget {
  final List<Story> stories;
  final OnStoryTapFn onStoryTap;
  final bool isFetchingMore;
  final VoidCallback onFetchMore;

  StoryList(
      {@required this.stories,
      @required this.onStoryTap,
      this.isFetchingMore = false,
      this.onFetchMore});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(8.0),
      children: [
        ...stories
            .map((story) => Container(
                    child: StoryTile(
                  story: story,
                  onStoryTap: onStoryTap,
                )))
            .toList(),
        Center(
          child: FlatButton(
            child: Text('Load more...'),
            onPressed: isFetchingMore ? null : onFetchMore,
          ),
        )
      ],
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
