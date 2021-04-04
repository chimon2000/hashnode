import 'package:flutter/material.dart';
import 'package:hashnode/ui/pages/story_detail/story_detail_query.dart';

class StoryDetailPage extends StatelessWidget {
  final String slug;
  final String hostname;

  StoryDetailPage({@required this.slug, this.hostname});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
      ),
      body: StoryDetailQuery(
        slug: slug,
        hostname: hostname,
        builder: (context, story, {refetch}) {
          return RefreshIndicator(
            child: StoryDetail(
              story: story,
            ),
            onRefresh: () async =>
                Future.delayed(Duration(seconds: 1), refetch),
          );
        },
      ),
    );
  }
}
