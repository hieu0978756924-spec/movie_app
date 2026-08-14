import 'package:equatable/equatable.dart';

enum SortOption {
  popularityDesc('popularity.desc', 'Phổ biến nhất'),
  ratingDesc('vote_average.desc', 'Đánh giá cao nhất'),
  releaseDateDesc('primary_release_date.desc', 'Mới nhất'),
  releaseDateAsc('primary_release_date.asc', 'Cũ nhất');

  final String value;
  final String label;
  const SortOption(this.value, this.label);
}

class MovieFilter extends Equatable {
  final List<int> selectedGenreIds;
  final int startYear;
  final int endYear;
  final double minRating;
  final SortOption sortBy;

  const MovieFilter({
    this.selectedGenreIds = const [],
    this.startYear = 1980,
    this.endYear = 2026,
    this.minRating = 0.0,
    this.sortBy = SortOption.popularityDesc,
  });

  bool get isDefault =>
      selectedGenreIds.isEmpty &&
      startYear == 1980 &&
      endYear == 2026 &&
      minRating == 0.0 &&
      sortBy == SortOption.popularityDesc;

  int get activeFilterCount {
    int count = 0;
    if (selectedGenreIds.isNotEmpty) count += selectedGenreIds.length;
    if (startYear > 1980 || endYear < 2026) count++;
    if (minRating > 0.0) count++;
    if (sortBy != SortOption.popularityDesc) count++;
    return count;
  }

  MovieFilter copyWith({
    List<int>? selectedGenreIds,
    int? startYear,
    int? endYear,
    double? minRating,
    SortOption? sortBy,
  }) {
    return MovieFilter(
      selectedGenreIds: selectedGenreIds ?? this.selectedGenreIds,
      startYear: startYear ?? this.startYear,
      endYear: endYear ?? this.endYear,
      minRating: minRating ?? this.minRating,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  @override
  List<Object?> get props => [
        selectedGenreIds,
        startYear,
        endYear,
        minRating,
        sortBy,
      ];
}
