import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharmapack/features/auth/domain/entities/user.dart';
import 'package:pharmapack/features/auth/domain/entities/pharmacie.dart';
import '../../bloc/home/home_bloc.dart';
import '../../bloc/home/home_event.dart';
import '../../bloc/home/home_state.dart';
import '../../../domain/entities/commande_stats.dart';
import '../../../domain/entities/commande.dart';
import 'package:pharmapack/core/utils/commande_utils.dart';

// ─── Palette ──────────────────────────────────────────────────────────────────
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
  static const red          = Color(0xFFE53935);
  static const redLight     = Color(0xFFFFEBEE);
  static const amber        = Color(0xFFFF9800);
  static const amberLight   = Color(0xFFFFF3E0);
  static const blue         = Color(0xFF1A56DB);
  static const blueLight    = Color(0xFFEBF2FF);
  static const orange       = Color(0xFFEA580C);
  static const orangeLight  = Color(0xFFFFF7ED);
}

// ─── HOME PAGE ────────────────────────────────────────────────────────────────
class HomePage extends StatefulWidget {
  final User? user;
  const HomePage({super.key, this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _headerCtrl;
  late AnimationController _contentCtrl;
  late Animation<double>   _headerFade;
  late Animation<Offset>   _headerSlide;
  late Animation<double>   _contentFade;

  @override
  void initState() {
    super.initState();

    _headerCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _contentCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    _headerFade  = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.04), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic));
    _contentFade = CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut);

    _headerCtrl.forward();
    Future.delayed(const Duration(milliseconds: 180), () {
      if (mounted) _contentCtrl.forward();
    });

    context.read<HomeBloc>().add(LoadHomeStats());
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  /// Retourne la première [Pharmacie] de l'utilisateur, ou null si absente.
  Pharmacie? get _pharmacie {
    final list = widget.user?.pharmacies;
    if (list != null && list.isNotEmpty) return list.first;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Nom complet de l'utilisateur (prenom + nom)
    final prenomStr = widget.user?.prenom ?? '';
    final nomStr    = widget.user?.nom    ?? '';
    final nomComplet = '$prenomStr $nomStr'.trim();
    final email      = widget.user?.email ?? '';
    final initiales  = _buildInitiales(prenomStr, nomStr);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _C.bg,
        body: RefreshIndicator(
          onRefresh: () async {
            context.read<HomeBloc>().add(LoadHomeStats());
            await Future.delayed(const Duration(milliseconds: 300));
          },
          color: _C.primary,
          backgroundColor: _C.white,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            slivers: [
              // ── Header ────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _headerFade,
                  child: SlideTransition(
                    position: _headerSlide,
                    child: _buildHeader(
                      nomComplet: nomComplet.isEmpty ? 'Utilisateur' : nomComplet,
                      email:      email,
                      initiales:  initiales,
                      pharmacie:  _pharmacie,
                    ),
                  ),
                ),
              ),
              // ── Corps ─────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _contentFade,
                  child: _buildBody(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HEADER
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildHeader({
    required String    nomComplet,
    required String    email,
    required String    initiales,
    required Pharmacie? pharmacie,
  }) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_C.dark, _C.primaryDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Cercles décoratifs
          Positioned(top: -50, right: -30,
              child: _circle(180, _C.primary.withOpacity(0.10))),
          Positioned(top: 40, right: 60,
              child: _circle(80, _C.primary.withOpacity(0.07))),
          Positioned(bottom: -20, left: -30,
              child: _circle(130, _C.primary.withOpacity(0.06))),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Ligne 1 : avatar + nom/email + pharmacie + notif ───
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar
                      _buildAvatar(initiales),
                      const SizedBox(width: 12),

                      // Nom + email
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nomComplet,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: _C.white,
                                letterSpacing: -0.4,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              email,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: _C.white.withOpacity(0.55),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Bloc pharmacie OU cloche seule
                      if (pharmacie != null)
                        _buildPharmacieBloc(pharmacie)
                      else
                        _buildNotifButton(),
                    ],
                  ),

                  // ── Ligne 2 : adresse pharmacie + cloche (si pharmacie) ─
                  if (pharmacie != null) ...[
                    const SizedBox(height: 12),
                    Divider(color: _C.white.withOpacity(0.08), thickness: 1, height: 1),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Pill adresse
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 5),
                            decoration: BoxDecoration(
                              color: _C.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: _C.primary.withOpacity(0.25)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.location_on_rounded,
                                    size: 11, color: _C.primary),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    pharmacie.adresse.isNotEmpty
                                        ? pharmacie.adresse
                                        : 'Adresse non renseignée',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: _C.primary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        _buildNotifButton(),
                      ],
                    ),
                  ],

                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Avatar utilisateur ────────────────────────────────────────────────────
  Widget _buildAvatar(String initiales) {
    final photoUrl = widget.user?.photo_profil;
    final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;

    return Container(
      width: 46, height: 46,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_C.primary, _C.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.primary.withOpacity(0.4), width: 1.5),
      ),
      child: hasPhoto
          ? ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Image.network(
          photoUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _initialesText(initiales),
        ),
      )
          : _initialesText(initiales),
    );
  }

  Widget _initialesText(String initiales) {
    return Center(
      child: Text(
        initiales,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 15, fontWeight: FontWeight.w800, color: _C.white,
        ),
      ),
    );
  }

  // ── Bloc pharmacie (coin droit header) ────────────────────────────────────
  Widget _buildPharmacieBloc(Pharmacie pharmacie) {
    final hasLogo = pharmacie.logo != null && pharmacie.logo!.isNotEmpty;

    return Container(
      constraints: const BoxConstraints(maxWidth: 148),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _C.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.white.withOpacity(0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mini logo
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: _C.primary.withOpacity(0.20),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: _C.primary.withOpacity(0.3)),
              image: hasLogo
                  ? DecorationImage(
                image: NetworkImage(pharmacie.logo!),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: hasLogo
                ? null
                : const Icon(Icons.local_pharmacy_rounded,
                size: 15, color: _C.primary),
          ),
          const SizedBox(width: 8),
          // Nom + statut
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pharmacie.nom.isNotEmpty ? pharmacie.nom : 'Ma pharmacie',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: _C.white,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 5, height: 5,
                    decoration: const BoxDecoration(
                        color: _C.primary, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    'En ligne',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: _C.primary,
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Bouton notification ───────────────────────────────────────────────────
  Widget _buildNotifButton() {
    return Stack(
      children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: _C.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: _C.white.withOpacity(0.12)),
          ),
          child: const Icon(Icons.notifications_outlined,
              size: 19, color: _C.white),
        ),
        Positioned(
          top: 7, right: 7,
          child: Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFFFF5722),
              shape: BoxShape.circle,
              border: Border.all(color: _C.dark, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // ── Cercle décoratif helper ───────────────────────────────────────────────
  Widget _circle(double size, Color color) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CORPS — BlocBuilder
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildBody() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, state),
            if (state is HomeLoading)
              _buildLoadingState()
            else if (state is HomeError)
              _buildErrorState(context, state.message)
            else if (state is HomeLoaded)
                Column(children: [
                  _buildStatsContent(state.stats),
                  _buildHistoriqueSection(state.historique),
                ])
              else
                _buildLoadingState(),
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }

  // ── En-tête section ───────────────────────────────────────────────────────
  Widget _buildSectionHeader(BuildContext context, HomeState state) {
    final isLoading = state is HomeLoading;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(children: [
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
          'Suivi des commandes',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16, fontWeight: FontWeight.w800, color: _C.black,
          ),
        ),
        const Spacer(),
        if (isLoading)
          SizedBox(
            width: 16, height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2, color: _C.primary.withOpacity(0.6),
            ),
          )
        else
          GestureDetector(
            onTap: () => context.read<HomeBloc>().add(LoadHomeStats()),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _C.primaryLight,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.refresh_rounded, size: 12, color: _C.primary),
                const SizedBox(width: 4),
                Text(
                  'Actualiser',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10, fontWeight: FontWeight.w600, color: _C.primary,
                  ),
                ),
              ]),
            ),
          ),
      ]),
    );
  }

  // ── Loading shimmer ───────────────────────────────────────────────────────
  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(children: [
        _shimmerBox(height: 94, radius: 20),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _shimmerBox(height: 80, radius: 18)),
          const SizedBox(width: 12),
          Expanded(child: _shimmerBox(height: 80, radius: 18)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _shimmerBox(height: 80, radius: 18)),
          const SizedBox(width: 12),
          Expanded(child: _shimmerBox(height: 80, radius: 18)),
        ]),
        const SizedBox(height: 12),
        _shimmerBox(height: 70, radius: 18),
      ]),
    );
  }

  Widget _shimmerBox({required double height, double radius = 12}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: _C.border,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  // ── Erreur ────────────────────────────────────────────────────────────────
  Widget _buildErrorState(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _C.redLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.red.withOpacity(0.2)),
        ),
        child: Column(children: [
          const Icon(Icons.error_outline_rounded, color: _C.red, size: 36),
          const SizedBox(height: 10),
          Text(
            'Impossible de charger les statistiques',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13, fontWeight: FontWeight.w600, color: _C.red,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 11, color: _C.red.withOpacity(0.7)),
            textAlign: TextAlign.center,
            maxLines: 2, overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => context.read<HomeBloc>().add(LoadHomeStats()),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [_C.primary, _C.primaryDark]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Réessayer',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _C.white,
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STATS
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildStatsContent(CommandeStats stats) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(children: [
        _buildTotalBanner(stats),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _buildStatCard(
            label: 'En attente', value: stats.enAttente,
            icon: Icons.hourglass_top_rounded,
            color: _C.amber, bg: _C.amberLight,
            hasBadge: stats.enAttente > 0,
          )),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard(
            label: 'Validées', value: stats.validees,
            icon: Icons.check_circle_outline_rounded,
            color: _C.primary, bg: _C.primaryLight,
          )),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _buildStatCard(
            label: 'Livrées', value: stats.livrees,
            icon: Icons.local_shipping_rounded,
            color: _C.blue, bg: _C.blueLight,
          )),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard(
            label: 'Annulées', value: stats.annulees,
            icon: Icons.cancel_outlined,
            color: _C.orange, bg: _C.orangeLight,
          )),
        ]),
        const SizedBox(height: 12),
        _buildRejeteesCard(stats.rejetees),
      ]),
    );
  }

  // ── Bannière Total ────────────────────────────────────────────────────────
  Widget _buildTotalBanner(CommandeStats stats) {
    final total = stats.enAttente + stats.validees + stats.livrees
        + stats.annulees + stats.rejetees;
    final pct = total > 0
        ? ((stats.livrees / total) * 100).round()
        : 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_C.dark, _C.primaryDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _C.primaryDeep.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(children: [
        Positioned(right: -20, top: -20,
            child: _circle(100, _C.primary.withOpacity(0.10))),
        Positioned(right: 28, bottom: -30,
            child: _circle(65, _C.primary.withOpacity(0.08))),
        Row(children: [
          Container(
            width: 54, height: 54,
            decoration: BoxDecoration(
              color: _C.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _C.primary.withOpacity(0.25)),
            ),
            child: const Icon(Icons.shopping_bag_rounded,
                color: _C.primary, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total des commandes',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: _C.white.withOpacity(0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$total',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: _C.white,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Toutes périodes confondues',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: _C.white.withOpacity(0.35),
                  ),
                ),
              ],
            ),
          ),
          if (total > 0)
            SizedBox(
              width: 54, height: 54,
              child: CustomPaint(
                painter: _DonutPainter(stats: stats, total: total),
                child: Center(
                  child: Text(
                    '$pct%',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: _C.white,
                    ),
                  ),
                ),
              ),
            ),
        ]),
      ]),
    );
  }

  // ── Carte stat ────────────────────────────────────────────────────────────
  Widget _buildStatCard({
    required String   label,
    required int      value,
    required IconData icon,
    required Color    color,
    required Color    bg,
    bool              hasBadge = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasBadge ? color.withOpacity(0.3) : _C.border,
          width: hasBadge ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(children: [
        Stack(clipBehavior: Clip.none, children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
                color: bg, borderRadius: BorderRadius.circular(13)),
            child: Icon(icon, size: 21, color: color),
          ),
          if (hasBadge)
            Positioned(
              top: -3, right: -3,
              child: Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                  color: color, shape: BoxShape.circle,
                  border: Border.all(color: _C.white, width: 2),
                ),
              ),
            ),
        ]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$value',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _C.black,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: _C.label,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 26, height: 26,
          decoration: BoxDecoration(
              color: bg, borderRadius: BorderRadius.circular(8)),
          child: Icon(Icons.arrow_forward_ios_rounded, size: 11, color: color),
        ),
      ]),
    );
  }

  // ── Carte Rejetées ────────────────────────────────────────────────────────
  Widget _buildRejeteesCard(int rejetees) {
    final hasAlert = rejetees > 0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasAlert ? _C.red.withOpacity(0.35) : _C.border,
          width: hasAlert ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _C.red.withOpacity(hasAlert ? 0.08 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
              color: _C.redLight, borderRadius: BorderRadius.circular(13)),
          child: const Icon(Icons.block_rounded, size: 21, color: _C.red),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              '$rejetees',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _C.black,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Rejetées',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 11, color: _C.label, fontWeight: FontWeight.w500),
            ),
          ]),
        ),
        if (hasAlert)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: _C.redLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _C.red.withOpacity(0.2)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.warning_amber_rounded, size: 13, color: _C.red),
              const SizedBox(width: 5),
              Text(
                'Action requise',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11, fontWeight: FontWeight.w700, color: _C.red,
                ),
              ),
            ]),
          )
        else
          Container(
            width: 26, height: 26,
            decoration: BoxDecoration(
                color: _C.redLight, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.arrow_forward_ios_rounded,
                size: 11, color: _C.red),
          ),
      ]),
    );
  }

  // ── Historique commandes ──────────────────────────────────────────────────
  // ── Historique commandes ──────────────────────────────────────────────────
  Widget _buildHistoriqueSection(List<Commande> commandes) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── En-tête ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Container(
                  width: 4, height: 22,
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
                  'Historique des commandes',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16, fontWeight: FontWeight.w800, color: _C.black,
                  ),
                ),
              ]),
              // Compteur commandes
              if (commandes.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _C.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${commandes.length}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12, fontWeight: FontWeight.w700, color: _C.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 5),

          // ── État vide ──
          if (commandes.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                color: _C.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _C.border),
              ),
              child: Column(children: [
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    color: _C.primaryLight,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.receipt_long_outlined,
                      color: _C.primary, size: 28),
                ),
                const SizedBox(height: 12),
                Text(
                  'Aucune commande pour le moment',
                  style: GoogleFonts.plusJakartaSans(
                    color: _C.label, fontSize: 13, fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Vos commandes apparaîtront ici',
                  style: GoogleFonts.plusJakartaSans(
                    color: _C.label.withOpacity(0.6), fontSize: 11,
                  ),
                ),
              ]),
            )

          // ── Liste commandes ──
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: commandes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final cmd = commandes[index];
                final statutColor = CommandeUtils.getStatutColor(cmd.statut);
                final statutLabel = CommandeUtils.getStatutLabel(cmd.statut);

                return Container(
                  decoration: BoxDecoration(
                    color: _C.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _C.border.withOpacity(0.8)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // ── Header carte ──
                      Container(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                        decoration: BoxDecoration(
                          color: _C.primaryLight.withOpacity(0.4),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20)),
                        ),
                        child: Row(
                          children: [
                            // Icône
                            Container(
                              width: 38, height: 38,
                              decoration: BoxDecoration(
                                color: _C.white,
                                borderRadius: BorderRadius.circular(11),
                                boxShadow: [
                                  BoxShadow(
                                    color: _C.primary.withOpacity(0.12),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.receipt_long_rounded,
                                  color: _C.primary, size: 18),
                            ),
                            const SizedBox(width: 10),
                            // Référence + date
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Commande #${cmd.reference.toUpperCase()}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                      color: _C.black,
                                    ),
                                  ),
                                  if (cmd.createdAt != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      _formatDate(cmd.createdAt!), // ex: "12 jan. 2025"
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        color: _C.label,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            // Badge statut
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: statutColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: statutColor.withOpacity(0.25)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6, height: 6,
                                    decoration: BoxDecoration(
                                      color: statutColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    statutLabel,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: statutColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Corps : liste produits ──
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                        child: Column(
                          children: cmd.details.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  // Point décoratif
                                  Container(
                                    width: 6, height: 6,
                                    decoration: BoxDecoration(
                                      color: _C.primary.withOpacity(0.4),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Nom produit
                                  Expanded(
                                    child: Text(
                                      "${item.nomProduit ?? 'Produit'}",
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12.5,
                                        color: _C.dark,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Quantité
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _C.primaryLight,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'x${item.quantite}',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        color: _C.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Prix
                                  Text(
                                    "${item.prixTotal} FCFA",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _C.black,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      // ── Divider + Total ──
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                        child: Column(
                          children: [
                            // Ligne séparatrice en pointillés
                            Row(
                              children: List.generate(
                                60,
                                    (_) => Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 2),
                                    height: 1,
                                    color: _C.border,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${cmd.details.fold(0, (sum, i) => sum + i.quantite)} article(s)',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: _C.label,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Total : ',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        color: _C.label,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '${cmd.montantTotal} FCFA',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        color: _C.primary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

// ── Helper date ──
  String _formatDate(DateTime date) {
    const mois = [
      'jan.', 'fév.', 'mar.', 'avr.', 'mai', 'jun.',
      'jul.', 'aoû.', 'sep.', 'oct.', 'nov.', 'déc.'
    ];
    return '${date.day} ${mois[date.month - 1]} ${date.year}';
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String _buildInitiales(String prenom, String nom) {
    final p = prenom.isNotEmpty ? prenom[0] : '';
    final n = nom.isNotEmpty    ? nom[0]    : '';
    final result = '$p$n'.toUpperCase();
    return result.isEmpty ? 'PH' : result;
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// DONUT CHART — CustomPainter
// ══════════════════════════════════════════════════════════════════════════════
class _DonutPainter extends CustomPainter {
  final CommandeStats stats;
  final int           total;

  _DonutPainter({required this.stats, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0) return;

    final cx = size.width  / 2;
    final cy = size.height / 2;
    final r  = (size.width  / 2) - 4;
    final t  = total.toDouble();

    final segments = [
      (stats.enAttente.toDouble(), const Color(0xFFFF9800)),
      (stats.validees.toDouble(),  const Color(0xFF06C167)),
      (stats.livrees.toDouble(),   const Color(0xFF1A56DB)),
      (stats.annulees.toDouble(),  const Color(0xFFEA580C)),
      (stats.rejetees.toDouble(),  const Color(0xFFE53935)),
    ];

    // Fond subtil
    canvas.drawCircle(
      Offset(cx, cy), r,
      Paint()
        ..color       = Colors.white.withOpacity(0.08)
        ..style       = PaintingStyle.stroke
        ..strokeWidth = 5,
    );

    double startAngle = -1.5708; // -π/2
    for (final seg in segments) {
      if (seg.$1 <= 0) continue;
      final sweep = (seg.$1 / t) * 6.28318;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        startAngle,
        sweep - 0.06,
        false,
        Paint()
          ..color       = seg.$2
          ..style       = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeCap   = StrokeCap.round,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.total != total;
}