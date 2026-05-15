import 'package:equatable/equatable.dart';

class Produit extends Equatable {
  final String id;
  final String nom;
  final String description;
  final double prix;
  final double? prixPromo;
  final int stock;
  final String? image;
  final String dimension;
  final String unite;
  final String categorieNom;

  const Produit({
    required this.id,
    required this.nom,
    required this.description,
    required this.prix,
    this.prixPromo,
    required this.stock,
    this.image,
    required this.dimension,
    required this.unite,
    required this.categorieNom
  });

  @override
  List<Object?> get props => [
    id,
    nom,
    description,
    prix,
    prixPromo,
    stock,
    image,
    dimension,
    unite,
    categorieNom
  ];
}