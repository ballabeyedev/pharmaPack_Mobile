import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_commande_stats.dart';
import '../../../domain/usecases/get_historique_commandes.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetCommandeStats getStats;
  final GetHistoriqueCommandes getHistorique;

  HomeBloc({
    required this.getStats,
    required this.getHistorique,
  }) : super(HomeInitial()) {

    // ───── STATS ─────
    on<LoadHomeStats>((event, emit) async {
      emit(HomeLoading());
      try {
        final stats = await getStats();
        final historique = await getHistorique();

        emit(HomeLoaded(
          stats: stats,
          historique: historique,
        ));
      } catch (e) {
        emit(HomeError('Une erreur est survenue'));
      }
    });
  }
}