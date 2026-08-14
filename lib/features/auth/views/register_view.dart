import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injection.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/user_session.dart';
import '../../../core/widgets/glass_card.dart';
import '../../profile/data/user_profile_manager.dart';
import '../presentation/bloc/auth_bloc.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  bool hidePassword = true;
  bool hideConfirmPassword = true;

  @override
  void dispose() {
    nameController.dispose();
    dobController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  void _onRegisterPressed(BuildContext context, AuthBloc authBloc) {
    if (_formKey.currentState?.validate() ?? false) {
      final name = nameController.text.trim();
      final dob = dobController.text.trim();
      final email = emailController.text.trim();

      UserProfileManager.instance.updateProfile(
        name: name.isNotEmpty ? name : null,
        dob: dob.isNotEmpty ? dob : null,
        email: email.isNotEmpty ? email : null,
      );

      authBloc.add(
        RegisterSubmittedEvent(
          email,
          passwordController.text,
          name: name,
          dob: dob,
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
                          if (state is RegisterSuccessState) {
                            UserSession.instance.setGuestMode(false);
                            UserProfileManager.instance.updateProfile(
                              name: nameController.text.trim().isNotEmpty ? nameController.text.trim() : null,
                              dob: dobController.text.trim().isNotEmpty ? dobController.text.trim() : null,
                              email: emailController.text.trim().isNotEmpty ? emailController.text.trim() : null,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.message),
                                backgroundColor: AppColors.success,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                            context.go(RoutePath.login);
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
                              // App Branding Header
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  color: AppColors.darkSurface.withValues(alpha: 0.8),
                                  border: Border.all(
                                    color: AppColors.neonCoral.withValues(alpha: 0.3),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.neonCoral.withValues(alpha: 0.25),
                                      blurRadius: 24,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.person_add_alt_1_rounded,
                                  color: AppColors.neonCoral,
                                  size: 38,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "Tạo Tài Khoản",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Đăng ký để khám phá hàng ngàn bộ phim hay",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),

                              // Glassmorphism Register Card
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
                                      // Accent line
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

                                      // Full Name Field
                                      Text(
                                        "HỌ VÀ TÊN",
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white.withValues(alpha: 0.6),
                                          letterSpacing: 1.1,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        key: const Key('register_name_field'),
                                        controller: nameController,
                                        enabled: !isLoading,
                                        style: const TextStyle(color: Colors.white, fontSize: 15),
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return "Vui lòng nhập họ và tên";
                                          }
                                          if (value.trim().length < 2) {
                                            return "Họ và tên phải có ít nhất 2 ký tự";
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          hintText: "Nhập họ và tên của bạn",
                                          hintStyle: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.35),
                                            fontSize: 14,
                                          ),
                                          prefixIcon: Icon(
                                            Icons.person_outline_rounded,
                                            color: Colors.white.withValues(alpha: 0.6),
                                            size: 20,
                                          ),
                                          filled: true,
                                          fillColor: AppColors.glassInputSurface,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(14),
                                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(14),
                                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(14),
                                            borderSide: const BorderSide(color: AppColors.neonCoral, width: 1.5),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Date of Birth Field
                                      Text(
                                        "NGÀY THÁNG NĂM SINH",
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white.withValues(alpha: 0.6),
                                          letterSpacing: 1.1,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        key: const Key('register_dob_field'),
                                        controller: dobController,
                                        readOnly: true,
                                        enabled: !isLoading,
                                        style: const TextStyle(color: Colors.white, fontSize: 15),
                                        onTap: () async {
                                          final pickedDate = await showDatePicker(
                                            context: context,
                                            initialDate: DateTime(2000, 1, 1),
                                            firstDate: DateTime(1930),
                                            lastDate: DateTime.now(),
                                            builder: (context, child) {
                                              return Theme(
                                                data: Theme.of(context).copyWith(
                                                  colorScheme: const ColorScheme.dark(
                                                    primary: AppColors.neonCoral,
                                                    onPrimary: Colors.white,
                                                    surface: AppColors.darkSurface,
                                                    onSurface: Colors.white,
                                                  ),
                                                ),
                                                child: child!,
                                              );
                                            },
                                          );
                                          if (pickedDate != null) {
                                            dobController.text =
                                                "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
                                          }
                                        },
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return "Vui lòng chọn ngày tháng năm sinh";
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          hintText: "DD/MM/YYYY (Nhấn chọn ngày sinh)",
                                          hintStyle: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.35),
                                            fontSize: 14,
                                          ),
                                          prefixIcon: Icon(
                                            Icons.calendar_today_outlined,
                                            color: Colors.white.withValues(alpha: 0.6),
                                            size: 20,
                                          ),
                                          suffixIcon: Icon(
                                            Icons.arrow_drop_down_rounded,
                                            color: Colors.white.withValues(alpha: 0.6),
                                            size: 24,
                                          ),
                                          filled: true,
                                          fillColor: AppColors.glassInputSurface,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(14),
                                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(14),
                                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(14),
                                            borderSide: const BorderSide(color: AppColors.neonCoral, width: 1.5),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Email Field
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
                                        key: const Key('register_email_field'),
                                        controller: emailController,
                                        keyboardType: TextInputType.emailAddress,
                                        enabled: !isLoading,
                                        style: const TextStyle(color: Colors.white, fontSize: 15),
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return "Vui lòng nhập địa chỉ email";
                                          }
                                          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                          if (!emailRegex.hasMatch(value.trim())) {
                                            return "Email không đúng định dạng (vd: name@domain.com)";
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          hintText: "Nhập địa chỉ email của bạn",
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
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(14),
                                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(14),
                                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(14),
                                            borderSide: const BorderSide(color: AppColors.neonCoral, width: 1.5),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Password Field
                                      Text(
                                        "MẬT KHẨU",
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white.withValues(alpha: 0.6),
                                          letterSpacing: 1.1,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        key: const Key('register_password_field'),
                                        controller: passwordController,
                                        obscureText: hidePassword,
                                        enabled: !isLoading,
                                        style: const TextStyle(color: Colors.white, fontSize: 15),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Vui lòng nhập mật khẩu";
                                          }
                                          if (value.length < 6) {
                                            return "Mật khẩu phải từ 6 ký tự trở lên";
                                          }
                                          final hasLetter = value.contains(RegExp(r'[a-zA-Z]'));
                                          final hasDigits = value.contains(RegExp(r'[0-9]'));
                                          if (!hasLetter || !hasDigits) {
                                            return "Mật khẩu bảo mật phải chứa cả chữ và số";
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          hintText: "Ít nhất 6 ký tự",
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
                                            icon: Icon(
                                              hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                              color: Colors.white.withValues(alpha: 0.6),
                                              size: 20,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                hidePassword = !hidePassword;
                                              });
                                            },
                                          ),
                                          filled: true,
                                          fillColor: AppColors.glassInputSurface,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(14),
                                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(14),
                                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(14),
                                            borderSide: const BorderSide(color: AppColors.neonCoral, width: 1.5),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Confirm Password Field
                                      Text(
                                        "NHẬP LẠI MẬT KHẨU",
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white.withValues(alpha: 0.6),
                                          letterSpacing: 1.1,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        key: const Key('register_confirm_password_field'),
                                        controller: confirmController,
                                        obscureText: hideConfirmPassword,
                                        enabled: !isLoading,
                                        style: const TextStyle(color: Colors.white, fontSize: 15),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Vui lòng xác nhận mật khẩu";
                                          }
                                          if (value != passwordController.text) {
                                            return "Mật khẩu không khớp";
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          hintText: "Xác nhận lại mật khẩu",
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
                                            icon: Icon(
                                              hideConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                              color: Colors.white.withValues(alpha: 0.6),
                                              size: 20,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                hideConfirmPassword = !hideConfirmPassword;
                                              });
                                            },
                                          ),
                                          filled: true,
                                          fillColor: AppColors.glassInputSurface,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(14),
                                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(14),
                                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(14),
                                            borderSide: const BorderSide(color: AppColors.neonCoral, width: 1.5),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),

                                      // Submit Button
                                      SizedBox(
                                        width: double.infinity,
                                        height: 52,
                                        child: ElevatedButton(
                                          key: const Key('register_submit_button'),
                                          onPressed: isLoading ? null : () => _onRegisterPressed(context, authBloc),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.neonCoral,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(14),
                                            ),
                                            elevation: 8,
                                            shadowColor: AppColors.neonCoral.withValues(alpha: 0.4),
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
                                              : const Text(
                                                  "Tạo Tài Khoản",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Back to Login Link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Đã có tài khoản? ",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withValues(alpha: 0.6),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: isLoading
                                        ? null
                                        : () {
                                            context.pop();
                                          },
                                    child: const Text(
                                      "Đăng nhập ngay",
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