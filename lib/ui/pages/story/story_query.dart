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
        publicationDomain
      }
      slug
      cuid
      title
      brief
      dateAdded
      totalReactions
      responseCount
    }
    next: storiesFeed(type: $type, page: $nextPage){
      __typename
      id: cuid
      author {
        username
        publicationDomain
      }
      slug
      cuid
      title
      brief
      dateAdded
      totalReactions
      responseCount
    }
  }
''';

const storyTypeMap = {
  StoryListType.featured: 'FEATURED',
  StoryListType.recent: 'RECENT',
  StoryListType.trending: 'BEST'
};

enum StoryListType { featured, recent, trending }

typedef BuilderFn = Widget Function(BuildContext context, List<Story> stories,
    {Refetch? refetch, Function(FetchMoreOptions)? fetchMore});

class StoryQuery extends StatelessWidget {
  final BuilderFn builder;
  final StoryListType listType;

  StoryQuery({
    required this.builder,
    required this.listType,
  });

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: gql(query),
        variables: {
          'type': storyTypeMap[listType],
          'currentPage': 0,
          'nextPage': 1
        },
        pollInterval: Duration(seconds: 2),
      ),
      builder: (result, {refetch, fetchMore}) {
        if (result.hasException) {
          return new Center(
              child: Column(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.center,
                  child: new Text(
                    'Could not find stories...',
                    style: new TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ),
              Expanded(
                  flex: 4,
                  child: Container(
                    alignment: Alignment.topCenter,
                    // illustration by Ouch.pics https://icons8.com
                    child: Image.asset('images/mirage-page-not-found.png'),
                  )),
              Expanded(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.topCenter,
                    child:
                        new Text('illustration by Ouch.pics https://icons8.com',
                            style: new TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black45,
                              fontSize: 14.0,
                            )),
                  )),
            ],
          ));
          // return Text('Could not find Stories: \n' + result.errors.toString());

        }

        if (result.isLoading && result.data == null) {
          return Center(child: CircularProgressIndicator());
        }

        final List<Object> storiesFeed = [
          ...result.data!['current'],
          ...result.data!['next']
        ];

        print(storiesFeed[5]);

        final stories =
            storiesFeed.map((story) => Story.fromJson(story as Map<String, dynamic>)).toList();

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
  final VoidCallback? onFetchMore;

  StoryList(
      {required this.stories,
      required this.onStoryTap,
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
          child: TextButton(
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
    required this.story,
    required this.onStoryTap,
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
          story.title!,
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
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  story.brief!,
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
    story.totalReactions!,
    zero: '',
    one: '${story.totalReactions} reaction',
    many: '${story.totalReactions} reactions',
    other: '${story.totalReactions} reactions',
    name: 'reactions',
    args: [story.totalReactions!],
  );

  final comments = Intl.plural(
    story.responseCount!,
    zero: '',
    one: '${story.responseCount} comment',
    many: '${story.responseCount} comments',
    other: '${story.responseCount} comments',
    name: 'comments',
    args: [story.responseCount!],
  );

  final strings = [
    reactions,
    comments,
  ].where((row) => row.isNotEmpty).toList();

  final totals = list(strings);

  return 'by ${story.author} ${story.timeAgo} ${totals.isEmpty ? "" : ", $totals"}';
}

String list([List<String> values = const []]) {
  return '';
}
