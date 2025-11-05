import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:universal_go/core/utils/phone_input_formatter.dart';
import 'package:universal_go/features/auth/presentation/widgets/auth_textfield.dart';
import 'package:universal_go/shared/mixins/validation_mixin.dart';
import 'package:universal_go/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:universal_go/features/auth/presentation/bloc/auth_state.dart';
import 'package:universal_go/core/navigation/app_routes.dart';
import 'package:universal_go/features/auth/presentation/widgets/auth_field_label.dart';
import 'package:universal_go/shared/widgets/app_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with ValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController(text: '+998 ');
  final _passwordController = TextEditingController();
  final _obscurePasswordNotifier = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _obscurePasswordNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            if (state.user.role == 'customer') {
              Navigator.pushReplacementNamed(context, AppRoutes.customerHome);
            } else if (state.user.role == 'seller') {
              Navigator.pushReplacementNamed(context, AppRoutes.sellerHome);
            }
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    "assets/images/img_universal_go_logo.png",
                    width: 100.w,
                    height: 100.h,
                  ),
                  SizedBox(height: 32.h),

                  // Welcome Back title
                  Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Subtitle
                  Text(
                    'Enter your credentials to access your account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Card Container with Shadow
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(24.w),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Phone Field
                          const FieldLabel(label: 'Phone Number'),
                          SizedBox(height: 8.h),
                          AuthTextField(
                            controller: _phoneController,
                            hintText: '+998 XX XXX XX XX',
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              UzbekPhoneInputFormatter(),
                              LengthLimitingTextInputFormatter(17),
                            ],
                            validator: validateUzbekPhone,
                            maxLength: 17,
                          ),
                          SizedBox(height: 20.h),

                          // Password Field
                          const FieldLabel(label: 'Password'),
                          SizedBox(height: 8.h),
                          AuthPasswordField(
                            controller: _passwordController,
                            hintText: '••••••••',
                            obscureTextNotifier: _obscurePasswordNotifier,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 24.h),

                          // Sign In Button
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              final isLoading = state is AuthLoading;
                              return GradientButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          AppRoutes.chooseRole,
                                        );

                                        // if (_formKey.currentState!.validate()) {
                                        //   final cleanPhone = _phoneController.text
                                        //       .replaceAll(RegExp(r'\s'), '');

                                        //   context.read<AuthBloc>().add(
                                        //         SignInRequested(
                                        //           phoneNumber: cleanPhone,
                                        //           password: _passwordController.text,
                                        //         ),
                                        //       );
                                        // }
                                      },
                                title: 'Sign In',
                                isLoading: isLoading,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account? ',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.register);
                        },
                        child: Text(
                          'Sign up',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
