import 'package:flutter/material.dart';

import 'package:movie_app/features/home/controllers/home_controller.dart';
import 'package:movie_app/features/home/models/movie.dart';
import 'package:movie_app/features/home/views/movie_detail_view.dart';
class FavoriteView extends StatefulWidget {
  const FavoriteView({super.key});

  @override
  State<FavoriteView> createState() => _FavoriteViewState();
}

class _FavoriteViewState extends State<FavoriteView> {
  final HomeController controller = HomeController.instance;

  @override
  Widget build(BuildContext context) {
    List<Movie> danhSachYeuThich =
        controller.danhSachYeuThich;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Phim yêu thích"),
      ),

      body: danhSachYeuThich.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [

                  Icon(
                    Icons.favorite_border,
                    color: Colors.red,
                    size: 90,
                  ),

                  SizedBox(height: 20),

                  Text(
                    "Bạn chưa có phim yêu thích",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(15),

              itemCount: danhSachYeuThich.length,

              itemBuilder: (context, index) {
                final movie = danhSachYeuThich[index];

                return Card(
                  margin: const EdgeInsets.only(
                    bottom: 15,
                  ),

                  child: InkWell(
                    borderRadius:
                        BorderRadius.circular(16),

                    onTap: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (_) =>
                              MovieDetailView(
                            movie: movie,
                          ),
                        ),
                      ).then((_) {
                        setState(() {});
                      });
                    },

                    child: Padding(
                      padding:
                          const EdgeInsets.all(12),

                      child: Row(
                        children: [

                          //---------------- ẢNH ----------------//

                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(10),

                            child: Image.asset(
                              movie.hinhAnh,
                              width: 90,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),

                          const SizedBox(width: 15),

                          //---------------- THÔNG TIN ----------------//

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [

                                Text(
                                  movie.tenPhim,
                                  style:
                                      const TextStyle(
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Text(movie.theLoai),

                                const SizedBox(height: 8),

                                Row(
                                  children: [

                                    const Icon(
                                      Icons.star,
                                      color:
                                          Colors.amber,
                                      size: 18,
                                    ),

                                    const SizedBox(
                                        width: 5),

                                    Text(
                                      movie
                                          .diemDanhGia
                                          .toString(),
                                    ),

                                  ],
                                ),

                                const SizedBox(
                                    height: 10),

                                Text(
                                  movie.thoiLuong,
                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          //---------------- BỎ YÊU THÍCH ----------------//

                          IconButton(
                            onPressed: () {
                              setState(() {
                                controller
                                    .doiTrangThaiYeuThich(
                                        movie);
                              });
                            },

                            icon: const Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}