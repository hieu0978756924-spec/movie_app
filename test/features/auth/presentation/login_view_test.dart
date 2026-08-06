import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/di/injection.dart';
import 'package:movie_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:movie_app/features/auth/views/login_view.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockAuthBloc mockAuthBloc;

  setUp(() async {
    await GetIt.instance.reset();
    configureDependencies();
    mockAuthBloc = MockAuthBloc();

    when(() => mockAuthBloc.state).thenReturn(AuthInitialState());
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockAuthBloc.close()).thenAnswer((_) async {});

    if (getIt.isRegistered<AuthBloc>()) {
      getIt.unregister<AuthBloc>();
    }
    getIt.registerFactory<AuthBloc>(() => mockAuthBloc);
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: LoginView(),
    );
  }

  group('LoginView Widget & Validation Tests', () {
    testWidgets('Renders all required UI elements (Logo, Fields, Buttons)',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Góc Phim'), findsOneWidget);
      expect(find.byKey(const Key('login_email_field')), findsOneWidget);
      expect(find.byKey(const Key('login_password_field')), findsOneWidget);
      expect(find.byKey(const Key('login_submit_button')), findsOneWidget);
      expect(find.byKey(const Key('login_register_button')), findsOneWidget);
    });

    testWidgets('Shows validation errors for invalid inputs', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Vui lòng nhập email'), findsOneWidget);
      expect(find.text('Vui lòng nhập mật khẩu'), findsOneWidget);

      await tester.enterText(
          find.byKey(const Key('login_email_field')), 'invalid-email');
      await tester.enterText(
          find.byKey(const Key('login_password_field')), '123');

      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Email không hợp lệ'), findsOneWidget);
      expect(find.text('Mật khẩu phải có ít nhất 6 ký tự'), findsOneWidget);
    });

    testWidgets('Dispatches LoginSubmittedEvent when inputs are valid',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(
          find.byKey(const Key('login_email_field')), 'test@example.com');
      await tester.enterText(
          find.byKey(const Key('login_password_field')), 'password123');

      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pumpAndSettle();

      verify(() => mockAuthBloc.add(
            const LoginSubmittedEvent('test@example.com', 'password123'),
          )).called(1);
    });
  });
}
