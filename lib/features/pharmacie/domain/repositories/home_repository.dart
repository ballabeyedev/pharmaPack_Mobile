import '../entities/commande_stats.dart';
import '../entities/commande.dart';

abstract class HomeRepository {
  Future<CommandeStats> getCommandeStats();

  Future<List<Commande>> getHistoriqueCommandes();
}