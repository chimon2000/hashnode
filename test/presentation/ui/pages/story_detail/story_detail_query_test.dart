import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hashnode/core/models/story.dart';
import 'package:hashnode/presentation/ui/pages/story_detail/story_detail_query.dart';
import '../../../../util/query_mocker.dart';
import '../../../../util/response.dart';
import '../../../../util/util.dart';

void main() {
  Story? actualStory;

  tearDown(() {
    actualStory = null;
  });

  group('StoryDetailQuery', () {
    testWidgets('smoke test', (WidgetTester tester) async {
      final expectedStory = stories[0];
      final mockedResult = <String, dynamic>{
        'data': {
          '__typename': 'data',
          "post": {
            '__typename': 'PostDetailed',
            ...expectedStory.toMap(),
            'author': {
              '__typename': 'User',
              ...expectedStory.toMap()['author'],
            },
          }
        }
      };

      final containerKey = ValueKey('containerKey');
      await tester.pumpWidget(
        TestWrapper(
          child: QueryMocker(
            mockedResponse: buildGoodResponse(mockedResult),
            child: StoryDetailQuery(
              slug: 'test',
              builder: (context, story, {refetch, fetchMore}) {
                actualStory = story;
                return Container(key: containerKey);
              },
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(actualStory!.cuid, expectedStory.cuid);
      expect(actualStory!.slug, expectedStory.slug);
    });

    testWidgets('error', (WidgetTester tester) async {
      final expectedStory = stories[0];
      final mockedResult = <String, dynamic>{
        'data': {
          "post": {
            '__typename': 'PostDetailed',
            ...expectedStory.toMap(),
            'author': {
              '__typename': 'User',
              ...expectedStory.toMap()['author'],
            },
          }
        }
      };

      await tester.pumpWidget(
        TestWrapper(
          child: QueryMocker(
            mockedResponse: buildGoodResponse(mockedResult),
            child: StoryDetailQuery(
              slug: 'test',
              builder: (context, story, {refetch, fetchMore}) {
                actualStory = story;
                return Container();
              },
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.byKey(StoryDetailQuery.errorTextKey), findsOneWidget);
    });
  });
}
