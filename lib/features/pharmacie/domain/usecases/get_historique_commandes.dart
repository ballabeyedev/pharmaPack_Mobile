import '../entities/commande.dart';
import '../repositories/home_repository.dart';

class GetHistoriqueCommandes {
  final HomeRepository repository;

  GetHistoriqueCommandes(this.repository);

  Future<List<Commande>> call() {
    return repository.getHistoriqueCommandes();
  }
}