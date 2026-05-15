import '../entities/produit.dart';
import '../repositories/produit_repository.dart';

class GetProduits {
  final ProduitRepository repository;

  GetProduits(this.repository);

  Future<List<Produit>> call() async {
    return await repository.getProduits();
  }
}