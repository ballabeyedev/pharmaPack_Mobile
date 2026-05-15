import 'package:dio/dio.dart';
import '../models/user_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(
      String identifiant,
      String motDePasse,
      );

  Future<AuthResponseModel> register({
    required String nom,
    required String prenom,
    required String email,
    required String mot_de_passe,
    required String adresse,
    required String telephone,

    // pharmacie
    required String nomPharmacie,
    required String emailPharmacie,
    required String telephonePharmacie,
    required String villePharmacie,
    required String adressePharmacie,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  final String _loginPath;
  final String _registerPath;

  AuthRemoteDataSourceImpl({required this.dio})
      : _loginPath = _normalisePath(
    dotenv.get('AUTH_LOGIN_PATH', fallback: '/auth/login'),
  ),
        _registerPath = _normalisePath(
          dotenv.get(
            'AUTH_REGISTER_PATH',
            fallback: '/pharmaPack/auth/register',
          ),
        );

  static String _normalisePath(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw StateError('Les chemins API ne peuvent pas être vides.');
    }
    return trimmed.startsWith('/') ? trimmed : '/$trimmed';
  }

  // =========================
  // 🔐 LOGIN
  // =========================
  @override
  Future<AuthResponseModel> login(
      String identifiant,
      String motDePasse,
      ) async {
    try {
      final isEmail =
      RegExp(r'\S+@\S+\.\S+').hasMatch(identifiant);

      final data = isEmail
          ? {
        'email': identifiant,
        'mot_de_passe': motDePasse,
      }
          : {
        'telephone': identifiant,
        'mot_de_passe': motDePasse,
      };

      final response = await dio.post(
        _loginPath,
        data: data,
      );

      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ LOGIN ERROR: ${e.response?.data}');
      rethrow;
    }
  }

  // =========================
  // 🟢 REGISTER (USER + PHARMACIE)
  // =========================
  @override
  Future<AuthResponseModel> register({
    required String nom,
    required String prenom,
    required String email,
    required String mot_de_passe,
    required String adresse,
    required String telephone,

    required String nomPharmacie,
    required String emailPharmacie,
    required String telephonePharmacie,
    required String villePharmacie,
    required String adressePharmacie,
  }) async {
    try {
      final data = {
        // USER
        "nom": nom,
        "prenom": prenom,
        "email": email,
        "mot_de_passe": mot_de_passe,
        "adresse": adresse,
        "telephone": telephone,
        "role": "pharmacie",

        // PHARMACIE
        "nom_pharmacie": nomPharmacie,
        "email_pharmacie": emailPharmacie,
        "telephone_pharmacie": telephonePharmacie,
        "ville_pharmacie": villePharmacie,
        "adresse_pharmacie": adressePharmacie,
      };

      final response = await dio.post(
        _registerPath,
        data: data,
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ REGISTER ERROR: ${e.response?.data}');
      rethrow;
    }
  }
}