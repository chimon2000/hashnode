import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hashnode/core/models/story.dart';
import 'package:hashnode/presentation/ui/widgets/graphql_query_builder.dart';

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

typedef BuilderFn = Widget Function(
  BuildContext context,
  List<Story> stories, {
  Refetch? refetch,
  Function(FetchMoreOptions)? fetchMore,
});

class StoryQuery extends StatelessWidget {
  final BuilderFn builder;
  final StoryListType listType;

  StoryQuery({
    required this.builder,
    required this.listType,
  });

  @override
  Widget build(BuildContext context) {
    final options = QueryOptions(
      fetchPolicy: FetchPolicy.cacheAndNetwork,
      document: gql(query),
      variables: {
        'type': storyTypeMap[listType],
        'currentPage': 0,
        'nextPage': 1
      },
    );

    return GraphQLQueryBuilder(
      options: options,
      builder: builder,
      errorBuilder: (_, result) => _Error(key: errorTextKey),
      loadingBuilder: (_, __) => Center(child: CircularProgressIndicator()),
      serializer: (data) {
        final List<Object> storiesFeed = [...data!['current'], ...data['next']];

        final stories = storiesFeed
            .map((story) => Story.fromJson(story as Map<String, dynamic>))
            .toList();

        return stories;
      },
    );
  }

  @visibleForTesting
  static const errorTextKey = ValueKey('story_list_query_error_text_key');
}

class _Error extends StatelessWidget {
  const _Error({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                'Could not find stories...',
                style: TextStyle(
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
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.topCenter,
              child: Text(
                'illustration by Ouch.pics https://icons8.com',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black45,
                  fontSize: 14.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
