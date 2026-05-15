import 'package:flutter_test/flutter_test.dart';

import 'package:news_app/main.dart';

void main() {
  testWidgets('App loads sign-in', (WidgetTester tester) async {
    await tester.pumpWidget(const NewsAppRoot());
    await tester.pump();
    expect(find.textContaining('News Desk'), findsOneWidget);
  });
}
