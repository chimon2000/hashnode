import 'package:hashnode/core/models/story.dart';
import 'package:intl/intl.dart';

extension StoryDisplayEnhancements on Story {
  String get caption {
    final reactions = Intl.plural(
      totalReactions!,
      zero: '',
      one: '$totalReactions reaction',
      many: '$totalReactions reactions',
      other: '$totalReactions reactions',
      name: 'reactions',
      args: [totalReactions!],
    );

    final comments = Intl.plural(
      responseCount!,
      zero: '',
      one: '$responseCount comment',
      many: '$responseCount comments',
      other: '$responseCount comments',
      name: 'comments',
      args: [responseCount!],
    );

    final strings = [
      reactions,
      comments,
    ].where((row) => row.isNotEmpty).toList();

    final totals = list(strings);

    return 'by $author $timeAgo ${totals.isEmpty ? "" : ", $totals"}';
  }

  String list([List<String> values = const []]) {
    return '';
  }
}
