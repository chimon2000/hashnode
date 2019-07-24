import 'package:flutter/material.dart';
import 'package:hashnode/story/story_detail_query.dart';

class StoryDetailPage extends StatelessWidget {
  final String cuid;
  StoryDetailPage({@required this.cuid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hashnode'),
        elevation: 0.0,
      ),
      body: StoryDetailQuery(
        cuid: cuid,
        builder: (context, story) {
          return StoryDetail(
            story: story,
          );
        },
      ),
    );
  }
}
