import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import 'app_router.dart';

@module
abstract class RouterModule {
  @singleton
  GoRouter get router => AppRouter.router;
}
