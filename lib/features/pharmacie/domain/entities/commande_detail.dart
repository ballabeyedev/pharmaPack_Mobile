class CommandeDetail {
  final String id;
  final String produitId;
  final String? nomProduit;
  final String? imageProduit;
  final int quantite;
  final double prixUnitaire;
  final double prixTotal;

  CommandeDetail({
    required this.id,
    required this.produitId,
    this.nomProduit,
    this.imageProduit,
    required this.quantite,
    required this.prixUnitaire,
    required this.prixTotal,
  });
}