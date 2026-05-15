import '../../domain/entities/commande.dart';
import 'commande_detail_model.dart';

class CommandeModel extends Commande {
  CommandeModel({
    required super.id,
    required super.reference,
    required super.pharmacieId,
    required super.montantTotal,
    required super.statut,
    super.adresseLivraison,
    required super.modeLivraison,
    required super.createdAt,
    required super.details,
  });

  factory CommandeModel.fromJson(Map<String, dynamic> json) {
    return CommandeModel(
      id: json['id'] ?? '',

      // 🔥 IMPORTANT : backend doit envoyer "reference"
      reference: json['reference'] ?? '',

      pharmacieId: json['pharmacie_id'] ?? '',
      montantTotal: double.tryParse(json['montant_total'].toString()) ?? 0.0,
      statut: json['statut'] ?? 'en_attente',
      adresseLivraison: json['adresse_livraison'],
      modeLivraison: json['mode_livraison'] ?? 'livraison',

      // 🔥 backend Sequelize = createdAt (PAS created_at)
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),

      // 🔥 DETAILS PRODUITS
      details: json['details'] != null
          ? (json['details'] as List)
          .map((e) => CommandeDetailModel.fromJson(e))
          .toList()
          : [],
    );
  }
}