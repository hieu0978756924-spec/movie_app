import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/main.dart';

void main() {
  testWidgets('MovieApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MovieApp());
    expect(find.text('Góc Phim App Initialized'), findsOneWidget);
  });
}