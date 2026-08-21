import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injection.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_cubit.dart';
import '../presentation/bloc/home_bloc.dart';
import '../presentation/widgets/movie_section_widget.dart';
import '../presentation/widgets/movie_skeleton_loader.dart';
import '../presentation/widgets/trending_carousel_widget.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return BlocProvider<HomeBloc>(
      create: (_) => getIt<HomeBloc>()..add(FetchHomeMoviesEvent()),
      child: Builder(
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Scaffold(
            backgroundColor:
                isDark ? AppColors.darkBackground : AppColors.lightBackground,
            appBar: AppBar(
              backgroundColor:
                  isDark ? AppColors.darkBackground : AppColors.lightBackground,
              elevation: 0,
              title: Row(
                children: [
                  const Icon(
                    Icons.movie_creation_rounded,
                    color: AppColors.primaryRed,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    locale.translate('app_title'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: AppColors.primaryRed,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: 'Đổi Giao diện',
                  icon: Icon(
                    isDark ? Icons.light_mode : Icons.dark_mode,
                    color: isDark
                        ? AppColors.accentGold
                        : AppColors.darkBackground,
                  ),
                  onPressed: () {
                    getIt<ThemeCubit>().toggleTheme();
                  },
                ),
                IconButton(
                  tooltip: locale.translate('search_placeholder'),
                  icon: Icon(
                    Icons.search,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                  onPressed: () {
                    context.push(RoutePath.search);
                  },
                ),
                IconButton(
                  tooltip: locale.translate('profile'),
                  icon: Icon(
                    Icons.person_outline,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                  onPressed: () {
                    context.push(RoutePath.profile);
                  },
                ),
              ],
            ),
            body: SafeArea(
              child: BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoadingState || state is HomeInitialState) {
                    return const MovieSkeletonLoader();
                  }

                  if (state is HomeErrorState) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                            size: 60,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () {
                              context
                                  .read<HomeBloc>()
                                  .add(FetchHomeMoviesEvent());
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is HomeLoadedState) {
                    return RefreshIndicator(
                      color: AppColors.primaryRed,
                      backgroundColor: AppColors.darkSurface,
                      onRefresh: () async {
                        context.read<HomeBloc>().add(RefreshHomeMoviesEvent());
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            TrendingCarouselWidget(
                              movies: state.trendingMovies,
                            ),
                            if (state.recommendedMovies.isNotEmpty)
                              MovieSectionWidget(
                                title:
                                    '${locale.translate('because_you_added')} "${state.recommendedSourceTitle ?? ''}"',
                                movies: state.recommendedMovies,
                              ),
                            MovieSectionWidget(
                              title: locale.translate('now_playing'),
                              movies: state.nowPlayingMovies,
                              onSeeAll: () {
                                context.push(
                                    RoutePath.categoryPath('now_playing'));
                              },
                            ),
                            MovieSectionWidget(
                              title: locale.translate('popular'),
                              movies: state.popularMovies,
                              onSeeAll: () {
                                context.push(RoutePath.categoryPath('popular'));
                              },
                            ),
                            MovieSectionWidget(
                              title: locale.translate('top_rated'),
                              movies: state.topRatedMovies,
                              onSeeAll: () {
                                context
                                    .push(RoutePath.categoryPath('top_rated'));
                              },
                            ),
                            MovieSectionWidget(
                              title: locale.translate('upcoming'),
                              movies: state.upcomingMovies,
                              onSeeAll: () {
                                context
                                    .push(RoutePath.categoryPath('upcoming'));
                              },
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
