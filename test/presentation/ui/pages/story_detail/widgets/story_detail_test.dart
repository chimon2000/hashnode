import 'package:flutter_test/flutter_test.dart';
import 'package:hashnode/core/models/story.dart';
import 'package:hashnode/core/providers/settings.dart';

import 'package:hashnode/presentation/ui/pages/story_detail/widgets/widgets.dart';
import 'package:provider/provider.dart';

import '../../../../../util/util.dart';

void main() {
  group('StoryTile', () {
    testWidgets('smoke test', (WidgetTester tester) async {
      final expectedStory = stories[0];
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        TestWrapper(
          providers: [ChangeNotifierProvider.value(value: Settings())],
          child: StoryDetail(
            story: stories[0],
          ),
        ),
      );

      expect(find.text(expectedStory.title!), findsOneWidget);
    });
  });
}
