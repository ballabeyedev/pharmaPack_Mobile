import '../entities/commande.dart';
import '../repositories/commande_repository.dart';

enum CommandeType {
  tout,
  livrees,
  enAttente,
  annulees,
  validees,
  rejetees,
}

class GetListCommandes {
  final CommandeRepository repository;

  GetListCommandes(this.repository);

  Future<List<Commande>> call(CommandeType type) {
    switch (type) {
      case CommandeType.livrees:
        return repository.getCommandesLivrees();
      case CommandeType.enAttente:
        return repository.getCommandesEnAttente();
      case CommandeType.annulees:
        return repository.getCommandesAnnulees();
      case CommandeType.validees:
        return repository.getCommandesValidees();
      case CommandeType.rejetees:
        return repository.getCommandesRejetees();
      case CommandeType.tout:
        return repository.getAllCommandes();
    }
  }
}