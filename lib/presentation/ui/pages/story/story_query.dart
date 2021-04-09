import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hashnode/core/models/story.dart';

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

        final stories = storiesFeed
            .map((story) => Story.fromJson(story as Map<String, dynamic>))
            .toList();

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
