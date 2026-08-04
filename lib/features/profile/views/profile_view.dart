import 'package:flutter/material.dart';
import 'package:movie_app/features/auth/views/login_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text("Cá nhân"),
      ),

      body: SingleChildScrollView(

        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(

            children: [

              //-----------------------------------------
              // AVATAR
              //-----------------------------------------

              const CircleAvatar(
                radius: 60,
                backgroundImage:
                    AssetImage("assets/images/avatar.jpg"),
              ),

              const SizedBox(height: 20),

              //-----------------------------------------
              // TÊN
              //-----------------------------------------

              const Text(
                "Nguyễn Ngọc Như Hiếu",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "nhuhieu@gmail.com",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 35),

              //-----------------------------------------
              // THÔNG TIN
              //-----------------------------------------

              Card(

                child: Column(

                  children: [

                    ListTile(

                      leading: const Icon(
                        Icons.person,
                        color: Colors.red,
                      ),

                      title: const Text(
                        "Thông tin cá nhân",
                      ),

                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                      ),

                      onTap: () {},

                    ),

                    const Divider(height: 1),

                    ListTile(

                      leading: const Icon(
                        Icons.favorite,
                        color: Colors.red,
                      ),

                      title: const Text(
                        "Phim yêu thích",
                      ),

                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                      ),

                      onTap: () {},

                    ),

                    const Divider(height: 1),

                    ListTile(

                      leading: const Icon(
                        Icons.settings,
                        color: Colors.red,
                      ),

                      title: const Text(
                        "Cài đặt",
                      ),

                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                      ),

                      onTap: () {},

                    ),

                  ],
                ),
              ),

              const SizedBox(height: 25),

              //-----------------------------------------
              // ĐĂNG XUẤT
              //-----------------------------------------

              SizedBox(

                width: double.infinity,

                child: ElevatedButton.icon(

                  onPressed: () {

                    Navigator.pushReplacement(

                      context,

                      MaterialPageRoute(

                        builder: (_) =>
                            const LoginView(),

                      ),

                    );

                  },

                  icon: const Icon(Icons.logout),

                  label: const Text(
                    "Đăng xuất",
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}