import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/di/injection.dart';
import 'package:movie_app/core/router/app_router.dart';
import 'package:movie_app/main.dart';

void main() {
  testWidgets('MovieApp smoke test', (WidgetTester tester) async {
    configureDependencies();
    AppRouter.setAuthCheckOverride(() => false);
    await tester.pumpWidget(const MovieApp());
    await tester.pumpAndSettle();
    expect(find.byType(MovieApp), findsOneWidget);
  });
}
