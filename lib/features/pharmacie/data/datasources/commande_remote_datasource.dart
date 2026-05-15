import 'package:dio/dio.dart';
import '../../../../core/config/env.dart';
import '../models/commande_model.dart';

abstract class CommandeRemoteDataSource {
  Future<List<CommandeModel>> fetchCommandesLivrees();
  Future<List<CommandeModel>> fetchCommandesEnAttente();
  Future<List<CommandeModel>> fetchCommandesAnnulees();
  Future<List<CommandeModel>> fetchCommandesValidees();
  Future<List<CommandeModel>> fetchCommandesRejetees();
  Future <CommandeModel> fetchCommandeDetail(String id);
  Future<void> annulerCommande(String id, String motif);
  Future<List<CommandeModel>> fetchAllCommandes();
}

class CommandeRemoteDataSourceImpl implements CommandeRemoteDataSource {
  final Dio dio;

  CommandeRemoteDataSourceImpl(this.dio);

  // ✅ LISTE DES COMMANDES LIVREES
  @override
  Future<List<CommandeModel>> fetchCommandesLivrees() async {
    try {
      final response = await dio.get(Env.commandeLivree);

      final data = response.data;

      if (data is Map && data['commandes'] != null) {
        return (data['commandes'] as List)
            .map((e) => CommandeModel.fromJson(
          Map<String, dynamic>.from(e),
        ))
            .toList();
      }

      return [];
    } catch (e) {
       throw Exception('Erreur fetchCommandesLivrees');
    }
  }

  // ✅ LISTE DES COMMANDES EN ATTENTE 
  @override
  Future<List<CommandeModel>> fetchCommandesEnAttente() async {
    try {
      final response = await dio.get(Env.commandeEnAttente);

      final data = response.data;

      if (data is Map && data['commandes'] != null) {
        return (data['commandes'] as List)
            .map((e) => CommandeModel.fromJson(
          Map<String, dynamic>.from(e),
        ))
            .toList();
      }

      return [];
    } catch (e) {
      throw Exception('Erreur fetchCommandesEnAttente');
    }
  }

// ✅ LISTE DES COMMANDES ANNULEES
  @override
  Future<List<CommandeModel>> fetchCommandesAnnulees() async {
    try {
      final response = await dio.get(Env.commandeAnnulee);

      final data = response.data;

      if (data is Map && data['commandes'] != null) {
        return (data['commandes'] as List)
            .map((e) => CommandeModel.fromJson(
          Map<String, dynamic>.from(e),
        ))
            .toList();
      }

      return [];
    } catch (e) {
      throw Exception('Erreur fetchCommandesAnnulees');
    }
  }

  // ✅ LISTE DES COMMANDES VALIDEES
  @override
  Future<List<CommandeModel>> fetchCommandesValidees() async {
    try {
      final response = await dio.get(Env.commandeValidee);

      final data = response.data;

      if (data is Map && data['commandes'] != null) {
        return (data['commandes'] as List)
            .map((e) => CommandeModel.fromJson(
          Map<String, dynamic>.from(e),
        ))
            .toList();
      }

      return [];
    } catch (e) {
      throw Exception('Erreur fetchCommandesValidees');
    }
  }

  // ✅ LISTE DES COMMANDES REJETEE
  @override
  Future<List<CommandeModel>> fetchCommandesRejetees() async {
    try {
      final response = await dio.get(Env.commandeRejetee);

      final data = response.data;

      if (data is Map && data['commandes'] != null) {
        return (data['commandes'] as List)
            .map((e) => CommandeModel.fromJson(
          Map<String, dynamic>.from(e),
        ))
            .toList();
      }

      return [];
    } catch (e) {
      throw Exception('Erreur fetchCommandesRejetees');
    }
  }

  // ✅ LISTE DE TOUTES LES COMMANDES
  @override
  Future<List<CommandeModel>> fetchAllCommandes() async {
    try {
      final response = await dio.get(Env.allCommande);

      final data = response.data;

      if (data is Map && data['commandes'] != null) {
        return (data['commandes'] as List)
            .map((e) => CommandeModel.fromJson(
          Map<String, dynamic>.from(e),
        ))
            .toList();
      }

      return [];
    } catch (e) {
      throw Exception('Erreur fetchAllCommandes');
    }
  }


  // ✅ DÉTAIL COMMANDE
  @override
  Future<CommandeModel> fetchCommandeDetail(String id) async {
    try {
      final response = await dio.get("${Env.commandeDetail}/$id");
      final data = response.data;

      if (data is Map && data['commande'] != null) {
        return CommandeModel.fromJson(
          Map<String, dynamic>.from(data['commande']),
        );
      }

      throw Exception("Commande non trouvé");
    } catch (e) {
      throw Exception('Erreur fetchCommandeDetail');
    }
  }

  // ✅ ANNULER UNE COMMANDE
  @override
  Future<void> annulerCommande(String id, String motif) async {
    try {
      await dio.patch(
        "${Env.annulerCommande}/$id",
        data: {
          "motifAnnulation": motif,
        },
      );
    } catch (e) {
      throw Exception('Erreur annulerCommande');
    }
  }
}