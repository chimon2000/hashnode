import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hashnode/core/models/story.dart';

const document = r'''
  query Post($slug: String!, $hostname: String) {
    post(slug: $slug, hostname: $hostname){
      __typename
      author {
        username
        publicationDomain
      }
      slug
      cuid
      title
      brief
      content
      contentMarkdown
      coverImage
      dateAdded
    }
  }
''';

typedef BuilderFn = Widget Function(BuildContext context, Story story,
    {Refetch? refetch});

class StoryDetailQuery extends StatelessWidget {
  final String? slug;
  final String? hostname;
  final BuilderFn builder;

  StoryDetailQuery({
    required this.slug,
    required this.builder,
    this.hostname,
  });

  @override
  Widget build(BuildContext context) {
    var options = QueryOptions(
      document: gql(document),
      variables: {'slug': slug, 'hostname': hostname},
      pollInterval: Duration(seconds: 5),
      fetchPolicy: FetchPolicy.networkOnly,
    );

    return Query(
      options: options,
      builder: (result, {refetch, fetchMore}) {
        if (result.hasException) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: Text(result.exception.toString())),
          );
        }

        if (result.isLoading) {
          return Center(child: CircularProgressIndicator());
        }
        final Object post = result.data!['post'];

        final story = Story.fromJson(post as Map<String, dynamic>);

        return builder(context, story, refetch: refetch);
      },
    );
  }
}
