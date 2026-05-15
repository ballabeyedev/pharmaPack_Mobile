import '../../domain/entities/passer_commande.dart';

class PasserCommandeModel extends PasserCommande {
  PasserCommandeModel({required super.produits});

  Map<String, dynamic> toJson() {
    return {
      "produits": produits.map((e) => {
        "produit_id": e.produitId,
        "quantite": e.quantite,
      }).toList()
    };
  }
}