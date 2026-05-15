import 'package:flutter_bloc/flutter_bloc.dart';

import 'commande_event.dart';
import 'commande_state.dart';

import '../../../domain/usecases/get_list_commande.dart';
import '../../../domain/usecases/get_commande_detail.dart';
import '../../../domain/usecases/annuler_commande_usecase.dart';

class CommandeBloc extends Bloc<CommandeEvent, CommandeState> {
  final GetListCommandes getListCommandes;
  final GetCommandeDetail getCommandeDetail;
  final AnnulerCommandeUseCase annulerCommande;

  CommandeBloc({
    required this.getListCommandes,
    required this.getCommandeDetail,
    required this.annulerCommande,
  }) : super(CommandeInitial()) {

    on<LoadCommandes>(_onLoadCommandes);
    on<LoadCommandeDetail>(_onLoadCommandeDetail);
    on<AnnulerCommandeEvent>(_onAnnulerCommande);
  }

  // ─────────────────────────────
  // LISTE COMMANDES
  // ─────────────────────────────
  Future<void> _onLoadCommandes(
    LoadCommandes event,
    Emitter<CommandeState> emit,
  ) async {
    emit(CommandeLoading());
    try {
      final result = await getListCommandes(event.type);
      emit(CommandesLoaded(result));
    } catch (e) {
      emit(CommandeError(e.toString()));
    }
  }

  // ─────────────────────────────
  // DETAIL COMMANDE
  // ─────────────────────────────
  Future<void> _onLoadCommandeDetail(
    LoadCommandeDetail event,
    Emitter<CommandeState> emit,
  ) async {
    emit(CommandeLoading());
    try {
      final result = await getCommandeDetail(event.id);
      emit(CommandeDetailLoaded(result));
    } catch (e) {
      emit(CommandeError(e.toString()));
    }
  }

  // ─────────────────────────────
  // ANNULER COMMANDE
  // ─────────────────────────────
  Future<void> _onAnnulerCommande(
      AnnulerCommandeEvent event,
      Emitter<CommandeState> emit,
      ) async {
    emit(CommandeLoading());
    try {
      await annulerCommande(event.id, event.motif);
      emit(CommandeSuccess());
    } catch (e) {
      emit(CommandeError(e.toString()));
    }
  }
}