import '../../domain/entities/commande.dart';
import '../../domain/entities/commande_stats.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';
import '../models/commande_stats_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl(this.remoteDataSource);

  @override
  Future<CommandeStats> getCommandeStats() async {
    final data = await remoteDataSource.fetchStats();
    return CommandeStatsModel.fromList(data);
  }

  @override
  Future<List<Commande>> getHistoriqueCommandes() async {
    return await remoteDataSource.fetchHistorique();
  }
}