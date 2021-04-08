import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hashnode/core/models/story.dart';
import 'package:hashnode/presentation/ui/widgets/graphql_query_builder.dart';

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

typedef BuilderFn = Widget Function(
  BuildContext context,
  Story story, {
  Refetch? refetch,
  Function(FetchMoreOptions)? fetchMore,
});

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
      // pollInterval: Duration(seconds: 5),
      fetchPolicy: FetchPolicy.networkOnly,
    );

    return GraphQLQueryBuilder(
      options: options,
      builder: builder,
      errorBuilder: (_, result) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              result.exception.toString(),
              key: errorTextKey,
            ),
          ),
        );
      },
      loadingBuilder: (_, __) => Center(child: CircularProgressIndicator()),
      serializer: (data) => Story.fromJson(data!['post']),
    );
  }

  @visibleForTesting
  static const errorTextKey = ValueKey('story_detail_query_error_text_key');
}
