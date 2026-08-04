import 'package:flutter/material.dart';

import 'package:movie_app/features/auth/views/register_view.dart';
import 'package:movie_app/features/home/views/home_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              const Icon(
                Icons.movie_creation,
                color: Colors.red,
                size: 90,
              ),

              const SizedBox(height: 20),

              const Text(
                "Góc Phim",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              TextField(
                controller: emailController,

                decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: passwordController,

                obscureText: hidePassword,

                decoration: InputDecoration(
                  labelText: "Mật khẩu",

                  prefixIcon: const Icon(Icons.lock),

                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        hidePassword = !hidePassword;
                      });
                    },

                    icon: Icon(
                      hidePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  onPressed: () {

                    Navigator.pushReplacement(
                      context,

                      MaterialPageRoute(
                        builder: (_) => const HomeView(),
                      ),
                    );

                  },

                  child: const Text("Đăng nhập"),
                ),
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () {

                  Navigator.push(

                    context,

                    MaterialPageRoute(
                      builder: (_) =>
                          const RegisterView(),
                    ),
                  );

                },

                child: const Text(
                  "Chưa có tài khoản? Đăng ký",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}