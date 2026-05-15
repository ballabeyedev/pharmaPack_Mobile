import '../entities/commande.dart';

abstract class CommandeRepository {
  Future<List<Commande>> getCommandesLivrees();
  Future<List<Commande>> getCommandesEnAttente();
  Future<List<Commande>> getCommandesAnnulees();
  Future<List<Commande>> getCommandesValidees();
  Future<List<Commande>> getCommandesRejetees();
  Future<List<Commande>> getAllCommandes();


  Future<Commande> getCommandeDetail(String id);
  Future<void> annulerCommande(String id);
}