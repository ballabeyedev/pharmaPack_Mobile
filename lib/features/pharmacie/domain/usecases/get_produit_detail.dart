import '../entities/produit.dart';
import '../repositories/produit_repository.dart';

class GetProduitDetail {
  final ProduitRepository repository;

  GetProduitDetail(this.repository);

  Future<Produit> call(String id) async {
    return await repository.getProduitDetail(id);
  }
}