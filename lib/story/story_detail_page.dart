import 'package:flutter/material.dart';
import 'package:hashnode/story/story_detail_query.dart';

class StoryDetailPage extends StatelessWidget {
  final String cuid;
  StoryDetailPage({@required this.cuid});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return StoryDetailQuery(
      cuid: cuid,
    );
  }
}
