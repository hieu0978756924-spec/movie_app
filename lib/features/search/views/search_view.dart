import 'package:flutter/material.dart';

import '../../home/controllers/home_controller.dart';
import '../../home/models/movie.dart';
import '../../home/views/movie_detail_view.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final HomeController controller = HomeController.instance;

  final TextEditingController searchController =
      TextEditingController();

  List<Movie> ketQua = [];

  @override
  void initState() {
    super.initState();

    ketQua = controller.danhSachPhim;
  }

  void timKiem(String keyword) {
    setState(() {
      ketQua = controller.timKiemPhim(keyword);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tìm kiếm phim"),
      ),

      body: Column(
        children: [

          //----------------------------------------
          // Ô tìm kiếm
          //----------------------------------------

          Padding(
            padding: const EdgeInsets.all(15),

            child: TextField(
              controller: searchController,

              onChanged: timKiem,

              decoration: InputDecoration(
                hintText: "Nhập tên phim...",

                prefixIcon: const Icon(Icons.search),

                suffixIcon: IconButton(
                  onPressed: () {
                    searchController.clear();

                    timKiem("");
                  },

                  icon: const Icon(Icons.clear),
                ),

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
              ),
            ),
          ),

          //----------------------------------------
          // Danh sách
          //----------------------------------------

          Expanded(
            child: ketQua.isEmpty
                ? const Center(
                    child: Text(
                      "Không tìm thấy phim",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  )

                : ListView.builder(

                    itemCount: ketQua.length,

                    itemBuilder: (context, index) {

                      final movie = ketQua[index];

                      return Card(

                        margin:
                            const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 8,
                        ),

                        child: ListTile(

                          leading: ClipRRect(

                            borderRadius:
                                BorderRadius.circular(
                                    8),

                            child: Image.asset(

                              movie.hinhAnh,

                              width: 60,

                              height: 80,

                              fit: BoxFit.cover,

                            ),
                          ),

                          title: Text(movie.tenPhim),

                          subtitle: Text(
                            movie.theLoai,
                          ),

                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                          ),

                          onTap: () {

                            Navigator.push(

                              context,

                              MaterialPageRoute(

                                builder: (_) =>
                                    MovieDetailView(
                                  movie: movie,
                                ),

                              ),

                            );

                          },

                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}