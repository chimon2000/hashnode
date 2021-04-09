// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:hashnode/presentation/ui/pages/about/about_page.dart';
import 'package:provider/provider.dart';

import '../../../../util/util.dart';

void main() {
  group('AboutPage', () {
    testWidgets('smoke test', (WidgetTester tester) async {
      await tester.pumpWidget(
        TesterWrapper(
          child: AboutPage(),
        ),
      );

      expect(find.text('ryanedge.page'), findsOneWidget);
    });
  });
}
