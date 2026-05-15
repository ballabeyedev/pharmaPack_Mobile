import 'package:dio/dio.dart';
import '../services/token_service.dart';
import '../config/env.dart';

class DioClient {
  final Dio dio;

  DioClient(TokenService tokenService)
      : dio = Dio(BaseOptions(
    baseUrl: Env.baseUrl,
    connectTimeout: const Duration(seconds: 15),
  )) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }
}