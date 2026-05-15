import '../../../domain/entities/commande.dart';
import '../../../domain/usecases/get_list_commande.dart';

abstract class CommandeEvent {}

class LoadCommandes extends CommandeEvent {
  final CommandeType type;
  LoadCommandes(this.type);
}

class LoadCommandeDetail extends CommandeEvent {
  final String id;
  LoadCommandeDetail(this.id);
}

class AnnulerCommandeEvent extends CommandeEvent {
  final String id;
  final String motif;
  AnnulerCommandeEvent(this.id, {required this.motif});
}