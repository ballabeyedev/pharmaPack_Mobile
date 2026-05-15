import '../../../domain/entities/commande_stats.dart';
import '../../../domain/entities/commande.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final CommandeStats stats;
  final List<Commande> historique;
  HomeLoaded({
    required this.stats,
    required this.historique,
  });
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}