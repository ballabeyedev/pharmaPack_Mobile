import '../entities/produit.dart';
import '../entities/passer_commande.dart';

abstract class ProduitRepository {
  Future<List<Produit>> getProduits();
  Future<Produit> getProduitDetail(String id);
  Future<void> passerCommande(PasserCommande commande);
}