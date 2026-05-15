import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../bloc/commande/commande_bloc.dart';
import '../../bloc/commande/commande_event.dart';
import '../../bloc/commande/commande_state.dart';
import '../../../domain/entities/commande.dart';
import '../../../domain/usecases/get_list_commande.dart';
import 'detail_commande_page.dart';

class _C {
  static const primary      = Color(0xFF06C167);
  static const primaryDark  = Color(0xFF04A355);
  static const primaryDeep  = Color(0xFF027A40);
  static const primaryLight = Color(0xFFEDFAF3);
  static const black        = Color(0xFF0D1F17);
  static const dark         = Color(0xFF1A2E22);
  static const white        = Color(0xFFFFFFFF);
  static const bg           = Color(0xFFF2FAF5);
  static const border       = Color(0xFFDDF0E6);
  static const label        = Color(0xFF7A9E87);
  static const sub          = Color(0xFF4D7A60);
  static const surface      = Color(0xFFF8FDF9);
  static const red          = Color(0xFFE53935);
  static const redLight     = Color(0xFFFFEBEE);
  static const amber        = Color(0xFFFFA000);
  static const amberLight   = Color(0xFFFFF8E1);
  static const blueLight    = Color(0xFFEBF2FF);
  static const blue         = Color(0xFF185FA5);
  static const purple       = Color(0xFF7C4DFF);
  static const purpleLight  = Color(0xFFEDE7F6);
}

// ── Définition des onglets ──────────────────────────────────────────────────
class _Tab {
  final String label;
  final CommandeType type;
  final Color color;
  final Color colorLight;
  final IconData icon;

  const _Tab({
    required this.label,
    required this.type,
    required this.color,
    required this.colorLight,
    required this.icon,
  });
}

const _tabs = [
  _Tab(label: 'Toutes',     type: CommandeType.tout,       color: _C.primary, colorLight: _C.primaryLight, icon: Icons.receipt_long_rounded),
  _Tab(label: 'En attente', type: CommandeType.enAttente,  color: _C.amber,   colorLight: _C.amberLight,   icon: Icons.hourglass_top_rounded),
  _Tab(label: 'Validées',   type: CommandeType.validees,   color: _C.blue,    colorLight: _C.blueLight,    icon: Icons.check_circle_rounded),
  _Tab(label: 'Livrées',    type: CommandeType.livrees,    color: _C.primary, colorLight: _C.primaryLight, icon: Icons.local_shipping_rounded),
  _Tab(label: 'Annulées',   type: CommandeType.annulees,   color: _C.red,     colorLight: _C.redLight,     icon: Icons.cancel_rounded),
  _Tab(label: 'Rejetées',   type: CommandeType.rejetees,   color: _C.purple,  colorLight: _C.purpleLight,  icon: Icons.block_rounded),
];

class HistoriqueCommandesPage extends StatefulWidget {
  const HistoriqueCommandesPage({super.key});

  @override
  State<HistoriqueCommandesPage> createState() => _HistoriqueCommandesPageState();
}

class _HistoriqueCommandesPageState extends State<HistoriqueCommandesPage>
    with SingleTickerProviderStateMixin {
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadTab(0);
  }

  // ── Chaque onglet appelle son propre endpoint ──────────────────────────
  void _loadTab(int index) {
    setState(() => _tabIndex = index);
    context.read<CommandeBloc>().add(LoadCommandes(_tabs[index].type));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _C.bg,
        body: Column(children: [
          _buildHeader(),
          Expanded(child: _buildBody()),
        ]),
      ),
    );
  }

  // ── HEADER ───────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_C.dark, _C.primaryDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Titre
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Mes commandes',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 22, fontWeight: FontWeight.w800,
                        color: _C.white, letterSpacing: -0.5)),
                const SizedBox(height: 2),
                BlocBuilder<CommandeBloc, CommandeState>(
                  builder: (_, state) {
                    final n = state is CommandesLoaded ? state.commandes.length : 0;
                    return Text('$n résultat${n > 1 ? 's' : ''}',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: _C.white.withOpacity(0.5),
                            fontWeight: FontWeight.w500));
                  },
                ),
              ]),
              const Spacer(),
              // Bouton refresh
              BlocBuilder<CommandeBloc, CommandeState>(
                builder: (_, state) {
                  final loading = state is CommandeLoading;
                  return GestureDetector(
                    onTap: loading ? null : () => _loadTab(_tabIndex),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: _C.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(color: _C.white.withOpacity(0.18)),
                      ),
                      child: loading
                          ? Padding(
                        padding: const EdgeInsets.all(9),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                              _C.white.withOpacity(0.7)),
                        ),
                      )
                          : const Icon(Icons.refresh_rounded,
                          size: 18, color: _C.white),
                    ),
                  );
                },
              ),
            ]),
            const SizedBox(height: 18),

            // ── Onglets scrollables ───────────────────────────────────
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_tabs.length, (i) {
                  final tab = _tabs[i];
                  final sel = _tabIndex == i;
                  return GestureDetector(
                    onTap: () => _loadTab(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8, bottom: 16),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? _C.white : _C.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: sel
                              ? _C.white
                              : _C.white.withOpacity(0.2),
                        ),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(tab.icon,
                            size: 14,
                            color: sel ? tab.color : _C.white.withOpacity(0.7)),
                        const SizedBox(width: 6),
                        Text(tab.label,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: sel
                                    ? tab.color
                                    : _C.white.withOpacity(0.7))),
                      ]),
                    ),
                  );
                }),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── BODY ─────────────────────────────────────────────────────────────────
  Widget _buildBody() {
    return BlocBuilder<CommandeBloc, CommandeState>(
      builder: (context, state) {
        if (state is CommandeLoading) return _buildLoading();
        if (state is CommandeError)   return _buildError(state.message);
        if (state is CommandesLoaded) {
          if (state.commandes.isEmpty) return _buildEmpty();
          return _buildList(state.commandes);
        }
        return const SizedBox.shrink();
      },
    );
  }

  // ── LOADING (cartes shimmer) ──────────────────────────────────────────────
  Widget _buildLoading() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => _shimmerCard(),
    );
  }

  Widget _shimmerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _shim(h: 14, w: 160),
          const Spacer(),
          _shim(h: 22, w: 80, r: 20),
        ]),
        const SizedBox(height: 14),
        _shim(h: 10, w: 120),
        const SizedBox(height: 8),
        _shim(h: 10, w: 80),
        const SizedBox(height: 14),
        Row(children: [_shim(h: 12, w: 90), const Spacer(), _shim(h: 36, w: 100, r: 12)]),
      ]),
    );
  }

  Widget _shim({required double h, double? w, double r = 6}) => Container(
      height: h, width: w,
      decoration: BoxDecoration(
          color: _C.border, borderRadius: BorderRadius.circular(r)));

  // ── ERREUR ────────────────────────────────────────────────────────────────
  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 70, height: 70,
            decoration: const BoxDecoration(
                color: _C.redLight, shape: BoxShape.circle),
            child: const Icon(Icons.error_outline_rounded,
                color: _C.red, size: 32),
          ),
          const SizedBox(height: 16),
          Text('Erreur de chargement',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 15, fontWeight: FontWeight.w700, color: _C.black)),
          const SizedBox(height: 6),
          Text(message,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12, color: _C.label),
              textAlign: TextAlign.center, maxLines: 3),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => _loadTab(_tabIndex),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [_C.primary, _C.primaryDark]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(
                    color: _C.primary.withOpacity(0.3),
                    blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.refresh_rounded, size: 16, color: _C.white),
                const SizedBox(width: 8),
                Text('Réessayer', style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, fontWeight: FontWeight.w700,
                    color: _C.white)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  // ── VIDE ──────────────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    final tab = _tabs[_tabIndex];
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
                color: tab.colorLight, shape: BoxShape.circle),
            child: Icon(tab.icon, color: tab.color, size: 36),
          ),
          const SizedBox(height: 16),
          Text('Aucune commande',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 16, fontWeight: FontWeight.w700, color: _C.black)),
          const SizedBox(height: 6),
          Text('Vous n\'avez pas encore de commandes "${tab.label.toLowerCase()}".',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, color: _C.label),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  // ── LISTE ─────────────────────────────────────────────────────────────────
  Widget _buildList(List<Commande> commandes) {
    return RefreshIndicator(
      onRefresh: () async => _loadTab(_tabIndex),
      color: _C.primary,
      backgroundColor: _C.white,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
        itemCount: commandes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _buildCard(commandes[i]),
      ),
    );
  }

  Widget _buildCard(Commande cmd) {
    final tab = _tabs[_tabIndex];
    final statutInfo = _statutInfo(cmd.statut);
    final dateStr = _formatDate(cmd.createdAt);
    final nbProduits = cmd.details.length;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, anim, __) => DetailCommandePage(commandeId: cmd.id),
          transitionsBuilder: (_, anim, __, child) => SlideTransition(
            position: Tween<Offset>(
                begin: const Offset(1, 0), end: Offset.zero)
                .animate(CurvedAnimation(
                parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 350),
        ),
      ).then((_) => _loadTab(_tabIndex)),
      child: Container(
        decoration: BoxDecoration(
          color: _C.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _C.border),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(children: [
          // ── En-tête carte ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(children: [
              // Icône onglet
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: tab.colorLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(tab.icon, color: tab.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Commande #${cmd.reference}',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13, fontWeight: FontWeight.w800,
                          color: _C.black),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Row(children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 11, color: _C.label),
                    const SizedBox(width: 4),
                    Text(dateStr,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 11, color: _C.label)),
                  ]),
                ],
              )),
              const SizedBox(width: 8),
              // Badge statut
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statutInfo.bgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: statutInfo.textColor.withOpacity(0.3)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 6, height: 6,
                    decoration: BoxDecoration(
                        color: statutInfo.textColor,
                        shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 5),
                  Text(statutInfo.label,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 10, fontWeight: FontWeight.w700,
                          color: statutInfo.textColor)),
                ]),
              ),
            ]),
          ),

          // ── Séparateur ────────────────────────────────────────────
          Container(height: 1, color: _C.border),

          // ── Infos bas ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(children: [
              // Nb produits
              _cardMeta(Icons.shopping_bag_rounded,
                  '$nbProduits produit${nbProduits > 1 ? 's' : ''}'),
              const SizedBox(width: 16),
              // Mode livraison
              _cardMeta(
                cmd.modeLivraison == 'livraison'
                    ? Icons.local_shipping_rounded
                    : Icons.storefront_rounded,
                cmd.modeLivraison == 'livraison'
                    ? 'Livraison'
                    : 'Retrait',
              ),
              const Spacer(),
              // Montant + bouton
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('${_formatPrix(cmd.montantTotal)} F CFA',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 15, fontWeight: FontWeight.w800,
                        color: _C.black, letterSpacing: -0.3)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [_C.primary, _C.primaryDark],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(
                        color: _C.primary.withOpacity(0.3),
                        blurRadius: 6, offset: const Offset(0, 2))],
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('Voir le détail',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 11, fontWeight: FontWeight.w700,
                            color: _C.white)),
                    const SizedBox(width: 5),
                    const Icon(Icons.arrow_forward_rounded,
                        size: 12, color: _C.white),
                  ]),
                ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _cardMeta(IconData icon, String text) {
    return Row(children: [
      Icon(icon, size: 13, color: _C.label),
      const SizedBox(width: 5),
      Text(text, style: GoogleFonts.plusJakartaSans(
          fontSize: 11, color: _C.label)),
    ]);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  _StatutInfo _statutInfo(String statut) {
    switch (statut.toLowerCase()) {
      case 'en_attente':
        return _StatutInfo('En attente', _C.amberLight, _C.amber);
      case 'validee':
        return _StatutInfo('Validée', _C.blueLight, _C.blue);
      case 'livree':
        return _StatutInfo('Livrée', _C.primaryLight, _C.primary);
      case 'annulee':
        return _StatutInfo('Annulée', _C.redLight, _C.red);
      case 'rejetee':
        return _StatutInfo('Rejetée', _C.purpleLight, _C.purple);
      default:
        return _StatutInfo(statut, _C.border, _C.label);
    }
  }

  String _formatDate(DateTime d) {
    final months = [
      '', 'jan', 'fév', 'mar', 'avr', 'mai', 'jun',
      'jul', 'août', 'sep', 'oct', 'nov', 'déc'
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  String _formatPrix(double prix) {
    final formatted = prix.toStringAsFixed(0);
    final buf = StringBuffer();
    int count = 0;
    for (int i = formatted.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buf.write(' ');
      buf.write(formatted[i]);
      count++;
    }
    return buf.toString().split('').reversed.join();
  }
}

class _StatutInfo {
  final String label;
  final Color bgColor;
  final Color textColor;
  const _StatutInfo(this.label, this.bgColor, this.textColor);
}