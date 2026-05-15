import '../../domain/entities/produit.dart';
import '../../domain/repositories/produit_repository.dart';
import '../datasources/produit_remote_datasource.dart';
import '../../domain/entities/passer_commande.dart';
import '../models/passer_commande_model.dart';

class ProduitRepositoryImpl implements ProduitRepository {
  final ProduitRemoteDataSource remoteDataSource;

  ProduitRepositoryImpl(this.remoteDataSource);

  // ✅ LISTE PRODUITS
  @override
  Future<List<Produit>> getProduits() async {
    return await remoteDataSource.fetchProduits();
  }

  // ✅ DÉTAIL PRODUIT
  @override
  Future<Produit> getProduitDetail(String id) async {
    return await remoteDataSource.fetchProduitDetail(id);
  }

  @override
  Future<void> passerCommande(PasserCommande commande) async {
    final model = PasserCommandeModel(produits: commande.produits);
    await remoteDataSource.passerCommande(model);
  }
}