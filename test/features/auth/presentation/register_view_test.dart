import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/di/injection.dart';
import 'package:movie_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:movie_app/features/auth/views/register_view.dart';

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
      home: RegisterView(),
    );
  }

  group('RegisterView Widget & Validation Tests', () {
    testWidgets('Renders all required UI elements', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Tạo tài khoản'), findsOneWidget);
      expect(find.byKey(const Key('register_name_field')), findsOneWidget);
      expect(find.byKey(const Key('register_email_field')), findsOneWidget);
      expect(find.byKey(const Key('register_password_field')), findsOneWidget);
      expect(find.byKey(const Key('register_confirm_password_field')),
          findsOneWidget);
      expect(find.byKey(const Key('register_submit_button')), findsOneWidget);
    });

    testWidgets('Shows validation errors for empty and invalid inputs',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final submitBtn = find.byKey(const Key('register_submit_button'));
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('Vui lòng nhập họ và tên'), findsOneWidget);
      expect(find.text('Vui lòng nhập email'), findsOneWidget);
      expect(find.text('Vui lòng nhập mật khẩu'), findsOneWidget);
      expect(find.text('Vui lòng nhập lại mật khẩu'), findsOneWidget);

      // Enter mismatched passwords
      await tester.enterText(
          find.byKey(const Key('register_name_field')), 'John Doe');
      await tester.enterText(
          find.byKey(const Key('register_email_field')), 'john@example.com');
      await tester.enterText(
          find.byKey(const Key('register_password_field')), 'pass123');
      await tester.enterText(
          find.byKey(const Key('register_confirm_password_field')), 'pass456');

      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('Mật khẩu không khớp'), findsOneWidget);
    });

    testWidgets(
        'Dispatches RegisterSubmittedEvent when form is valid and submitted',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(
          find.byKey(const Key('register_name_field')), 'John Doe');
      await tester.enterText(
          find.byKey(const Key('register_email_field')), 'john@example.com');
      await tester.enterText(
          find.byKey(const Key('register_password_field')), 'password123');
      await tester.enterText(
          find.byKey(const Key('register_confirm_password_field')),
          'password123');

      final submitBtn = find.byKey(const Key('register_submit_button'));
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      verify(() => mockAuthBloc.add(
            const RegisterSubmittedEvent('john@example.com', 'password123'),
          )).called(1);
    });
  });
}
