import '../entities/commande_stats.dart';
import '../repositories/home_repository.dart';

class GetCommandeStats {
  final HomeRepository repository;

  GetCommandeStats(this.repository);

  Future<CommandeStats> call() {
    return repository.getCommandeStats();
  }
}