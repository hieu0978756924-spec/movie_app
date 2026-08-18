import 'package:flutter/material.dart';

import '../controllers/home_controller.dart';
import '../models/movie.dart';
import '../views/movie_detail_view.dart';

class MovieCard extends StatefulWidget {
  final Movie movie;
  final VoidCallback? onReload;

  const MovieCard({
    super.key,
    required this.movie,
    this.onReload,
  });

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  final HomeController controller = HomeController.instance;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MovieDetailView(
              movie: widget.movie,
            ),
          ),
        ).then((_) {
          if (widget.onReload != null) {
            widget.onReload!();
          }
        });
      },

      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 15),

        decoration: BoxDecoration(
          color: const Color(0xff1E1E1E),

          borderRadius: BorderRadius.circular(20),

          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            //------------------ ẢNH ------------------//

            Stack(
              children: [

                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),

                  child: Image.asset(
                    widget.movie.hinhAnh,
                    width: double.infinity,
                    height: 260,
                    fit: BoxFit.cover,
                  ),
                ),

                Positioned(
                  right: 10,
                  top: 10,
                  child: ListenableBuilder(
                    listenable: controller,
                    builder: (context, _) {
                      final isFav = controller.favoriteMovieIds.contains(widget.movie.id) || widget.movie.yeuThich;
                      return CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          onPressed: () {
                            controller.doiTrangThaiYeuThich(widget.movie);
                            if (widget.onReload != null) {
                              widget.onReload!();
                            }
                          },
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: Colors.red,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            //------------------ THÔNG TIN ------------------//

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Text(
                      widget.movie.tenPhim,

                      maxLines: 2,

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [

                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 18,
                        ),

                        const SizedBox(width: 5),

                        Text(
                          '${widget.movie.diemDanhGia.toStringAsFixed(1)}/10',
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Text(
                      widget.movie.theLoai,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      widget.movie.thoiLuong,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                    const Spacer(),

                    SizedBox(
                      width: double.infinity,

                      child: ElevatedButton.icon(

                        onPressed: () {

                          Navigator.push(
                            context,

                            MaterialPageRoute(

                              builder: (_) =>
                                  MovieDetailView(
                                movie: widget.movie,
                              ),
                            ),
                          );

                        },

                        icon: const Icon(Icons.play_arrow),

                        label: const Text("Xem chi tiết"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}