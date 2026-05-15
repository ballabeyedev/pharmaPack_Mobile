import '../../../domain/entities/commande.dart';

abstract class CommandeState {}

class CommandeInitial extends CommandeState {}

class CommandeLoading extends CommandeState {}

class CommandesLoaded extends CommandeState {
  final List<Commande> commandes;
  CommandesLoaded(this.commandes);
}

class CommandeDetailLoaded extends CommandeState {
  final Commande commande;
  CommandeDetailLoaded(this.commande);
}

class CommandeSuccess extends CommandeState {}

class CommandeError extends CommandeState {
  final String message;
  CommandeError(this.message);
}