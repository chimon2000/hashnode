import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:timeago/timeago.dart' as timeago;

class Story extends Equatable {
  final String? cuid;
  final String? slug;
  final String? title;
  final String? brief;
  final String? content;
  final String? contentMarkdown;
  final String? coverImage;
  final String? hostname;
  final int? responseCount;
  final int? totalReactions;
  final String? author;
  final DateTime dateAdded;

  Story({
    required this.cuid,
    required this.title,
    required this.brief,
    required this.dateAdded,
    required this.slug,
    this.content,
    this.contentMarkdown,
    this.coverImage,
    this.responseCount,
    this.totalReactions,
    this.author,
    this.hostname,
  });

  String get timeAgo {
    return timeago.format(dateAdded);
  }

  @override
  List<Object?> get props {
    return [
      cuid,
      slug,
      title,
      brief,
      content,
      contentMarkdown,
      coverImage,
      hostname,
      responseCount,
      totalReactions,
      author,
      dateAdded,
    ];
  }

  @override
  bool get stringify => true;

  Map<String, dynamic> toMap() {
    return {
      'cuid': cuid,
      'slug': slug,
      'title': title,
      'brief': brief,
      'content': content,
      'contentMarkdown': contentMarkdown,
      'coverImage': coverImage,
      'responseCount': responseCount,
      'totalReactions': totalReactions,
      'author': {
        'username': author,
        'publicationDomain': hostname,
      },
      'dateAdded': dateAdded.toIso8601String(),
    };
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
        responseCount: json['responseCount'],
        totalReactions: json['totalReactions'],
        author: json['author']['username'],
        hostname: Uri.tryParse(json['author']['publicationDomain'] ?? '')?.host,
        slug: json['slug'],
      );
}
