import '../../../domain/entities/passer_commande.dart';

abstract class ProduitEvent {}

// 🔹 LISTE PRODUITS
class LoadProduits extends ProduitEvent {}

// 🔹 DETAIL PRODUIT
class LoadProduitDetail extends ProduitEvent {
  final String id;
  LoadProduitDetail(this.id);
}

// 🔹 PASSER COMMANDE
class PasserCommandeEvent extends ProduitEvent {
  final PasserCommande commande;

  PasserCommandeEvent(this.commande);
}