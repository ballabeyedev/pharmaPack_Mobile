import 'package:equatable/equatable.dart';

class Pharmacie extends Equatable {
  final String id;
  final String nom;
  final String adresse;
  final String? logo;

  const Pharmacie({
    required this.id,
    required this.nom,
    required this.adresse,
    this.logo,
  });

  factory Pharmacie.fromJson(Map<String, dynamic> json) {
    return Pharmacie(
      id: json['id'].toString(),
      nom: json['nom_pharmacie'] ?? '',
      adresse: json['adresse_pharmacie'] ?? '',
      logo: json['logo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom_pharmacie': nom,
      'adresse_pharmacie': adresse,
      'logo': logo,
    };
  }

  @override
  List<Object?> get props => [id, nom, adresse, logo];
}