import '../../domain/entities/commande_detail.dart';


class CommandeDetailModel extends CommandeDetail {
  CommandeDetailModel({
    required super.produitId,
    super.nomProduit,
    required super.quantite,
    required super.prixUnitaire,
    required super.prixTotal,
  });

  factory CommandeDetailModel.fromJson(Map<String, dynamic> json) {
    return CommandeDetailModel(
      produitId: json['produit_id'] ?? '',
      nomProduit: json['produit']?['nom'] ?? 'Produit',
      quantite: json['quantite'] ?? 0,
      prixUnitaire: double.tryParse(json['prix_unitaire'].toString()) ?? 0,
      prixTotal: double.tryParse(json['prix_total'].toString()) ?? 0,
    );
  }
}