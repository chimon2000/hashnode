import 'package:flutter/material.dart';
import 'package:hashnode/core/models/story.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:html2md/html2md.dart' as html2md;

class StoryDetail extends StatelessWidget {
  StoryDetail({
    required this.story,
  });

  final Story story;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final markdown = html2md.convert(story.content!);

    final customMarkdownStyleSheet = MarkdownStyleSheet.fromTheme(theme)
        .copyWith(p: textTheme.bodyText2!.copyWith(fontSize: 15));

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
          if (story.coverImage != null) Image.network(story.coverImage!),
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
