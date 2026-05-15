import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Palette ──────────────────────────────────────────────────────────────────
class _C {
  static const primary      = Color(0xFF06C167);
  static const primaryDark  = Color(0xFF04A355);
  static const primaryDeep  = Color(0xFF027A40);
  static const primaryLight = Color(0xFFEDFAF3);
  static const primaryMid   = Color(0xFFB3F0D1);
  static const black        = Color(0xFF0D1F17);
  static const dark         = Color(0xFF1A2E22);
  static const white        = Color(0xFFFFFFFF);
  static const bg           = Color(0xFFF2FAF5);
  static const border       = Color(0xFFDDF0E6);
  static const label        = Color(0xFF7A9E87);
  static const sub          = Color(0xFF4D7A60);
  static const red          = Color(0xFFE53935);
  static const redLight     = Color(0xFFFFEBEE);
  static const amber        = Color(0xFFFF9800);
  static const amberLight   = Color(0xFFFFF3E0);
  static const blue         = Color(0xFF1A56DB);
  static const blueLight    = Color(0xFFEBF2FF);
}

// ─── MODÈLES MOCKUP ───────────────────────────────────────────────────────────
enum _AvoirStatut { disponible, utilise, expire }

class _Avoir {
  final String        id;
  final String        reference;
  final double        montant;
  final double        montantRestant;
  final _AvoirStatut  statut;
  final DateTime      dateCreation;
  final DateTime?     dateExpiration;
  final String        motif;
  final String?       commandeRef;

  const _Avoir({
    required this.id,
    required this.reference,
    required this.montant,
    required this.montantRestant,
    required this.statut,
    required this.dateCreation,
    this.dateExpiration,
    required this.motif,
    this.commandeRef,
  });
}

class _Utilisation {
  final String   avoirRef;
  final double   montantUtilise;
  final DateTime date;
  final String   commandeRef;

  const _Utilisation({
    required this.avoirRef,
    required this.montantUtilise,
    required this.date,
    required this.commandeRef,
  });
}

// ─── DONNÉES MOCKUP ───────────────────────────────────────────────────────────
final List<_Avoir> _mockAvoirs = [
  _Avoir(
    id: '1',
    reference: 'AV-2025-001',
    montant: 15000,
    montantRestant: 15000,
    statut: _AvoirStatut.disponible,
    dateCreation: DateTime(2025, 4, 10),
    dateExpiration: DateTime(2025, 7, 10),
    motif: 'Remboursement commande annulée',
    commandeRef: 'CMD-001',
  ),
  _Avoir(
    id: '2',
    reference: 'AV-2025-002',
    montant: 8500,
    montantRestant: 3500,
    statut: _AvoirStatut.disponible,
    dateCreation: DateTime(2025, 3, 22),
    dateExpiration: DateTime(2025, 6, 22),
    motif: 'Geste commercial — retard livraison',
    commandeRef: 'CMD-002',
  ),
  _Avoir(
    id: '3',
    reference: 'AV-2025-003',
    montant: 5000,
    montantRestant: 0,
    statut: _AvoirStatut.utilise,
    dateCreation: DateTime(2025, 2, 5),
    motif: 'Remboursement produit défectueux',
    commandeRef: 'CMD-003',
  ),
  _Avoir(
    id: '4',
    reference: 'AV-2024-015',
    montant: 12000,
    montantRestant: 12000,
    statut: _AvoirStatut.expire,
    dateCreation: DateTime(2024, 10, 1),
    dateExpiration: DateTime(2025, 1, 1),
    motif: 'Remboursement commande partielle',
    commandeRef: 'CMD-004',
  ),
];

final List<_Utilisation> _mockHistorique = [
  _Utilisation(
    avoirRef: 'AV-2025-002',
    montantUtilise: 5000,
    date: DateTime(2025, 4, 1),
    commandeRef: 'CMD-010',
  ),
  _Utilisation(
    avoirRef: 'AV-2025-003',
    montantUtilise: 5000,
    date: DateTime(2025, 3, 15),
    commandeRef: 'CMD-008',
  ),
];

// ─── PAGE AVOIRS ──────────────────────────────────────────────────────────────
class AvoirsPage extends StatefulWidget {
  const AvoirsPage({super.key});

  @override
  State<AvoirsPage> createState() => _AvoirsPageState();
}

class _AvoirsPageState extends State<AvoirsPage> with TickerProviderStateMixin {

  late AnimationController _headerCtrl;
  late AnimationController _contentCtrl;
  late Animation<double>   _headerFade;
  late Animation<Offset>   _headerSlide;
  late Animation<double>   _contentFade;

  // Onglet actif : 0 = Mes avoirs  |  1 = Historique
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();

    _headerCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
    _contentCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    _headerFade  = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.04), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic));
    _contentFade = CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut);

    _headerCtrl.forward();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _contentCtrl.forward();
    });
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String _formatDate(DateTime d) {
    const mois = ['jan.','fév.','mar.','avr.','mai','jun.',
      'jul.','aoû.','sep.','oct.','nov.','déc.'];
    return '${d.day} ${mois[d.month - 1]} ${d.year}';
  }

  String _formatMontant(double m) {
    final s = m.toStringAsFixed(0);
    final buf = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buf.write(' ');
      buf.write(s[i]);
      count++;
    }
    return buf.toString().split('').reversed.join();
  }

  double get _totalDisponible => _mockAvoirs
      .where((a) => a.statut == _AvoirStatut.disponible)
      .fold(0, (s, a) => s + a.montantRestant);

  int get _nbDisponibles =>
      _mockAvoirs.where((a) => a.statut == _AvoirStatut.disponible).length;

  // Couleurs & labels statut
  Color  _statutColor(_AvoirStatut s) => switch (s) {
    _AvoirStatut.disponible => _C.primary,
    _AvoirStatut.utilise    => _C.blue,
    _AvoirStatut.expire     => _C.red,
  };

  Color  _statutBg(_AvoirStatut s) => switch (s) {
    _AvoirStatut.disponible => _C.primaryLight,
    _AvoirStatut.utilise    => _C.blueLight,
    _AvoirStatut.expire     => _C.redLight,
  };

  IconData _statutIcon(_AvoirStatut s) => switch (s) {
    _AvoirStatut.disponible => Icons.check_circle_rounded,
    _AvoirStatut.utilise    => Icons.done_all_rounded,
    _AvoirStatut.expire     => Icons.timer_off_rounded,
  };

  String _statutLabel(_AvoirStatut s) => switch (s) {
    _AvoirStatut.disponible => 'Disponible',
    _AvoirStatut.utilise    => 'Utilisé',
    _AvoirStatut.expire     => 'Expiré',
  };

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _C.bg,
        body: Column(children: [
          FadeTransition(
            opacity: _headerFade,
            child: SlideTransition(position: _headerSlide, child: _buildHeader()),
          ),
          Expanded(
            child: FadeTransition(opacity: _contentFade, child: _buildContent()),
          ),
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HEADER
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_C.dark, _C.primaryDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(children: [
        Positioned(top: -40, right: -20,  child: _circle(160, _C.primary.withOpacity(0.10))),
        Positioned(top: 30,  right: 55,   child: _circle(70,  _C.primary.withOpacity(0.07))),
        Positioned(bottom: -30, left: -20,child: _circle(110, _C.primary.withOpacity(0.06))),

        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // ── Titre + retour ──
              Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: _C.white.withOpacity(0.09),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: _C.white.withOpacity(0.14)),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 16, color: _C.white),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      'Mes Avoirs',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20, fontWeight: FontWeight.w800,
                        color: _C.white, letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Crédits & remboursements',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, color: _C.white.withOpacity(0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ]),
                ),
                // Badge nb disponibles
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _C.primary.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _C.primary.withOpacity(0.35)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 6, height: 6,
                      decoration: const BoxDecoration(
                          color: _C.primary, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '$_nbDisponibles dispo.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11, fontWeight: FontWeight.w700,
                        color: _C.primary,
                      ),
                    ),
                  ]),
                ),
              ]),

              const SizedBox(height: 20),

              // ── Bannière solde total ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _C.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _C.white.withOpacity(0.12)),
                ),
                child: Row(children: [
                  // Icône wallet
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_C.primary, _C.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(
                        color: _C.primary.withOpacity(0.3),
                        blurRadius: 10, offset: const Offset(0, 4),
                      )],
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded,
                        color: _C.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        'Solde disponible',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12, color: _C.white.withOpacity(0.55),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text(
                          _formatMontant(_totalDisponible),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 30, fontWeight: FontWeight.w800,
                            color: _C.white, letterSpacing: -1.0,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4, left: 6),
                          child: Text(
                            'FCFA',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13, color: _C.white.withOpacity(0.55),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 4),
                      Text(
                        'Sur $_nbDisponibles avoir${_nbDisponibles > 1 ? 's' : ''} actif${_nbDisponibles > 1 ? 's' : ''}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11, color: _C.white.withOpacity(0.4),
                        ),
                      ),
                    ]),
                  ),
                  // Info avantage
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _headerPill(
                        Icons.shield_rounded,
                        'Sécurisé',
                        _C.primary,
                      ),
                      const SizedBox(height: 6),
                      _headerPill(
                        Icons.flash_on_rounded,
                        'Utilisable\nimmédiatement',
                        _C.amber,
                      ),
                    ],
                  ),
                ]),
              ),

              const SizedBox(height: 16),

              // ── Avantages rapides ──
              Row(children: [
                _avantageChip(Icons.percent_rounded,   'Sans frais'),
                const SizedBox(width: 8),
                _avantageChip(Icons.timer_rounded,     'Valable 3 mois'),
                const SizedBox(width: 8),
                _avantageChip(Icons.local_offer_rounded, 'Cumulable'),
              ]),

              const SizedBox(height: 16),

              // ── Onglets Mes avoirs / Historique ──
              Row(children: [
                _tab(0, 'Mes avoirs',  Icons.account_balance_wallet_outlined),
                const SizedBox(width: 8),
                _tab(1, 'Historique',  Icons.history_rounded),
              ]),

              const SizedBox(height: 16),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _headerPill(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 9, fontWeight: FontWeight.w700, color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ]),
    );
  }

  Widget _avantageChip(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: _C.white.withOpacity(0.09),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _C.white.withOpacity(0.14)),
        ),
        child: Column(children: [
          Icon(icon, size: 14, color: _C.primary),
          const SizedBox(height: 3),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9, fontWeight: FontWeight.w600,
              color: _C.white.withOpacity(0.7),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _tab(int index, String label, IconData icon) {
    final sel = _tabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _tabIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? _C.white : _C.white.withOpacity(0.09),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: sel ? _C.white : _C.white.withOpacity(0.15),
          ),
          boxShadow: sel
              ? [BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8, offset: const Offset(0, 2),
          )]
              : [],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14,
              color: sel ? _C.primary : _C.white.withOpacity(0.55)),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12, fontWeight: FontWeight.w700,
              color: sel ? _C.primary : _C.white.withOpacity(0.55),
            ),
          ),
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CONTENU
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.05, 0),
            end: Offset.zero,
          ).animate(anim),
          child: child,
        ),
      ),
      child: _tabIndex == 0
          ? _buildAvoirsList(key: const ValueKey('avoirs'))
          : _buildHistorique(key: const ValueKey('historique')),
    );
  }

  // ── Liste avoirs ──────────────────────────────────────────────────────────
  Widget _buildAvoirsList({Key? key}) {
    return ListView(
      key: key,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 40),
      children: [
        // ── Bloc explication ──
        _buildInfoBanner(),
        const SizedBox(height: 16),

        // ── Avoirs groupés par statut ──
        ..._buildGroupedAvoirs(),
      ],
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _C.primaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
      ),
      child: Row(children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: _C.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(Icons.info_outline_rounded,
              color: _C.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              'Comment utiliser un avoir ?',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12, fontWeight: FontWeight.w700, color: _C.black,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Lors de votre prochaine commande, votre avoir sera automatiquement déduit du montant total.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11, color: _C.sub, height: 1.4,
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  List<Widget> _buildGroupedAvoirs() {
    final disponibles = _mockAvoirs
        .where((a) => a.statut == _AvoirStatut.disponible).toList();
    final utilises = _mockAvoirs
        .where((a) => a.statut == _AvoirStatut.utilise).toList();
    final expires = _mockAvoirs
        .where((a) => a.statut == _AvoirStatut.expire).toList();

    final widgets = <Widget>[];

    if (disponibles.isNotEmpty) {
      widgets.add(_groupTitle(
        'Disponibles', _C.primary, _C.primaryLight,
        Icons.check_circle_rounded, disponibles.length,
      ));
      widgets.add(const SizedBox(height: 10));
      for (final a in disponibles) {
        widgets.add(_buildAvoirCard(a));
        widgets.add(const SizedBox(height: 10));
      }
    }

    if (utilises.isNotEmpty) {
      widgets.add(const SizedBox(height: 6));
      widgets.add(_groupTitle(
        'Utilisés', _C.blue, _C.blueLight,
        Icons.done_all_rounded, utilises.length,
      ));
      widgets.add(const SizedBox(height: 10));
      for (final a in utilises) {
        widgets.add(_buildAvoirCard(a));
        widgets.add(const SizedBox(height: 10));
      }
    }

    if (expires.isNotEmpty) {
      widgets.add(const SizedBox(height: 6));
      widgets.add(_groupTitle(
        'Expirés', _C.red, _C.redLight,
        Icons.timer_off_rounded, expires.length,
      ));
      widgets.add(const SizedBox(height: 10));
      for (final a in expires) {
        widgets.add(_buildAvoirCard(a));
        widgets.add(const SizedBox(height: 10));
      }
    }

    return widgets;
  }

  Widget _groupTitle(
      String label, Color color, Color bg, IconData icon, int count) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            '$label  ($count)',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12, fontWeight: FontWeight.w700, color: color,
            ),
          ),
        ]),
      ),
    ]);
  }

  // ── Carte avoir ────────────────────────────────────────────────────────────
  Widget _buildAvoirCard(_Avoir avoir) {
    final color  = _statutColor(avoir.statut);
    final bg     = _statutBg(avoir.statut);
    final icon   = _statutIcon(avoir.statut);
    final label  = _statutLabel(avoir.statut);
    final isDispo = avoir.statut == _AvoirStatut.disponible;

    // Progression montant restant
    final progress = avoir.montant > 0
        ? (avoir.montantRestant / avoir.montant).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDispo ? _C.primary.withOpacity(0.25) : _C.border,
          width: isDispo ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDispo
                ? _C.primary.withOpacity(0.08)
                : Colors.black.withOpacity(0.03),
            blurRadius: 12, offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: [

        // ── Header carte ──
        Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          decoration: BoxDecoration(
            color: bg.withOpacity(isDispo ? 0.6 : 0.4),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(children: [
            // Icône statut
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: _C.white,
                borderRadius: BorderRadius.circular(11),
                boxShadow: [BoxShadow(
                  color: color.withOpacity(0.12),
                  blurRadius: 6, offset: const Offset(0, 2),
                )],
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  avoir.reference,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800, fontSize: 13, color: _C.black,
                  ),
                ),
                const SizedBox(height: 2),
                Row(children: [
                  const Icon(Icons.calendar_today_rounded,
                      size: 10, color: _C.label),
                  const SizedBox(width: 3),
                  Text(
                    _formatDate(avoir.dateCreation),
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 11, color: _C.label),
                  ),
                ]),
              ]),
            ),
            // Badge statut
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.25)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 6, height: 6,
                  decoration: BoxDecoration(
                      color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11, color: color, fontWeight: FontWeight.w700,
                  ),
                ),
              ]),
            ),
          ]),
        ),

        // ── Corps ──
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Montant principal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    'Montant initial',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 11, color: _C.label),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_formatMontant(avoir.montant)} FCFA',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16, fontWeight: FontWeight.w700, color: _C.black,
                    ),
                  ),
                ]),
                if (isDispo) ...[
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(
                      'Reste à utiliser',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 11, color: _C.label),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_formatMontant(avoir.montantRestant)} FCFA',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18, fontWeight: FontWeight.w800,
                        color: _C.primary, letterSpacing: -0.5,
                      ),
                    ),
                  ]),
                ],
              ],
            ),

            // Barre de progression (si pas expiré)
            if (avoir.statut != _AvoirStatut.expire) ...[
              const SizedBox(height: 12),
              Stack(children: [
                Container(
                  height: 7,
                  decoration: BoxDecoration(
                    color: _C.border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 7,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.6)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(progress * 100).round()}% restant',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 10, color: _C.label),
                  ),
                  Text(
                    '${_formatMontant(avoir.montant - avoir.montantRestant)} FCFA utilisés',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 10, color: _C.label),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 12),

            // Motif
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: _C.bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _C.border),
              ),
              child: Row(children: [
                const Icon(Icons.receipt_outlined,
                    size: 13, color: _C.label),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    avoir.motif,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5, color: _C.sub,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ]),
            ),
          ]),
        ),

        // ── Pied : expiration + commande liée ──
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
          child: Column(children: [
            // Séparateur pointillés
            Row(children: List.generate(60, (_) => Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                height: 1, color: _C.border,
              ),
            ))),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Commande liée
                if (avoir.commandeRef != null)
                  Row(children: [
                    const Icon(Icons.link_rounded, size: 12, color: _C.label),
                    const SizedBox(width: 4),
                    Text(
                      avoir.commandeRef!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11, color: _C.label,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ])
                else
                  const SizedBox.shrink(),

                // Date expiration
                if (avoir.dateExpiration != null)
                  Row(children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 12,
                      color: avoir.statut == _AvoirStatut.expire
                          ? _C.red
                          : _C.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      avoir.statut == _AvoirStatut.expire
                          ? 'Expiré le ${_formatDate(avoir.dateExpiration!)}'
                          : 'Expire le ${_formatDate(avoir.dateExpiration!)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: avoir.statut == _AvoirStatut.expire
                            ? _C.red
                            : _C.amber,
                      ),
                    ),
                  ])
                else
                  const SizedBox.shrink(),
              ],
            ),
          ]),
        ),
      ]),
    );
  }

  // ── Historique des utilisations ───────────────────────────────────────────
  Widget _buildHistorique({Key? key}) {
    return _mockHistorique.isEmpty
        ? _buildEmptyHistorique(key: key)
        : ListView(
      key: key,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 40),
      children: [
        // Résumé total utilisé
        _buildHistoriqueResume(),
        const SizedBox(height: 16),
        // Titre
        Row(children: [
          Container(
            width: 4, height: 18,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_C.primary, _C.primaryDark],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Détail des utilisations',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15, fontWeight: FontWeight.w800, color: _C.black,
            ),
          ),
        ]),
        const SizedBox(height: 12),
        ..._mockHistorique.map(_buildHistoriqueCard),
      ],
    );
  }

  Widget _buildHistoriqueResume() {
    final totalUtilise = _mockHistorique.fold(
        0.0, (s, u) => s + u.montantUtilise);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_C.dark, _C.primaryDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
          color: _C.primaryDeep.withOpacity(0.3),
          blurRadius: 14, offset: const Offset(0, 5),
        )],
      ),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: _C.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _C.primary.withOpacity(0.25)),
          ),
          child: const Icon(Icons.history_rounded,
              color: _C.primary, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              'Total utilisé',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11, color: _C.white.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '${_formatMontant(totalUtilise)} FCFA',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22, fontWeight: FontWeight.w800,
                color: _C.white, letterSpacing: -0.5,
              ),
            ),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _C.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _C.primary.withOpacity(0.25)),
          ),
          child: Text(
            '${_mockHistorique.length} transaction${_mockHistorique.length > 1 ? 's' : ''}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11, fontWeight: FontWeight.w700, color: _C.primary,
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildHistoriqueCard(_Utilisation u) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 8, offset: const Offset(0, 2),
        )],
      ),
      child: Row(children: [
        // Icône
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: _C.blueLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.shopping_bag_rounded,
              color: _C.blue, size: 18),
        ),
        const SizedBox(width: 12),
        // Infos
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              u.commandeRef,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13, fontWeight: FontWeight.w700, color: _C.black,
              ),
            ),
            const SizedBox(height: 3),
            Row(children: [
              const Icon(Icons.link_rounded, size: 11, color: _C.label),
              const SizedBox(width: 3),
              Text(
                u.avoirRef,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 11, color: _C.label),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.calendar_today_rounded,
                  size: 11, color: _C.label),
              const SizedBox(width: 3),
              Text(
                _formatDate(u.date),
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 11, color: _C.label),
              ),
            ]),
          ]),
        ),
        // Montant
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(
            '-${_formatMontant(u.montantUtilise)}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15, fontWeight: FontWeight.w800, color: _C.blue,
              letterSpacing: -0.3,
            ),
          ),
          Text(
            'FCFA',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 10, color: _C.label),
          ),
        ]),
      ]),
    );
  }

  Widget _buildEmptyHistorique({Key? key}) {
    return Center(
      key: key,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 80, height: 80,
            decoration: const BoxDecoration(
                color: _C.primaryLight, shape: BoxShape.circle),
            child: const Icon(Icons.history_rounded,
                color: _C.primary, size: 36),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune utilisation',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16, fontWeight: FontWeight.w700, color: _C.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Vos utilisations d\'avoirs apparaîtront ici',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 13, color: _C.label),
            textAlign: TextAlign.center,
          ),
        ]),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _circle(double size, Color color) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );
}