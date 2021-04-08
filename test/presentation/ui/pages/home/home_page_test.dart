import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hashnode/presentation/ui/pages/home/home.dart';
import 'package:hashnode/presentation/ui/pages/story/story_page.dart';
import 'package:hashnode/presentation/ui/pages/story/widgets/widgets.dart';
import '../../../../util/query_mocker.dart';
import '../../../../util/response.dart';
import '../../../../util/util.dart';

void main() {
  group('HomePage', () {
    testWidgets('smoke test', (WidgetTester tester) async {
      final expected = stories.take(2).toList();
      final expectedMapList = expected
          .map((e) => {
                '__typename': 'Post',
                'id': e.cuid,
                ...e.toMap(),
                'author': {
                  '__typename': 'Author',
                  ...e.toMap()['author'],
                },
              })
          .toList();
      final mockedResult = <String, dynamic>{
        'data': {
          '__typename': 'data',
          "current": [expectedMapList[0]],
          'next': [expectedMapList[1]],
        }
      };
      await tester.pumpWidget(
        QueryMocker(
          mockedResponse: buildGoodResponse(mockedResult),
          child: TesterWrapper(
            child: HomePage(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.byKey(StoryPage.refreshIndicatorKey), findsOneWidget);
      expect(find.byKey(StoryList.storyListFetchButtonKey), findsOneWidget);
      expect(find.byKey(ValueKey(expected[0].cuid)), findsOneWidget);

      await tester.tap(find.byKey(StoryList.storyListFetchButtonKey));

      await tester.pumpAndSettle();

      await tester.tap(find.byKey(StoryPageHeader.themeButtonKey));

      await tester.pumpAndSettle();
    });
  });
}
