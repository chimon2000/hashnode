import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hashnode/core/models/story.dart';
import 'package:hashnode/presentation/ui/pages/story/story_query.dart';
import 'package:hashnode/presentation/ui/pages/story/widgets/widgets.dart';
import 'package:hashnode/presentation/ui/pages/story_detail/story_detail_page.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:routemaster/routemaster.dart';
import 'package:provider/provider.dart';

class StoryPage extends StatefulWidget {
  final StoryListType listType;
  final String listTitle;

  StoryPage({
    Key? key,
    this.listType = StoryListType.featured,
    this.listTitle = 'Featured stories',
  }) : super(key: key);

  @override
  _StoryPageState createState() => _StoryPageState();

  @visibleForTesting
  static const refreshIndicatorKey =
      ValueKey('story_page_refresh_indicator_key');

  static _InheritedPageState of(BuildContext context) =>
      (context.dependOnInheritedWidgetOfExactType<_InheritedPageState>()
          as _InheritedPageState);
}

class _StoryPageState extends State<StoryPage> {
  bool _isFetchingMore = false;
  int _nextPage = 2;

  @override
  void initState() {
    super.initState();

    final deviceType = context.read<DeviceScreenType>();

    if (deviceType == DeviceScreenType.mobile) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        final queryParameters = RouteData.of(context).queryParameters;
        if (!queryParameters.containsKey('slug')) return;

        Routemaster.of(context).push('/story',
            queryParameters: RouteData.of(context).queryParameters);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StoryPageHeader(title: widget.listTitle),
      body: StoryQuery(
        listType: widget.listType,
        builder: (context, stories, {refetch, fetchMore}) {
          return _InheritedPageState(
            stories: stories,
            onFetchMore: _handleFetchMore(fetchMore: fetchMore),
            onStoryTap: _handleStoryTap,
            onRefresh: _handleRefresh(refetch: refetch),
            isFetchingMore: _isFetchingMore,
            child: ScreenTypeLayout.builder(
              mobile: (context) => MobileView(),
              desktop: (context) => DesktopView(),
            ),
          );
        },
      ),
    );
  }

  Future<void> Function() _handleRefresh(
      {Future<QueryResult?> Function()? refetch}) {
    return () => Future.delayed(Duration(seconds: 1), refetch);
  }

  Future<void> Function() _handleFetchMore(
      {dynamic Function(FetchMoreOptions)? fetchMore}) {
    return () async {
      final options = buildFetchMoreOpts(page: _nextPage);
      setState(() {
        _isFetchingMore = true;
      });

      await fetchMore!(options);

      setState(() {
        _isFetchingMore = false;
        _nextPage = _nextPage + 2;
      });
    };
  }

  void _handleStoryTap(Story story) {
    var deviceType = getDeviceType(MediaQuery.of(context).size);
    final hostname = (story.hostname?.isEmpty ?? true)
        ? '${story.author}.hashnode.dev'
        : story.hostname!;
    final queryParams = {"slug": story.slug!, "hostname": hostname}
      ..removeWhere((key, value) => value.isEmpty);

    if (deviceType == DeviceScreenType.mobile) {
      Routemaster.of(context).push('/story', queryParameters: queryParams);
    } else {
      final listType = describeEnum(widget.listType);
      Routemaster.of(context)
          .push('/stories/$listType', queryParameters: queryParams);
    }
  }
}

class MobileView extends StatelessWidget {
  const MobileView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = StoryPage.of(context);

    return RefreshIndicator(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: StoryList(
              stories: state.stories,
              isFetchingMore: state.isFetchingMore,
              onFetchMore: state.onFetchMore,
              onStoryTap: state.onStoryTap,
            ),
          ),
        ],
      ),
      onRefresh: state.onRefresh,
    );
  }
}

class DesktopView extends StatelessWidget {
  const DesktopView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = StoryPage.of(context);
    final queryParams = RouteData.of(context).queryParameters;

    final slug = queryParams['slug'];
    final hostname = queryParams['hostname'];

    return Row(
      children: [
        SizedBox(
          width: 350,
          child: RefreshIndicator(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: StoryList(
                    stories: state.stories,
                    isFetchingMore: state.isFetchingMore,
                    onFetchMore: state.onFetchMore,
                    onStoryTap: state.onStoryTap,
                  ),
                ),
              ],
            ),
            onRefresh: state.onRefresh,
          ),
        ),
        Expanded(
          child: slug == null
              ? Container(
                  color: Colors.white,
                )
              : StoryDetailPage(
                  slug: slug,
                  hostname: hostname,
                ),
        ),
      ],
    );
  }
}

FetchMoreOptions buildFetchMoreOpts({page = 2}) {
  FetchMoreOptions options = FetchMoreOptions.partial(
    variables: {'currentPage': page, 'nextPage': page + 1},
    updateQuery: (previousResultData, fetchMoreResultData) {
      final List<Object> currentPage = [
        ...previousResultData!['current'],
        ...previousResultData['next'],
      ];
      final List<Object> nextPage = [
        ...fetchMoreResultData!['current'],
        ...fetchMoreResultData['next'],
      ];

      fetchMoreResultData['current'] = currentPage;
      fetchMoreResultData['next'] = nextPage;

      return fetchMoreResultData;
    },
  );

  return options;
}

class _InheritedPageState extends InheritedWidget {
  _InheritedPageState({
    Key? key,
    required Widget child,
    required this.isFetchingMore,
    required this.onFetchMore,
    required this.onStoryTap,
    required this.onRefresh,
    required this.stories,
  }) : super(key: key, child: child);

  final bool isFetchingMore;
  final VoidCallback? onFetchMore;
  final OnStoryTapFn onStoryTap;
  final Future<void> Function() onRefresh;
  final List<Story> stories;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;
}
