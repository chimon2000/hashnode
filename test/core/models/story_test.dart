import 'package:flutter_test/flutter_test.dart';
import 'package:hashnode/core/models/story.dart';

void main() {
  group('Story', () {
    test('fromJSON', () {
      var story = Story.fromJson(json);

      expect(story.cuid, json['cuid']);
      expect(story.brief, json['brief']);
      expect(story.title, json['title']);
      expect(story.contentMarkdown, json['contentMarkdown']);
      expect(story.coverImage, json['coverImage']);
      expect(story.dateAdded, DateTime.parse(json['dateAdded']));
      expect(story.responseCount, json['responseCount']);
      expect(story.totalReactions, json['totalReactions']);
      expect(story.author, json['author']['username']);
      expect(story.slug, json['slug']);
    });
    test('==', () {
      var story = Story.fromJson(json);
      var anotherStory = Story.fromJson(json);

      expect(story, anotherStory);
    });
    test('toString', () {
      var story = Story.fromJson(json);
      var anotherStory = Story.fromJson(json);

      expect(story.toString(), anotherStory.toString());
    });
  });
}

final Map<String, dynamic> json = {
  'cuid': 'cuid',
  'brief': 'brief',
  'title': 'title',
  'contentMarkdown': 'contentMarkdown',
  'coverImage': '',
  'dateAdded': DateTime.now().toIso8601String(),
  'responseCount': 3,
  'totalReactions': 3,
  'author': {'publicationDomain': '', 'username': 'username'},
  'slug': 'slug',
};
