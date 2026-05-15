import 'package:equatable/equatable.dart';
import './pharmacie.dart';

class User extends Equatable {
  final String id;
  final String nom;
  final String prenom;
  final String email;
  final String mot_de_passe;
  final String adresse;
  final String telephone;
  final String? photo_profil;
  final String role;

  final List<Pharmacie>? pharmacies;


  const User({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.mot_de_passe,
    required this.adresse,
    required this.telephone,
    required this.role,
    this.photo_profil,
    this.pharmacies,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'prenom': prenom,
    'email': email,
    'mot_de_passe': mot_de_passe,
    'adresse': adresse,
    'telephone': telephone,
    'photoProfil': photo_profil,
    'role': role,
    'pharmacies': pharmacies?.map((p) => {
      'id': p.id,
      'nom_pharmacie': p.nom,
      'adresse_pharmacie': p.adresse,
      'logo': p.logo,
    }).toList(),

  };

  @override
  List<Object?> get props => [id, nom, prenom, email, telephone, photo_profil, role, pharmacies ];
}
