import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/di/injection.dart';
import 'package:movie_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:movie_app/features/splash/views/splash_view.dart';

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
      home: SplashView(),
    );
  }

  group('SplashView Widget Tests', () {
    testWidgets(
        'Renders all required branding elements and triggers CheckAuthEvent',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Góc Phim'), findsOneWidget);
      expect(find.text('Thế giới điện ảnh trong tay bạn'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      verify(() => mockAuthBloc.add(CheckAuthEvent())).called(1);
    });
  });
}
