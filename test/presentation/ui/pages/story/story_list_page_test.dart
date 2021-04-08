import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hashnode/presentation/ui/pages/story/story_page.dart';
import 'package:hashnode/presentation/ui/pages/story/story_query.dart';
import 'package:hashnode/presentation/ui/pages/story/widgets/widgets.dart';
import '../../../../util/query_mocker.dart';
import '../../../../util/response.dart';
import '../../../../util/util.dart';

void main() {
  group('StoryPage', () {
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
            child: StoryPage(),
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
    testWidgets('refresh', (WidgetTester tester) async {
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
            child: StoryPage(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.byKey(StoryPage.refreshIndicatorKey), findsOneWidget);
      expect(find.byKey(StoryList.storyListFetchButtonKey), findsOneWidget);
      expect(find.byKey(ValueKey(expected[0].cuid)), findsOneWidget);

      await tester.fling(
          find.byKey(ValueKey(expected[0].cuid)), Offset(0, 300), 1000);
      await tester.pumpAndSettle();
    });

    testWidgets('navigates to detail', (WidgetTester tester) async {
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
            child: StoryPage(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.byKey(ValueKey(expected[0].cuid)), findsOneWidget);

      await tester.tap(find.byKey(ValueKey(expected[0].cuid)));

      await tester.pump();
    });
    testWidgets('error', (WidgetTester tester) async {
      final expected = stories.take(1).toList();
      final expectedMapList = expected
          .map((e) => {
                '__typename': 'Post',
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
          "current": expectedMapList,
          'next': expectedMapList,
        }
      };

      await tester.pumpWidget(
        QueryMocker(
          mockedResponse: buildGoodResponse(mockedResult),
          child: TesterWrapper(
            child: StoryPage(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.byKey(StoryQuery.errorTextKey), findsOneWidget);
    });
  });

  group('SettingsMenuButton', () {
    testWidgets('smoke screen', (tester) async {
      final key = ValueKey('testButton');
      await tester.pumpWidget(
        TesterWrapper(
          child: SettingsMenuButton(
            key: key,
          ),
        ),
      );
      expect(find.byKey(SettingsMenuButton.themeButtonKey), findsNothing);
      expect(find.byKey(SettingsMenuButton.displayButtonKey), findsNothing);
      expect(find.byKey(SettingsMenuButton.aboutButtonKey), findsNothing);

      await tester.tap(find.byKey(key));

      await tester.pumpAndSettle();

      expect(find.byKey(SettingsMenuButton.themeButtonKey), findsOneWidget);
      expect(find.byKey(SettingsMenuButton.displayButtonKey), findsOneWidget);
      expect(find.byKey(SettingsMenuButton.aboutButtonKey), findsOneWidget);

      await tester.tap(find.byKey(SettingsMenuButton.themeButtonKey));

      await tester.pumpAndSettle();

      expect(find.byKey(SettingsMenuButton.themeButtonKey), findsNothing);
      expect(find.byKey(SettingsMenuButton.displayButtonKey), findsNothing);
      expect(find.byKey(SettingsMenuButton.aboutButtonKey), findsNothing);

      await tester.tap(find.byKey(key));

      await tester.pumpAndSettle();

      expect(find.byKey(SettingsMenuButton.themeButtonKey), findsOneWidget);
      expect(find.byKey(SettingsMenuButton.displayButtonKey), findsOneWidget);
      expect(find.byKey(SettingsMenuButton.aboutButtonKey), findsOneWidget);

      await tester.tap(find.byKey(SettingsMenuButton.displayButtonKey));

      await tester.pumpAndSettle();

      expect(find.byKey(SettingsMenuButton.themeButtonKey), findsNothing);
      expect(find.byKey(SettingsMenuButton.displayButtonKey), findsNothing);
      expect(find.byKey(SettingsMenuButton.aboutButtonKey), findsNothing);

      await tester.tap(find.byKey(key));

      await tester.pumpAndSettle();

      expect(find.byKey(SettingsMenuButton.themeButtonKey), findsOneWidget);
      expect(find.byKey(SettingsMenuButton.displayButtonKey), findsOneWidget);
      expect(find.byKey(SettingsMenuButton.aboutButtonKey), findsOneWidget);

      await tester.tap(find.byKey(SettingsMenuButton.aboutButtonKey));

      await tester.pumpAndSettle();

      expect(find.byKey(SettingsMenuButton.themeButtonKey), findsNothing);
      expect(find.byKey(SettingsMenuButton.displayButtonKey), findsNothing);
      expect(find.byKey(SettingsMenuButton.aboutButtonKey), findsNothing);
    });
  });
}
