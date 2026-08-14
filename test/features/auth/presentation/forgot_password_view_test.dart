import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/di/injection.dart';
import 'package:movie_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:movie_app/features/auth/views/forgot_password_view.dart';

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
      home: ForgotPasswordView(),
    );
  }

  group('ForgotPasswordView Widget & Validation Tests', () {
    testWidgets('Renders all required UI elements', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Khôi phục mật khẩu'), findsOneWidget);
      expect(find.byKey(const Key('forgot_email_field')), findsOneWidget);
      expect(find.byKey(const Key('forgot_submit_button')), findsOneWidget);
      expect(find.byKey(const Key('forgot_back_to_login_button')),
          findsOneWidget);
    });

    testWidgets('Shows validation errors for empty and invalid email',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final submitBtn = find.byKey(const Key('forgot_submit_button'));
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('Vui lòng nhập email'), findsOneWidget);

      await tester.enterText(
          find.byKey(const Key('forgot_email_field')), 'invalid-email');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('Email không hợp lệ'), findsOneWidget);
    });

    testWidgets(
        'Dispatches ResetPasswordSubmittedEvent when email is valid and submitted',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(
          find.byKey(const Key('forgot_email_field')), 'test@example.com');

      final submitBtn = find.byKey(const Key('forgot_submit_button'));
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      verify(() => mockAuthBloc.add(
            const ResetPasswordSubmittedEvent('test@example.com'),
          )).called(1);
    });
  });
}
