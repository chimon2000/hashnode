import 'package:flutter/material.dart';
import 'package:hashnode/presentation/ui/pages/story_detail/story_detail_query.dart';
import 'package:hashnode/presentation/ui/pages/story_detail/widgets/widgets.dart';

class StoryDetailPage extends StatelessWidget {
  StoryDetailPage({required this.slug, this.hostname});

  static Route<dynamic> route(String? slug, String? hostname) {
    return MaterialPageRoute<dynamic>(builder: (context) {
      return StoryDetailPage(
        slug: slug,
        hostname: hostname,
      );
    });
  }

  final String? slug;
  final String? hostname;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
      ),
      body: StoryDetailQuery(
        slug: slug,
        hostname: hostname,
        builder: (context, story, {refetch, fetchMore}) {
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
