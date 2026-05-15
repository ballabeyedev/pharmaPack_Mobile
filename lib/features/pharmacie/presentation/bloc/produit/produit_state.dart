import '../../../domain/entities/produit.dart';

abstract class ProduitState {}

// 🔹 INITIAL
class ProduitInitial extends ProduitState {}

// 🔹 LOADING
class ProduitLoading extends ProduitState {}

// 🔹 LISTE PRODUITS
class ProduitsLoaded extends ProduitState {
  final List<Produit> produits;
  ProduitsLoaded(this.produits);
}

// 🔹 DETAIL PRODUIT
class ProduitDetailLoaded extends ProduitState {
  final Produit produit;
  ProduitDetailLoaded(this.produit);
}

// 🔹 SUCCESS COMMANDE
class ProduitSuccess extends ProduitState {}

// 🔹 ERROR
class ProduitError extends ProduitState {
  final String message;
  ProduitError(this.message);
}