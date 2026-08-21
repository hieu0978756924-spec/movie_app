import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../presentation/bloc/auth_bloc.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void _onResetPressed(BuildContext context, AuthBloc authBloc) {
    if (_formKey.currentState?.validate() ?? false) {
      authBloc.add(
        ResetPasswordSubmittedEvent(emailController.text.trim()),
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
            appBar: AppBar(
              title: const Text("Quên mật khẩu"),
            ),
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: BlocConsumer<AuthBloc, AuthState>(
                    listener: (context, state) {
                      if (state is ResetPasswordSuccessState) {
                        showDialog(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text("Đã gửi email"),
                            content: Text(state.message),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                  context.pop();
                                },
                                child: const Text("OK"),
                              ),
                            ],
                          ),
                        );
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

                      return Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.lock_reset,
                              color: AppColors.primaryRed,
                              size: 80,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Khôi phục mật khẩu",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryRed,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Nhập email của bạn để nhận liên kết đặt lại mật khẩu",
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),

                            // Email Field
                            TextFormField(
                              key: const Key('forgot_email_field'),
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              enabled: !isLoading,
                              decoration: const InputDecoration(
                                labelText: "Email đăng ký",
                                prefixIcon: Icon(Icons.email_outlined),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Vui lòng nhập email";
                                }
                                final emailRegex =
                                    RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                if (!emailRegex.hasMatch(value.trim())) {
                                  return "Email không hợp lệ";
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) =>
                                  _onResetPressed(context, authBloc),
                            ),
                            const SizedBox(height: 28),

                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                key: const Key('forgot_submit_button'),
                                onPressed: isLoading
                                    ? null
                                    : () => _onResetPressed(context, authBloc),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        "Gửi yêu cầu khôi phục",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Back to Login Button
                            TextButton(
                              key: const Key('forgot_back_to_login_button'),
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      context.pop();
                                    },
                              child: const Text(
                                "Quay lại Đăng nhập",
                                style: TextStyle(
                                  color: AppColors.primaryRed,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
