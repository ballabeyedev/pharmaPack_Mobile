import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUser {
  final AuthRepository repository;

  RegisterUser(this.repository);

  Future<Either<Failure, User>> call({
    // ===== USER =====
    required String nom,
    required String prenom,
    required String email,
    required String mot_de_passe,
    required String adresse,
    required String telephone,

    // ===== PHARMACIE =====
    required String nomPharmacie,
    required String emailPharmacie,
    required String telephonePharmacie,
    required String villePharmacie,
    required String adressePharmacie,

  }) async {
    return await repository.register(
      nom: nom,
      prenom: prenom,
      email: email,
      mot_de_passe: mot_de_passe,
      adresse: adresse,
      telephone: telephone,

      // 🔥 PHARMACIE
      nomPharmacie: nomPharmacie,
      emailPharmacie: emailPharmacie,
      telephonePharmacie: telephonePharmacie,
      villePharmacie: villePharmacie,
      adressePharmacie: adressePharmacie,
    );
  }
}