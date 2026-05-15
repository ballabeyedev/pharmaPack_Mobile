import '../../domain/entities/commande.dart';
import '../../domain/repositories/commande_repository.dart';
import '../datasources/commande_remote_datasource.dart';

class CommandeRepositoryImpl implements CommandeRepository {
  final CommandeRemoteDataSource remoteDataSource;

  CommandeRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Commande>> getCommandesLivrees() async {
    final result = await remoteDataSource.fetchCommandesLivrees();
    return result;
  }

  @override
  Future<List<Commande>> getCommandesEnAttente() async {
    final result = await remoteDataSource.fetchCommandesEnAttente();
    return result;
  }

  @override
  Future<List<Commande>> getCommandesAnnulees() async {
    final result = await remoteDataSource.fetchCommandesAnnulees();
    return result;
  }

  @override
  Future<List<Commande>> getCommandesValidees() async {
    final result = await remoteDataSource.fetchCommandesValidees();
    return result;
  }

  @override
  Future<List<Commande>> getCommandesRejetees() async {
    final result = await remoteDataSource.fetchCommandesRejetees();
    return result;
  }

  @override
  Future<List<Commande>> getAllCommandes() async {
    final result = await remoteDataSource.fetchAllCommandes();
    return result;
  }

  @override
  Future<Commande> getCommandeDetail(String id) async {
    final result = await remoteDataSource.fetchCommandeDetail(id);
    return result;
  }

  @override
  Future<void> annulerCommande(String id, String motif) async {
    await remoteDataSource.annulerCommande(id, motif);
  }
}