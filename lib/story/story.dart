import 'package:flutter/foundation.dart';
import 'package:timeago/timeago.dart' as timeago;

class Story {
  final String cuid;
  final String title;
  final String brief;
  final String content;
  final String contentMarkdown;
  final String coverImage;
  final DateTime dateAdded;

  Story({
    @required this.cuid,
    @required this.title,
    @required this.brief,
    @required this.dateAdded,
    this.content,
    this.contentMarkdown,
    this.coverImage,
  });

  String get timeAgo {
    return timeago.format(dateAdded);
  }

  static Story fromJson(Map<String, dynamic> json) => Story(
        cuid: json['cuid'],
        brief: json['brief'],
        title: json['title'],
        content: json['content'],
        contentMarkdown: json['contentMarkdown'],
        coverImage: json['coverImage'],
        dateAdded: DateTime.parse(
          json['dateAdded'],
        ),
      );
}
