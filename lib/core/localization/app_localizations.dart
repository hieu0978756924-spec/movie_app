import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('vi'));
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'vi': {
      'app_title': 'Góc Phim',
      'search_placeholder': 'Tìm kiếm phim, thể loại, diễn viên...',
      'hot_trending': 'PHIM HOT BỔN MÙA',
      'now_playing': 'Phim Đang Chiếu',
      'popular': 'Phim Phổ Biến',
      'top_rated': 'Phim Đánh Giá Cao',
      'upcoming': 'Phim Sắp Chiếu',
      'my_favorites': 'Phim Yêu Thích',
      'profile': 'Tài Khoản',
      'watch_now': 'Xem Ngay',
      'add_favorite': 'Yêu Thích',
      'added_favorite': 'Đã Yêu Thích',
      'synopsis': 'Nội dung phim',
      'cast': 'Diễn viên',
      'director': 'Đạo diễn',
      'release_date': 'Ngày khởi chiếu',
      'duration': 'Thời lượng',
      'rating': 'Đánh giá',
      'minutes': 'phút',
      'login_title': 'Chào mừng đến Góc Phim',
      'login_subtitle':
          'Đăng nhập để xem phim HD và đồng bộ danh sách yêu thích cá nhân',
      'login_google': 'Đăng nhập bằng Google',
      'login_facebook': 'Đăng nhập bằng Facebook',
      'login_guest': 'Dùng thử không đăng nhập',
      'cloud_synced': 'Đã đồng bộ Đám Mây',
      'cloud_syncing': 'Đang đồng bộ...',
      'dark_mode': 'Chế độ Tối',
      'light_mode': 'Chế độ Sáng',
      'language': 'Ngôn ngữ',
      'vietnamese': 'Tiếng Việt 🇻🇳',
      'english': 'English 🇬🇧',
      'logout': 'Đăng xuất',
      'biography': 'Tiểu sử',
      'known_for': 'Phim đã tham gia',
      'see_all': 'Xem tất cả',
      'see_more': 'Xem thêm',
      'show_less': 'Thu gọn',
      'similar_movies': 'Phim tương tự',
      'try_again': 'Thử lại',
      'reviews': 'Đánh giá & Bình luận',
      'no_results': 'Không tìm thấy kết quả phù hợp',
      'because_you_added': 'Vì bạn đã thêm',
    },
    'en': {
      'app_title': 'Movie Corner',
      'search_placeholder': 'Search movies, genres, actors...',
      'hot_trending': 'HOT & TRENDING',
      'now_playing': 'Now Playing',
      'popular': 'Popular Movies',
      'top_rated': 'Top Rated',
      'upcoming': 'Upcoming Movies',
      'my_favorites': 'My Favorites',
      'profile': 'Account & Settings',
      'watch_now': 'Watch Now',
      'add_favorite': 'My List',
      'added_favorite': 'In My List',
      'synopsis': 'Synopsis',
      'cast': 'Cast & Crew',
      'director': 'Director',
      'release_date': 'Release Date',
      'duration': 'Duration',
      'rating': 'Rating',
      'minutes': 'mins',
      'login_title': 'Welcome to Movie Corner',
      'login_subtitle':
          'Sign in to watch HD movies & sync your favorite list to cloud',
      'login_google': 'Continue with Google',
      'login_facebook': 'Continue with Facebook',
      'login_guest': 'Continue as Guest',
      'cloud_synced': 'Cloud Synced',
      'cloud_syncing': 'Syncing...',
      'dark_mode': 'Dark Mode',
      'light_mode': 'Light Mode',
      'language': 'Language',
      'vietnamese': 'Tiếng Việt 🇻🇳',
      'english': 'English 🇬🇧',
      'logout': 'Sign Out',
      'biography': 'Biography',
      'known_for': 'Known For',
      'see_all': 'See All',
      'see_more': 'Read More',
      'show_less': 'Show Less',
      'similar_movies': 'Similar Movies',
      'try_again': 'Try Again',
      'reviews': 'Reviews & Comments',
      'no_results': 'No matching results found',
      'because_you_added': 'Because you added',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['vi']?[key] ??
        key;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['vi', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
