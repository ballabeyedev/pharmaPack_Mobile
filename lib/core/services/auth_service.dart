import 'package:flutter/material.dart';
import 'token_service.dart';

class AuthService {
  final TokenService tokenService;
  final GlobalKey<NavigatorState> navigatorKey;

  AuthService({
    required this.tokenService,
    required this.navigatorKey,
  });

  Future<void> logout() async {
    await tokenService.clearToken();

    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/login',
          (route) => false,
    );
  }
}