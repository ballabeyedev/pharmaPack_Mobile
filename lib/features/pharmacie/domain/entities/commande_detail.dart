class CommandeDetail {
  final String produitId;
  final String? nomProduit;
  final int quantite;
  final double prixUnitaire;
  final double prixTotal;

  CommandeDetail({
    required this.produitId,
    this.nomProduit,
    required this.quantite,
    required this.prixUnitaire,
    required this.prixTotal,
  });
}