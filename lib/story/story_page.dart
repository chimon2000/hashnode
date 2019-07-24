import 'package:flutter/material.dart';
import 'package:hashnode/story/story_query.dart';

class StoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: StoryQuery(),
        )
      ],
    );
  }
}
