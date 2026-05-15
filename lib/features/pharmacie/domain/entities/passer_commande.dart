class PasserCommande {
  final List<LigneCommande> produits;

  PasserCommande({required this.produits});
}

class LigneCommande {
  final String produitId;
  final int quantite;

  LigneCommande({
    required this.produitId,
    required this.quantite,
  });
}