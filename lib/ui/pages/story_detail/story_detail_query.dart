import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hashnode/core/models/story.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:html2md/html2md.dart' as html2md;

const document = r'''
  query Post($cuid: String!) {
    post(cuid: $cuid){
      __typename
      id: cuid
      author {
        username
      }
      title,
      brief,
      content,
      contentMarkdown,
      coverImage,
      dateAdded
    }
  }
''';

typedef BuilderFn = Widget Function(BuildContext context, Story story,
    {RefetchFn refetch});
typedef RefetchFn = bool Function();

class StoryDetailQuery extends StatelessWidget {
  final String cuid;
  final BuilderFn builder;

  StoryDetailQuery({
    @required this.cuid,
    @required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: document,
        variables: {'cuid': cuid},
        pollInterval: 5000,
      ),
      builder: (result, {refetch, fetchMore}) {
        if (result.errors != null) {
          return Text(result.errors.toString());
        }

        if (result.loading) {
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

    final customMarkdownStyleSheet = MarkdownStyleSheet
        .fromTheme(theme)
        .copyWith(p: textTheme.body1.copyWith(fontSize: 15));

    final content = MarkdownBody(
      data: markdown,
      styleSheet: customMarkdownStyleSheet,
      onTapLink: (link) async {
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
              style: textTheme.headline,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 16, left: 16, right: 16),
            child: Text(
              'by ${story.author}',
              style: textTheme.subhead,
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
