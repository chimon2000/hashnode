import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hashnode/core/models/story.dart';
import 'package:hashnode/core/providers/settings.dart';
import 'package:hashnode/presentation/ui/pages/story/widgets/widgets.dart';
import 'package:provider/provider.dart';

import '../../../../../util/util.dart';

void main() {
  Story? actualStory;

  tearDown(() {
    actualStory = null;
  });

  group('StoryList', () {
    testWidgets('smoke test', (WidgetTester tester) async {
      final expectedStory = stories[0];
      var fetchMore = false;
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        TestWrapper(
          providers: [ChangeNotifierProvider.value(value: Settings())],
          child: StoryList(
            stories: stories,
            onStoryTap: (story) {
              actualStory = story;
            },
            onFetchMore: () {
              fetchMore = true;
            },
          ),
        ),
      );

      expect(find.text(expectedStory.title!), findsOneWidget);

      await tester.tap(find.byKey(ValueKey(expectedStory.cuid)));

      await tester.pump();

      expect(actualStory, expectedStory);

      await tester.tap(find.byKey(StoryList.storyListFetchButtonKey));

      expect(fetchMore, true);
    });
  });
}
