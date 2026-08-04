import 'package:flutter/material.dart';

import '../../favorite/views/favorite_view.dart';
import '../../profile/views/profile_view.dart';
import '../../search/views/search_view.dart';
import '../controllers/home_controller.dart';
import '../views/movie_detail_view.dart';
import '../widgets/movie_card.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = HomeController.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(
              Icons.movie_creation_rounded,
              color: Colors.red,
            ),
            SizedBox(width: 8),
            Text(
              "Góc Phim",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SearchView(),
                ),
              );
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            //---------------- Banner ----------------

            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                "assets/images/banner.jpg",
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 25),

            //---------------- Phim nổi bật ----------------

            const Text(
              "Phim nổi bật",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              height: 500,

              child: ListView.builder(
                scrollDirection: Axis.horizontal,

                itemCount: controller.danhSachPhim.length,

                itemBuilder: (context, index) {
                  return MovieCard(
                    movie: controller.danhSachPhim[index],
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            //---------------- Thể loại ----------------

            const Text(
              "Thể loại",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            const Wrap(
              spacing: 10,
              runSpacing: 10,

              children: [

                Chip(label: Text("Hành động")),
                Chip(label: Text("Marvel")),
                Chip(label: Text("Tình cảm")),
                Chip(label: Text("Hoạt hình")),
                Chip(label: Text("Gia đình")),
                Chip(label: Text("Tâm lý")),

              ],
            ),

            const SizedBox(height: 30),

            //---------------- Mới cập nhật ----------------

            const Text(
              "Mới cập nhật",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),

              itemCount: controller.danhSachPhim.length,

              itemBuilder: (context, index) {

                final movie = controller.danhSachPhim[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 15),

                  child: ListTile(

                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),

                      child: Image.asset(
                        movie.hinhAnh,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),

                    title: Text(movie.tenPhim),

                    subtitle: Text(movie.theLoai),

                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                    ),

                    onTap: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MovieDetailView(
                            movie: movie,
                          ),
                        ),
                      );

                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,

        onTap: (index) {

          if (index == 1) {

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const FavoriteView(),
              ),
            );

          }

          if (index == 2) {

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProfileView(),
              ),
            );

          }

        },

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Trang chủ",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Yêu thích",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Cá nhân",
          ),
        ],
      ),
    );
  }
}