import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hashnode/core/models/story.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:html2md/html2md.dart' as html2md;

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
    {Refetch refetch});

class StoryDetailQuery extends StatelessWidget {
  final String slug;
  final String hostname;
  final BuilderFn builder;

  StoryDetailQuery({
    @required this.slug,
    @required this.builder,
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
        final Object post = result.data['post'];

        final story = Story.fromJson(post);

        return builder(context, story, refetch: refetch);
      },
    );
  }
}

class StoryDetail extends StatelessWidget {
  final Story story;
  StoryDetail({
    @required this.story,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    String markdown = html2md.convert(story.content);

    final customMarkdownStyleSheet = MarkdownStyleSheet.fromTheme(theme)
        .copyWith(p: textTheme.bodyText2.copyWith(fontSize: 15));

    final content = MarkdownBody(
      data: markdown,
      styleSheet: customMarkdownStyleSheet,
      onTapLink: (link, _, __) async {
        if (await canLaunch(link)) {
          await launch(link);
        } else {
          throw 'Could not launch $link';
        }
      },
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (story.coverImage != null) Image.network(story.coverImage),
          Padding(
            padding: EdgeInsets.only(top: 16, left: 16, right: 16),
            child: Text(
              '${story.title}',
              style: textTheme.headline5,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 16, left: 16, right: 16),
            child: Text(
              'by ${story.author}',
              style: textTheme.subtitle1,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 16.0,
            ),
            child: content,
          ),
        ],
      ),
    );
  }
}
