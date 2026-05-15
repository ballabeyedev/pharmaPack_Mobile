import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/services/token_service.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  // =========================
  // 🔐 LOGIN
  // =========================
  @override
  Future<Either<Failure, User>> login(
      String identifiant,
      String motDePasse,
      ) async {
    try {
      final authResponse =
      await remoteDataSource.login(identifiant, motDePasse);

      await sl<TokenService>().setToken(authResponse.token);

      await sl<FlutterSecureStorage>().write(
        key: 'user_id',
        value: authResponse.user.id,
      );

      return Right(authResponse.user);
    } on DioException catch (e) {
      return Left(ServerFailure(
        errorMessage: _handleDioError(e),
      ));
    } catch (e) {
      return Left(ServerFailure(errorMessage: e.toString()));
    }
  }

  // =========================
  // 📝 REGISTER (1 SEULE API)
  // =========================
  @override
  Future<Either<Failure, User>> register({
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
      // 🚀 UNE SEULE REQUÊTE
      final response = await remoteDataSource.register(
        nom: nom,
        prenom: prenom,
        email: email,
        mot_de_passe: mot_de_passe,
        adresse: adresse,
        telephone: telephone,
        nomPharmacie: nomPharmacie,
        emailPharmacie: emailPharmacie,
        telephonePharmacie: telephonePharmacie,
        villePharmacie: villePharmacie,
        adressePharmacie: adressePharmacie,
      );

      // 🔐 token si backend le retourne
      await sl<TokenService>().setToken(response.token);

      await sl<FlutterSecureStorage>().write(
        key: 'user_id',
        value: response.user.id,
      );

      return Right(response.user);

    } on DioException catch (e) {
      return Left(ServerFailure(
        errorMessage: _handleDioError(e),
      ));
    } catch (e) {
      return Left(ServerFailure(errorMessage: e.toString()));
    }
  }

  // =========================
  // 🧠 ERROR HANDLER
  // =========================
  String _handleDioError(DioException e) {
    if (e.response?.data is Map &&
        e.response?.data['message'] != null) {
      return e.response!.data['message'];
    }
    return e.message ?? 'Une erreur est survenue';
  }
}