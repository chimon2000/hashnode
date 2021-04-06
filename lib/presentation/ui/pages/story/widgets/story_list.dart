import 'package:flutter/material.dart';
import 'package:hashnode/core/models/story.dart';
import 'package:hashnode/presentation/ui/pages/story/widgets/story_title.dart';

class StoryList extends StatelessWidget {
  final List<Story> stories;
  final OnStoryTapFn onStoryTap;
  final bool isFetchingMore;
  final VoidCallback? onFetchMore;

  StoryList({
    required this.stories,
    required this.onStoryTap,
    this.isFetchingMore = false,
    this.onFetchMore,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(8.0),
      children: [
        ...stories
            .map(
              (story) => Container(
                child: StoryTile(
                  story: story,
                  onStoryTap: onStoryTap,
                ),
              ),
            )
            .toList(),
        Center(
          child: TextButton(
            key: storyListFetchButtonKey,
            child: Text('Load more...'),
            onPressed: isFetchingMore ? null : onFetchMore,
          ),
        )
      ],
    );
  }

  @visibleForTesting
  static const storyListFetchButtonKey = ValueKey('storyListFetchButton');
}
