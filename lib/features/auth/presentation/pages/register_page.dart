// lib/features/auth/presentation/pages/register_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:universal_go/core/utils/phone_input_formatter.dart';
import 'package:universal_go/features/auth/presentation/widgets/auth_textfield.dart';
import 'package:universal_go/shared/mixins/validation_mixin.dart';
import 'package:universal_go/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:universal_go/features/auth/presentation/bloc/auth_event.dart';
import 'package:universal_go/features/auth/presentation/bloc/auth_state.dart';
import 'package:universal_go/core/navigation/app_routes.dart';
import 'package:universal_go/features/auth/presentation/widgets/auth_field_label.dart';
import 'package:universal_go/shared/widgets/app_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with ValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController(text: '+998 ');
  final _passwordController = TextEditingController();
  final _obscurePasswordNotifier = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
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
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.sellerDashboard,
              );
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
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  "assets/images/img_universal_go_logo.png",
                  width: 100.w,
                  height: 100.h,
                ),
                SizedBox(height: 24.h),

                // Create Account title
                Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 8.h),

                // Subtitle
                Text(
                  'Sign up to start shopping from local stores',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 24.h),

                // Card Container with Shadow
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(16.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // First Name Field
                        const FieldLabel(label: 'First Name'),
                        SizedBox(height: 8.h),
                        AuthTextField(
                          controller: _firstNameController,
                          hintText: 'John',
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                          validator: (value) =>
                              validateName(value, fieldName: 'First name'),
                        ),
                        SizedBox(height: 20.h),

                        // Last Name Field
                        const FieldLabel(label: 'Last Name'),
                        SizedBox(height: 8.h),
                        AuthTextField(
                          controller: _lastNameController,
                          hintText: 'Doe',
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                          validator: (value) =>
                              validateName(value, fieldName: 'Last name'),
                        ),
                        SizedBox(height: 20.h),

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

                        // Create Account Button
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            final isLoading = state is AuthLoading;
                            return GradientButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      if (_formKey.currentState!.validate()) {
                                        final cleanPhone = _phoneController.text
                                            .replaceAll(RegExp(r'\s'), '');

                                        context.read<AuthBloc>().add(
                                              SignUpRequested(
                                                phoneNumber: cleanPhone,
                                                password:
                                                    _passwordController.text,
                                                firstName: _firstNameController
                                                    .text
                                                    .trim(),
                                                lastName: _lastNameController
                                                    .text
                                                    .trim(),
                                              ),
                                            );
                                      }
                                    },
                              title: 'Create Account',
                              isLoading: isLoading,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // Sign In Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                    child: Text(
                        'Sign in',
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
    );
  }
}
