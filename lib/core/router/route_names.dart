abstract class RouteName {
  static const splash = 'splash';
  static const login = 'login';
  static const register = 'register';
  static const forgotPassword = 'forgotPassword';
  static const home = 'home';
  static const movieDetail = 'movieDetail';
  static const category = 'category';
  static const search = 'search';
  static const watchlist = 'watchlist';
  static const profile = 'profile';
}

abstract class RoutePath {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const home = '/';
  static const movieDetail = '/movie/:id';
  static const category = '/category/:type';
  static const search = '/search';
  static const watchlist = '/watchlist';
  static const profile = '/profile';

  static String movieDetailPath(String id) => '/movie/$id';
  static String categoryPath(String type) => '/category/$type';
}



