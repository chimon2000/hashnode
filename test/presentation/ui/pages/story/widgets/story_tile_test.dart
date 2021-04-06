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

  group('StoryTile', () {
    testWidgets('smoke test', (WidgetTester tester) async {
      final expectedStory = stories[0];
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        TesterWrapper(
          providers: [ChangeNotifierProvider.value(value: Settings())],
          child: StoryTile(
            story: stories[0],
            onStoryTap: (story) {
              actualStory = story;
            },
          ),
        ),
      );

      expect(find.text(expectedStory.title!), findsOneWidget);

      await tester.tap(find.byKey(ValueKey(expectedStory.cuid)));

      await tester.pump();

      expect(actualStory, expectedStory);
    });
  });
}
