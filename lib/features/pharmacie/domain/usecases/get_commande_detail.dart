import '../entities/commande.dart';
import '../repositories/commande_repository.dart';

class GetCommandeDetail {
  final CommandeRepository repository;

  GetCommandeDetail(this.repository);

  Future<Commande> call(String id) {
    return repository.getCommandeDetail(id);
  }
}