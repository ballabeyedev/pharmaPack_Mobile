import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../bloc/commande/commande_bloc.dart';
import '../../bloc/commande/commande_event.dart';
import '../../bloc/commande/commande_state.dart';

import '../../../domain/entities/commande.dart';

import 'detail_commande_page.dart';
import '../../../domain/usecases/get_list_commande.dart';

class _C {
  static const primary = Color(0xFF06C167);
  static const dark = Color(0xFF1A2E22);
  static const white = Color(0xFFFFFFFF);
  static const bg = Color(0xFFF2FAF5);
}

class HistoriqueCommandesPage extends StatefulWidget {
  const HistoriqueCommandesPage({super.key});

  @override
  State<HistoriqueCommandesPage> createState() =>
      _HistoriqueCommandesPageState();
}

class _HistoriqueCommandesPageState extends State<HistoriqueCommandesPage> {
  String _filterStatut = "tous";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommandeBloc>().add(
            LoadCommandes(CommandeType.tout),
          );
    });
  }

  List<Commande> _applyFilter(List<Commande> list) {
    if (_filterStatut == "tous") return list;

    return list
        .where((c) => c.statut.toLowerCase() == _filterStatut)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  // ───────────────────────── HEADER ─────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(
        top: 50,
        left: 16,
        right: 16,
        bottom: 10,
      ),
      decoration: const BoxDecoration(color: _C.dark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Historique des commandes",
            style: GoogleFonts.plusJakartaSans(
              color: _C.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _chip("tous", "Tous"),
                _chip("en_attente", "En attente"),
                _chip("validee", "Validées"),
                _chip("livree", "Livrées"),
                _chip("annulee", "Annulées"),
                _chip("rejetee", "Rejetées"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── CHIP FILTER ─────────────────────────
  Widget _chip(String value, String label) {
    final selected = _filterStatut == value;

    return GestureDetector(
      onTap: () {
        setState(() => _filterStatut = value);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? _C.primary : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // ───────────────────────── BODY ─────────────────────────
  Widget _buildBody() {
    return BlocBuilder<CommandeBloc, CommandeState>(
      builder: (context, state) {
        // LOADING
        if (state is CommandeLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // SUCCESS
        if (state is CommandesLoaded) {
          final list = _applyFilter(state.commandes);

          if (list.isEmpty) {
            return const Center(
              child: Text("Aucune commande trouvée"),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _card(list[i]),
          );
        }

        // ERROR
        if (state is CommandeError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        // DEFAULT
        return const Center(child: Text("Chargement..."));
      },
    );
  }

  // ───────────────────────── CARD ─────────────────────────
  Widget _card(Commande cmd) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Commande #${cmd.reference}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${cmd.montantTotal} FCFA"),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _C.primary,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          DetailCommandePage(commande: cmd),
                    ),
                  );
                },
                child: const Text("Détail"),
              ),
            ],
          )
        ],
      ),
    );
  }
}