import '../repositories/commande_repository.dart';

class AnnulerCommandeUseCase {
  final CommandeRepository repository;

  AnnulerCommandeUseCase(this.repository);

  Future<void> call(String id, String motif) {
    return repository.annulerCommande(id, motif);
  }
}