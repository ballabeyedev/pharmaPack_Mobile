import '../../domain/entities/produit.dart';

class ProduitModel extends Produit {
  const ProduitModel({
    required super.id,
    required super.nom,
    required super.description,
    required super.prix,
    super.prixPromo,
    required super.stock,
    super.image,
    required super.dimension,
    required super.unite,
    required super.categorieNom
  });

  factory ProduitModel.fromJson(Map<String, dynamic> json) {
    return ProduitModel(
      id: json['id'].toString(),
      nom: json['nom'] ?? '',
      description: json['description'] ?? '',

      prix: double.tryParse(json['prix'].toString()) ?? 0,

      prixPromo: json['prix_promo'] != null
          ? double.tryParse(json['prix_promo'].toString())
          : null,

      stock: json['stock'] ?? 0,

      image: json['image'],

      dimension: json['dimension'] ?? '',
      unite: json['unite'] ?? '',
      categorieNom: json['categorie'] != null
          ? json['categorie']['nom'] ?? ''
          : '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'prix': prix,
      'prix_promo': prixPromo,
      'stock': stock,
      'image': image,
      'dimension': dimension,
      'unite': unite,
    };
  }
}