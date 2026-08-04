import 'package:flutter/material.dart';

import '../controllers/home_controller.dart';
import '../models/movie.dart';

class MovieDetailView extends StatefulWidget {
  final Movie movie;

  const MovieDetailView({
    super.key,
    required this.movie,
  });

  @override
  State<MovieDetailView> createState() => _MovieDetailViewState();
}

class _MovieDetailViewState extends State<MovieDetailView> {
  final HomeController controller = HomeController.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie.tenPhim),

        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                controller.doiTrangThaiYeuThich(widget.movie);
              });
            },
            icon: Icon(
              widget.movie.yeuThich
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: Colors.red,
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            //---------------- ẢNH ----------------//

            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),

              child: Image.asset(
                widget.movie.hinhAnh,
                width: double.infinity,
                height: 400,
                fit: BoxFit.cover,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  //---------------- TÊN PHIM ----------------//

                  Text(
                    widget.movie.tenPhim,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  //---------------- ĐIỂM ĐÁNH GIÁ ----------------//

                  Row(
                    children: [

                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),

                      const SizedBox(width: 10),

                      Text(
                        widget.movie.diemDanhGia.toString(),
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  //---------------- THỂ LOẠI ----------------//

                  Row(
                    children: [

                      const Icon(
                        Icons.movie,
                        color: Colors.red,
                      ),

                      const SizedBox(width: 10),

                      Text(
                        widget.movie.theLoai,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  //---------------- THỜI LƯỢNG ----------------//

                  Row(
                    children: [

                      const Icon(
                        Icons.access_time,
                        color: Colors.red,
                      ),

                      const SizedBox(width: 10),

                      Text(
                        widget.movie.thoiLuong,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  //---------------- NĂM PHÁT HÀNH ----------------//

                  Row(
                    children: [

                      const Icon(
                        Icons.calendar_today,
                        color: Colors.red,
                      ),

                      const SizedBox(width: 10),

                      Text(
                        widget.movie.namPhatHanh.toString(),
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  //---------------- ĐẠO DIỄN ----------------//

                  Row(
                    children: [

                      const Icon(
                        Icons.person,
                        color: Colors.red,
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          widget.movie.daoDien,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  //---------------- MÔ TẢ ----------------//

                  const Text(
                    "Nội dung phim",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    widget.movie.moTa,
                    style: const TextStyle(
                      fontSize: 17,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 40),

                  //---------------- BUTTON ----------------//

                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton.icon(

                      onPressed: () {

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Đang phát: ${widget.movie.tenPhim}",
                            ),
                          ),
                        );

                      },

                      icon: const Icon(Icons.play_arrow),

                      label: const Text(
                        "Xem ngay",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}