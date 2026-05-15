import 'package:flutter/material.dart';
import 'package:pharmapack/features/auth/presentation/pages/login_page.dart';
import 'package:pharmapack/features/auth/presentation/pages/register_page.dart';
import 'package:pharmapack/features/pharmacie/presentation/pages/home/home_page.dart';
import 'package:pharmapack/features/pharmacie/presentation/pages/home/main_client_page.dart';
import 'package:pharmapack/features/auth/domain/entities/user.dart';

class AppRouter {
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String homeRoute = '/home';
  static const String pharmacieRoute = '/pharmacie';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loginRoute:
        return MaterialPageRoute(builder: (_) => LoginPage());

      case registerRoute:
        return MaterialPageRoute(builder: (_) => const RegisterPage());

      case homeRoute:
        return MaterialPageRoute(builder: (_) => const HomePage());

      case pharmacieRoute:
        final user = settings.arguments as User?;
        return MaterialPageRoute(
          builder: (_) => MainAcheteurPage(user: user),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
        );
    }
  }
}