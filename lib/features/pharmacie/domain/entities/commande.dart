import "./commande_detail.dart";

class Commande {
  final String id;
  final String reference;
  final String pharmacieId;
  final double montantTotal;
  final String statut;
  final String? adresseLivraison;
  final String modeLivraison;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? motifAnnulation;
  final List<CommandeDetail> details;

  Commande({
    required this.id,
    required this.reference,
    required this.pharmacieId,
    required this.montantTotal,
    required this.statut,
    this.adresseLivraison,
    required this.modeLivraison,
    required this.createdAt,
    this.updatedAt,
    this.motifAnnulation,
    required this.details,
  });
}