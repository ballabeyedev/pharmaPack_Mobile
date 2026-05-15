import 'package:flutter_bloc/flutter_bloc.dart';
import 'produit_event.dart';
import 'produit_state.dart';

import '../../../domain/usecases/get_produits.dart';
import '../../../domain/usecases/get_produit_detail.dart';
import '../../../domain/usecases/passer_commande.dart';

class ProduitBloc extends Bloc<ProduitEvent, ProduitState> {
  final GetProduits getProduits;
  final GetProduitDetail getProduitDetail;
  final PasserCommandeUseCase passerCommande;

  ProduitBloc({
    required this.getProduits,
    required this.getProduitDetail,
    required this.passerCommande,
  }) : super(ProduitInitial()) {
    on<LoadProduits>(_onLoadProduits);
    on<LoadProduitDetail>(_onLoadProduitDetail);
    on<PasserCommandeEvent>(_onPasserCommande);
  }

  Future<void> _onLoadProduits(
      LoadProduits event,
      Emitter<ProduitState> emit,
      ) async {
    emit(ProduitLoading());
    try {
      final produits = await getProduits();
      emit(ProduitsLoaded(produits));
    } catch (e) {
      emit(ProduitError(e.toString()));
    }
  }

  Future<void> _onLoadProduitDetail(
      LoadProduitDetail event,
      Emitter<ProduitState> emit,
      ) async {
    emit(ProduitLoading());
    try {
      final produit = await getProduitDetail(event.id);
      emit(ProduitDetailLoaded(produit));
    } catch (e) {
      emit(ProduitError(e.toString()));
    }
  }

  Future<void> _onPasserCommande(
      PasserCommandeEvent event,
      Emitter<ProduitState> emit,
      ) async {
    emit(ProduitLoading());
    try {
      await passerCommande(event.commande);
      emit(ProduitSuccess());
    } catch (e) {
      emit(ProduitError(e.toString()));
    }
  }
}