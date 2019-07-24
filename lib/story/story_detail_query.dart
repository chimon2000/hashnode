import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hashnode/story/story.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:html2md/html2md.dart' as html2md;

const query = r'''
  query Post($cuid: String!) {
    post(cuid: $cuid){
      title,
      brief,
      content,
      contentMarkdown,
      coverImage,
      dateAdded
    }
  }
''';

class StoryDetailQuery extends StatelessWidget {
  final String cuid;
  StoryDetailQuery({@required this.cuid});

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: query,
        variables: {'cuid': cuid},
      ),
      builder: (result, {refetch}) {
        if (result.errors != null) {
          return Text(result.errors.toString());
        }

        if (result.loading) {
          return Center(child: CircularProgressIndicator());
        }
        final Object post = result.data['post'];

        final story = Story.fromJson(post);

        return StoryDetail(story: story);
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

    final content = MarkdownBody(
      data: markdown,
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
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 16.0,
            ),
            child: Text(
              '${story.title}',
              style: textTheme.headline,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
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
