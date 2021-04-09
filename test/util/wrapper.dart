import 'package:flutter/material.dart';
import 'package:hashnode/core/providers/settings.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class TesterWrapper extends StatelessWidget {
  final List<SingleChildWidget>? providers;
  final Widget child;
  final TargetPlatform platform;

  late final List<SingleChildWidget> _providers = [
    ChangeNotifierProvider.value(value: Settings())
  ];

  TesterWrapper({
    Key? key,
    required this.child,
    this.providers,
    this.platform = TargetPlatform.android,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers ?? _providers,
      child: MaterialApp(
        theme: ThemeData(platform: platform, brightness: Brightness.light),
        home: Material(
          child: Builder(
            builder: (context) => child,
          ),
        ),
      ),
    );
  }
}
