import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hashnode/core/models/story.dart';
import 'package:hashnode/presentation/ui/pages/story/story_query.dart';
import 'package:hashnode/presentation/ui/pages/story_detail/story_detail_query.dart';
import '../../../../util/query_mocker.dart';
import '../../../../util/response.dart';
import '../../../../util/util.dart';

void main() {
  List<Story>? actualStories;

  tearDown(() {
    actualStories = null;
  });

  group('StoryListQuery', () {
    testWidgets('smoke test', (WidgetTester tester) async {
      final expected = stories.take(1).toList();
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
          "current": expectedMapList,
          'next': expectedMapList,
        }
      };

      final containerKey = ValueKey('containerKey');
      await tester.pumpWidget(
        TestWrapper(
          child: QueryMocker(
            mockedResponse: buildGoodResponse(mockedResult),
            child: StoryQuery(
              listType: StoryListType.featured,
              builder: (context, stories, {refetch, fetchMore}) {
                actualStories = stories;
                return Container(key: containerKey);
              },
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.byKey(containerKey), findsOneWidget);

      expect(actualStories![0].cuid, expected[0].cuid);
      expect(actualStories![0].slug, expected[0].slug);
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

      final containerKey = ValueKey('containerKey');
      await tester.pumpWidget(
        TestWrapper(
          child: QueryMocker(
            mockedResponse: buildGoodResponse(mockedResult),
            child: StoryQuery(
              listType: StoryListType.featured,
              builder: (context, stories, {refetch, fetchMore}) {
                actualStories = stories;
                return Container(key: containerKey);
              },
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.byKey(StoryQuery.errorTextKey), findsOneWidget);
    });
  });
}
