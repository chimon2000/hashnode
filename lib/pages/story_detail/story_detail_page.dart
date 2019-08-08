import 'package:flutter/material.dart';
import 'package:hashnode/pages/story_detail/story_detail_query.dart';

class StoryDetailPage extends StatelessWidget {
  final String cuid;
  StoryDetailPage({@required this.cuid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
      ),
      body: StoryDetailQuery(
        cuid: cuid,
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
