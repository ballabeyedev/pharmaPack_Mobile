import 'package:dio/dio.dart';
import '../../../../core/config/env.dart';
import '../models/produit_model.dart';
import '../models/passer_commande_model.dart';

abstract class ProduitRemoteDataSource {
  Future<List<ProduitModel>> fetchProduits();
  Future<ProduitModel> fetchProduitDetail(String id);
  Future<void> passerCommande(PasserCommandeModel commande);
}

class ProduitRemoteDataSourceImpl implements ProduitRemoteDataSource {
  final Dio dio;

  ProduitRemoteDataSourceImpl(this.dio);

  // ✅ LISTE DES PRODUITS
  @override
  Future<List<ProduitModel>> fetchProduits() async {
    try {
      final response = await dio.get(Env.produits);

      final data = response.data;

      if (data is Map && data['produits'] != null) {
        return (data['produits'] as List)
            .map((e) => ProduitModel.fromJson(
          Map<String, dynamic>.from(e),
        ))
            .toList();
      }

      return [];
    } catch (e) {
      print('Erreur fetchProduits: $e');
      return [];
    }
  }

  // ✅ DÉTAIL PRODUIT
  @override
  Future<ProduitModel> fetchProduitDetail(String id) async {
    try {
      final response = await dio.get("${Env.produitDetail}/$id");
      final data = response.data;

      if (data is Map && data['produit'] != null) {
        return ProduitModel.fromJson(
          Map<String, dynamic>.from(data['produit']),
        );
      }

      throw Exception("Produit non trouvé");
    } catch (e) {
      print('Erreur fetchProduitDetail: $e');
      throw Exception("Erreur lors du chargement du produit");
    }
  }

  @override
  Future<void> passerCommande(PasserCommandeModel commande) async {
    try {
      await dio.post(
        Env.passerCommande,
        data: commande.toJson(),
      );
    } catch (e) {
      print("Erreur passerCommande: $e");
      throw Exception("Erreur lors de la commande");
    }
  }
}