import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injection.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../presentation/bloc/home_bloc.dart';
import '../presentation/widgets/movie_section_widget.dart';
import '../presentation/widgets/movie_skeleton_loader.dart';
import '../presentation/widgets/trending_carousel_widget.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>(
      create: (_) => getIt<HomeBloc>()..add(FetchHomeMoviesEvent()),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.darkBackground,
              elevation: 0,
              title: const Row(
                children: [
                  Icon(
                    Icons.movie_creation_rounded,
                    color: AppColors.primaryRed,
                    size: 28,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Góc Phim",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: AppColors.primaryRed,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    context.push(RoutePath.search);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.person_outline, color: Colors.white),
                  onPressed: () {
                    context.push(RoutePath.profile);
                  },
                ),
              ],
            ),
            body: SafeArea(
              child: BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoadingState) {
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
                            style: const TextStyle(
                              color: Colors.white,
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
                        context
                            .read<HomeBloc>()
                            .add(RefreshHomeMoviesEvent());
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
                            MovieSectionWidget(
                              title: 'Phim Đang Chiếu',
                              movies: state.nowPlayingMovies,
                              onSeeAll: () {
                                context.push(
                                    RoutePath.categoryPath('now_playing'));
                              },
                            ),
                            MovieSectionWidget(
                              title: 'Phim Phổ Biến',
                              movies: state.popularMovies,
                              onSeeAll: () {
                                context
                                    .push(RoutePath.categoryPath('popular'));
                              },
                            ),
                            MovieSectionWidget(
                              title: 'Phim Đánh Giá Cao',
                              movies: state.topRatedMovies,
                              onSeeAll: () {
                                context
                                    .push(RoutePath.categoryPath('top_rated'));
                              },
                            ),
                            MovieSectionWidget(
                              title: 'Phim Sắp Chiếu',
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