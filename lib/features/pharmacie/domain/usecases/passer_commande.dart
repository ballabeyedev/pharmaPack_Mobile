import '../entities/passer_commande.dart';
import '../repositories/produit_repository.dart';

class PasserCommandeUseCase {
  final ProduitRepository repository;

  PasserCommandeUseCase(this.repository);

  Future<void> call(PasserCommande commande) {
    return repository.passerCommande(commande);
  }
}