import 'package:flutter/material.dart';
import 'package:hashnode/core/models/story.dart';
import 'package:hashnode/core/providers/settings.dart';
import 'package:hashnode/presentation/extensions/extensions.dart';
import 'package:provider/provider.dart';

class StoryTile extends StatelessWidget {
  final Story story;
  final OnStoryTapFn onStoryTap;

  StoryTile({
    Key? key,
    required this.story,
    required this.onStoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final Settings settings = context.watch();

    var tileTitle = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          story.title!,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${story.caption}',
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
      key: ValueKey(story.cuid),
      title: tileTitle,
      subtitle: subTitle,
      contentPadding: EdgeInsets.fromLTRB(8, 0, 16, 8),
      onTap: () => onStoryTap(story),
    );
  }
}

typedef OnStoryTapFn = void Function(Story story);
