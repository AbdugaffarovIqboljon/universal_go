import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:universal_go/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:universal_go/injection_container.dart';
import 'package:universal_go/config/theme/app_theme.dart';
import 'package:universal_go/core/navigation/app_router.dart';
import 'package:universal_go/core/navigation/app_routes.dart';
import 'package:universal_go/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:universal_go/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:universal_go/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:universal_go/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:universal_go/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:universal_go/core/providers/theme_provider.dart';


class UniversalGoApp extends StatelessWidget {
  const UniversalGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            signInUseCase: SignInUseCase(sl<AuthRepositoryImpl>()),
            signUpUseCase: SignUpUseCase(sl<AuthRepositoryImpl>()),
            getCurrentUserUseCase: GetCurrentUserUseCase(sl<AuthRepositoryImpl>()),
            signOutUseCase: SignOutUseCase(sl<AuthRepositoryImpl>()),
          ),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (context, child) {
          return Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                title: 'Universal Go',
                theme: lightTheme,
                darkTheme: darkTheme,
                themeMode: themeProvider.themeMode,
                onGenerateRoute: AppRouter.generateRoute,
                initialRoute: AppRoutes.splash,
                debugShowCheckedModeBanner: false,
              );
            },
          );
        },
      ),
    );
  }
}