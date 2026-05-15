import 'package:dio/dio.dart';
import '../../../../core/config/env.dart';
import '../models/commande_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<int>> fetchStats();
  Future<List<CommandeModel>> fetchHistorique();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Dio dio;

  HomeRemoteDataSourceImpl(this.dio);

  @override
  Future<List<int>> fetchStats() async {
    final responses = await Future.wait([
      dio.get(Env.commandesEnAttente),
      dio.get(Env.commandesValidees),
      dio.get(Env.commandesLivrees),
      dio.get(Env.commandesAnnulees),
      dio.get(Env.commandesRejetees),
    ]);

    return responses.map<int>((res) {
      final data = res.data;

      if (data is int) return data;

      if (data is Map) {
        final value = data.values.firstWhere(
              (v) => v is int,
          orElse: () => 0,
        );
        return value as int;
      }

      return 0;
    }).toList();
  }

  @override
  Future<List<CommandeModel>> fetchHistorique() async {
    try {
      final response = await dio.get(Env.historiqueCommandes);

      final data = response.data;

      print("DATA HISTORIQUE : $data");

      // CAS 1 : la réponse est directement une liste
      if (data is List) {
        return data
            .map((e) => CommandeModel.fromJson(e))
            .toList();
      }

      // CAS 2 : la réponse contient "commandes"
      if (data is Map && data.containsKey('commandes')) {
        return (data['commandes'] as List)
            .map((e) => CommandeModel.fromJson(e))
            .toList();
      }

      return [];
    } catch (e) {
      print('Erreur fetchHistorique: $e');
      return [];
    }
  }
}