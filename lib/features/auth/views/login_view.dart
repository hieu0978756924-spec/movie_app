import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injection.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/utils/user_session.dart';
import '../../profile/data/user_profile_manager.dart';
import '../presentation/bloc/auth_bloc.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool hidePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed(BuildContext context, AuthBloc authBloc) {
    if (_formKey.currentState?.validate() ?? false) {
      authBloc.add(
        LoginSubmittedEvent(
          emailController.text.trim(),
          passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) => getIt<AuthBloc>(),
      child: Builder(
        builder: (context) {
          final authBloc = context.read<AuthBloc>();
          return Scaffold(
            backgroundColor: AppColors.darkBackground,
            body: Stack(
              children: [
                // 1. Hero Cinema Backdrop Image with Dark Gradients
                Positioned.fill(
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuArjodFJ_eTrgS7gjTZ2abRhyWBgB88G4LKfXgV69TBYh3vBpn4gKkx8xf_kCZfexgoNlrlYfNGgEAMK-SP-Qd0Pk4m8UMYb9xKJ0pYXdrFGW0RJqT9C_ov6VBEtsJp_3CS9g3KgMBNszSZvk0hL9eaiie8aZQCECR0eXi22yUy1_MoKIqIoSOLD81QOTHUs_YcUd5kv95zRLB62eeqpcqZppUKqXM1WKhPOKkUaaDjmKxke38VTHJvRv0ekKWDhYrfork8rPC6O5BY',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.darkBackground,
                      );
                    },
                  ),
                ),
                // Gradient Overlays for Cinematic Atmosphere
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.darkBackground.withValues(alpha: 0.4),
                          AppColors.darkBackground.withValues(alpha: 0.85),
                          AppColors.darkBackground,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.2,
                        colors: [
                          Colors.transparent,
                          AppColors.darkBackground.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ),

                // 2. Main Scrollable Content
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 24,
                      ),
                      child: BlocConsumer<AuthBloc, AuthState>(
                        listener: (context, state) {
                          if (state is AuthenticatedState) {
                            UserSession.instance.setGuestMode(false);
                            final loggedEmail = state.user.email ?? emailController.text.trim();
                            final metaName = state.user.userMetadata?['name'] ?? state.user.userMetadata?['full_name'];
                            final nameToUse = (metaName != null && metaName.toString().isNotEmpty)
                                ? metaName.toString()
                                : null;

                            UserProfileManager.instance.updateProfile(
                              email: loggedEmail.isNotEmpty ? loggedEmail : null,
                              name: nameToUse,
                            );
                            context.go(RoutePath.home);
                          } else if (state is AuthErrorState) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.message),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        },
                        builder: (context, state) {
                          final isLoading = state is AuthLoadingState;

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // --- App Branding Header ---
                              Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: AppColors.darkSurface.withValues(alpha: 0.8),
                                  border: Border.all(
                                    color: AppColors.neonCoral.withValues(alpha: 0.3),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.neonCoral.withValues(alpha: 0.25),
                                      blurRadius: 30,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.movie_creation_rounded,
                                  color: AppColors.neonCoral,
                                  size: 48,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Góc Phim",
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                  shadows: [
                                    Shadow(
                                      color: AppColors.neonCoral.withValues(alpha: 0.5),
                                      blurRadius: 16,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Góc nhỏ dành riêng cho người yêu phim",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),

                              // --- Glassmorphism Login Card ---
                              GlassCard(
                                blur: 40,
                                borderRadius: BorderRadius.circular(24),
                                backgroundColor: Colors.white.withValues(alpha: 0.06),
                                borderColor: Colors.white.withValues(alpha: 0.12),
                                padding: const EdgeInsets.all(24),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Top Subtle Accent Line
                                      Container(
                                        height: 2,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.transparent,
                                              AppColors.neonCoral.withValues(alpha: 0.6),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        "Đăng Nhập",
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      // --- Email Label & Field ---
                                      Text(
                                        "EMAIL",
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white.withValues(alpha: 0.6),
                                          letterSpacing: 1.1,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        key: const Key('login_email_field'),
                                        controller: emailController,
                                        keyboardType: TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                        enabled: !isLoading,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: "Nhập địa chỉ email",
                                          hintStyle: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.35),
                                            fontSize: 14,
                                          ),
                                          prefixIcon: Icon(
                                            Icons.mail_outline_rounded,
                                            color: Colors.white.withValues(alpha: 0.6),
                                            size: 20,
                                          ),
                                          filled: true,
                                          fillColor: AppColors.glassInputSurface,
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                              color: Colors.white.withValues(alpha: 0.1),
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                              color: Colors.white.withValues(alpha: 0.12),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                              color: AppColors.neonCoral,
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return "Vui lòng nhập email";
                                          }
                                          final emailRegex = RegExp(
                                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                          if (!emailRegex.hasMatch(value.trim())) {
                                            return "Email không hợp lệ";
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 18),

                                      // --- Password Label, Forgot Password & Field ---
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "MẬT KHẨU",
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white.withValues(alpha: 0.6),
                                              letterSpacing: 1.1,
                                            ),
                                          ),
                                          GestureDetector(
                                            key: const Key(
                                                'login_forgot_password_button'),
                                            onTap: isLoading
                                                ? null
                                                : () {
                                                    context.push(
                                                        RoutePath.forgotPassword);
                                                  },
                                            child: const Text(
                                              "Quên mật khẩu?",
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: AppColors.accentGold,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        key: const Key('login_password_field'),
                                        controller: passwordController,
                                        obscureText: hidePassword,
                                        textInputAction: TextInputAction.done,
                                        enabled: !isLoading,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: "Nhập mật khẩu",
                                          hintStyle: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.35),
                                            fontSize: 14,
                                          ),
                                          prefixIcon: Icon(
                                            Icons.lock_outline_rounded,
                                            color: Colors.white.withValues(alpha: 0.6),
                                            size: 20,
                                          ),
                                          suffixIcon: IconButton(
                                            key: const Key(
                                                'login_toggle_password_visibility'),
                                            onPressed: () {
                                              setState(() {
                                                hidePassword = !hidePassword;
                                              });
                                            },
                                            icon: Icon(
                                              hidePassword
                                                  ? Icons.visibility_outlined
                                                  : Icons.visibility_off_outlined,
                                              color: Colors.white.withValues(alpha: 0.6),
                                              size: 20,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: AppColors.glassInputSurface,
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                              color: Colors.white.withValues(alpha: 0.1),
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                              color: Colors.white.withValues(alpha: 0.12),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                              color: AppColors.neonCoral,
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Vui lòng nhập mật khẩu";
                                          }
                                          if (value.length < 6) {
                                            return "Mật khẩu phải có ít nhất 6 ký tự";
                                          }
                                          return null;
                                        },
                                        onFieldSubmitted: (_) =>
                                            _onLoginPressed(context, authBloc),
                                      ),
                                      const SizedBox(height: 24),

                                      // --- Primary CTA Button ("Đăng Nhập") ---
                                      Container(
                                        width: double.infinity,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(14),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.neonCoral
                                                  .withValues(alpha: 0.4),
                                              blurRadius: 16,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton(
                                          key: const Key('login_submit_button'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.neonCoral,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            elevation: 0,
                                          ),
                                          onPressed: isLoading
                                              ? null
                                              : () => _onLoginPressed(
                                                    context,
                                                    authBloc,
                                                  ),
                                          child: isLoading
                                              ? const SizedBox(
                                                  height: 22,
                                                  width: 22,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2.5,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : const Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "Đăng Nhập",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    SizedBox(width: 8),
                                                    Icon(
                                                      Icons.arrow_forward_rounded,
                                                      size: 20,
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      // --- Divider "Hoặc" ---
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              height: 1,
                                              color: Colors.white.withValues(alpha: 0.12),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12),
                                            child: Text(
                                              "Hoặc",
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.white.withValues(alpha: 0.5),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              height: 1,
                                              color: Colors.white.withValues(alpha: 0.12),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),

                                      // --- Google Social Login Button ---
                                      OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          minimumSize: const Size.fromHeight(50),
                                          backgroundColor:
                                              Colors.white.withValues(alpha: 0.06),
                                          side: BorderSide(
                                            color: Colors.white.withValues(alpha: 0.15),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                        ),
                                        onPressed: isLoading
                                            ? null
                                            : () {
                                                // Trigger Google Login Event if implemented
                                              },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.network(
                                              'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/480px-Google_%22G%22_logo.svg.png',
                                              height: 20,
                                              width: 20,
                                              errorBuilder:
                                                  (context, error, stackTrace) =>
                                                      const Icon(
                                                Icons.g_mobiledata_rounded,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            const Text(
                                              "Đăng nhập bằng Google",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      // --- Guest Mode Experience Button ---
                                      OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          minimumSize: const Size.fromHeight(50),
                                          backgroundColor: AppColors.primaryRed.withAlpha(25),
                                          side: const BorderSide(
                                            color: AppColors.primaryRed,
                                            width: 1.5,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                        ),
                                        onPressed: () {
                                          UserSession.instance.setGuestMode(true);
                                          context.go(RoutePath.home);
                                        },
                                        icon: const Icon(
                                          Icons.visibility_outlined,
                                          color: AppColors.primaryRed,
                                        ),
                                        label: const Text(
                                          "Trải nghiệm Giao diện (Khách)",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // --- Register Footer Link ---
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Chưa có tài khoản? ",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withValues(alpha: 0.6),
                                    ),
                                  ),
                                  GestureDetector(
                                    key: const Key('login_register_button'),
                                    onTap: isLoading
                                        ? null
                                        : () {
                                            context.push(RoutePath.register);
                                          },
                                    child: const Text(
                                      "Đăng ký ngay",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.neonCoral,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                        decorationColor: AppColors.neonCoral,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}