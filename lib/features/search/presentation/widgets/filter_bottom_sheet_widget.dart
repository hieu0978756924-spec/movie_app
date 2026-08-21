import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../home/domain/entities/genre.dart';
import '../../domain/entities/movie_filter.dart';

class FilterBottomSheetWidget extends StatefulWidget {
  final MovieFilter initialFilter;
  final List<Genre> availableGenres;
  final ValueChanged<MovieFilter> onApply;

  const FilterBottomSheetWidget({
    super.key,
    required this.initialFilter,
    required this.availableGenres,
    required this.onApply,
  });

  static Future<void> show({
    required BuildContext context,
    required MovieFilter initialFilter,
    required List<Genre> availableGenres,
    required ValueChanged<MovieFilter> onApply,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterBottomSheetWidget(
        initialFilter: initialFilter,
        availableGenres: availableGenres,
        onApply: onApply,
      ),
    );
  }

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late MovieFilter _tempFilter;

  @override
  void initState() {
    super.initState();
    _tempFilter = widget.initialFilter;
  }

  void _reset() {
    setState(() {
      _tempFilter = const MovieFilter();
    });
  }

  void _toggleGenre(int genreId) {
    final currentIds = List<int>.from(_tempFilter.selectedGenreIds);
    if (currentIds.contains(genreId)) {
      currentIds.remove(genreId);
    } else {
      currentIds.add(genreId);
    }
    setState(() {
      _tempFilter = _tempFilter.copyWith(selectedGenreIds: currentIds);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceVariant
                      : AppColors.lightSurfaceVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bộ Lọc & Sắp Xếp',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: _reset,
                        child: const Text(
                          'Đặt lại',
                          style: TextStyle(
                            color: AppColors.primaryRed,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(
              color: isDark
                  ? AppColors.glassBorder
                  : AppColors.lightSurfaceVariant,
              height: 1,
            ),

            // Scrollable Filter Sections
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Genres
                    if (widget.availableGenres.isNotEmpty) ...[
                      Text(
                        'Thể loại phim',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.availableGenres.map((genre) {
                          final isSelected =
                              _tempFilter.selectedGenreIds.contains(genre.id);
                          return FilterChip(
                            selected: isSelected,
                            label: Text(genre.name),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary),
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            selectedColor: AppColors.primaryRed,
                            backgroundColor: isDark
                                ? AppColors.darkSurfaceVariant
                                : AppColors.lightSurfaceVariant,
                            checkmarkColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.primaryRed
                                    : Colors.transparent,
                              ),
                            ),
                            onSelected: (_) => _toggleGenre(genre.id),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Section 2: Year Range Slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Năm phát hành',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_tempFilter.startYear} - ${_tempFilter.endYear}',
                          style: const TextStyle(
                            color: AppColors.accentGold,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    RangeSlider(
                      values: RangeValues(
                        _tempFilter.startYear.toDouble(),
                        _tempFilter.endYear.toDouble(),
                      ),
                      min: 1980,
                      max: currentYear.toDouble(),
                      divisions: currentYear - 1980,
                      activeColor: AppColors.primaryRed,
                      inactiveColor: isDark
                          ? AppColors.darkSurfaceVariant
                          : AppColors.lightSurfaceVariant,
                      labels: RangeLabels(
                        _tempFilter.startYear.toString(),
                        _tempFilter.endYear.toString(),
                      ),
                      onChanged: (RangeValues values) {
                        setState(() {
                          _tempFilter = _tempFilter.copyWith(
                            startYear: values.start.round(),
                            endYear: values.end.round(),
                          );
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Section 3: Min Rating Slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Điểm đánh giá tối thiểu',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: AppColors.accentGold,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _tempFilter.minRating > 0
                                  ? '${_tempFilter.minRating.toStringAsFixed(1)}+'
                                  : 'Tất cả',
                              style: const TextStyle(
                                color: AppColors.accentGold,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Slider(
                      value: _tempFilter.minRating.clamp(0.0, 10.0),
                      min: 0.0,
                      max: 10.0,
                      divisions: 10,
                      activeColor: AppColors.accentGold,
                      inactiveColor: isDark ? Colors.white24 : Colors.black12,
                      label: '${_tempFilter.minRating.round()} sao',
                      onChanged: (val) {
                        setState(() {
                          _tempFilter = _tempFilter.copyWith(minRating: val);
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Section 4: Sort Option
                    Text(
                      'Sắp xếp theo',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: SortOption.values.map((sortOpt) {
                        final isSelected = _tempFilter.sortBy == sortOpt;
                        return ChoiceChip(
                          selected: isSelected,
                          label: Text(sortOpt.label),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary),
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          selectedColor: AppColors.primaryRed,
                          backgroundColor: isDark
                              ? AppColors.darkSurfaceVariant
                              : AppColors.lightSurfaceVariant,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          onSelected: (_) {
                            setState(() {
                              _tempFilter =
                                  _tempFilter.copyWith(sortBy: sortOpt);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // Apply Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_tempFilter);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _tempFilter.activeFilterCount > 0
                        ? 'Áp dụng bộ lọc (${_tempFilter.activeFilterCount})'
                        : 'Áp dụng',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
