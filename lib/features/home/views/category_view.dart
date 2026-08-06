import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../presentation/bloc/category_bloc.dart';
import '../presentation/widgets/movie_card_widget.dart';
import '../presentation/widgets/movie_skeleton_loader.dart';

class CategoryView extends StatefulWidget {
  final String categoryType;

  const CategoryView({
    super.key,
    required this.categoryType,
  });

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<CategoryBloc>().add(LoadMoreCategoryMoviesEvent());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _getCategoryTitle(String type) {
    switch (type) {
      case 'trending':
        return 'Phim Trending';
      case 'now_playing':
        return 'Phim Đang Chiếu';
      case 'popular':
        return 'Phim Phổ Biến';
      case 'top_rated':
        return 'Phim Đánh Giá Cao';
      case 'upcoming':
        return 'Phim Sắp Chiếu';
      default:
        return 'Danh sách phim';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CategoryBloc>(
      create: (_) => getIt<CategoryBloc>()
        ..add(FetchCategoryMoviesEvent(widget.categoryType)),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.darkBackground,
              elevation: 0,
              title: Text(
                _getCategoryTitle(widget.categoryType),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: SafeArea(
              child: BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  if (state is CategoryLoadingState) {
                    return const MovieSkeletonLoader();
                  }

                  if (state is CategoryErrorState) {
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
                            style: const TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.read<CategoryBloc>().add(
                                    FetchCategoryMoviesEvent(
                                        widget.categoryType),
                                  );
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is CategoryLoadedState) {
                    if (state.movies.isEmpty) {
                      return const Center(
                        child: Text(
                          'Không có phim nào',
                          style: TextStyle(color: Colors.white70),
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          Expanded(
                            child: GridView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.only(top: 12, bottom: 16),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.62,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: state.movies.length,
                              itemBuilder: (context, index) {
                                return MovieCardWidget(
                                  movie: state.movies[index],
                                );
                              },
                            ),
                          ),
                          if (state.isLoadingMore)
                            const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.primaryRed,
                                ),
                              ),
                            ),
                        ],
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
