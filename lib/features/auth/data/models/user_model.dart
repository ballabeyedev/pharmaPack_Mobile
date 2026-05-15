import '../../domain/entities/user.dart';
import '../../domain/entities/pharmacie.dart';


class UserModel extends User {
  const UserModel({
    required super.id,
    required super.nom,
    required super.prenom,
    required super.email,
    required super.mot_de_passe,
    required super.adresse,
    required super.telephone,
    required super.role,
    super.photo_profil,
    super.pharmacies,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    List<Pharmacie> pharmaciesList = [];

    if (json['pharmacies'] != null) {
      pharmaciesList = (json['pharmacies'] as List)
          .map((p) => Pharmacie.fromJson(p))
          .toList();
    }

    return UserModel(
      id: json['id'].toString(),
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      email: json['email'] ?? '',
      mot_de_passe: json['mot_de_passe'] ?? '',
      adresse: json['adresse'] ?? '',
      telephone: json['telephone'] ?? '',
      role: json['role'] ?? '',
      photo_profil: json['photoProfil'],
      pharmacies: pharmaciesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'mot_de_passe': mot_de_passe,
      'adresse': adresse,
      'telephone': telephone,
      'role': role,
      'photoProfil': photo_profil,
      'pharmacies': pharmacies?.map((p) => {
        'id': p.id,
        'nom_pharmacie': p.nom,
        'adresse_pharmacie': p.adresse,
        'logo': p.logo,
      }).toList(),
    };
  }
}

class AuthResponseModel {
  final String token;
  final UserModel user;

  AuthResponseModel({required this.token, required this.user});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final userData = json['utilisateur'] ?? {};

    return AuthResponseModel(
      token: json['token'] ?? '',
      user: UserModel.fromJson(userData as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'utilisateur': user.toJson(),
    };
  }
}
