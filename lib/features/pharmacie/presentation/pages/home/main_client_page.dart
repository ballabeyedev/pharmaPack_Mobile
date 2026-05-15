import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharmapack/features/auth/domain/entities/user.dart';
import 'home_page.dart';
import '../profil/profil_page.dart';
import '../produit/produit_page.dart';
import '../commande/commandes_page.dart';
import '../avantage/avantage_page.dart'; // 👈 ta page Mes Avoirs

class _C {
  static const primary      = Color(0xFF06C167);
  static const primaryDark  = Color(0xFF04A355);
  static const primaryLight = Color(0xFFEDFAF3);
  static const primaryDeep  = Color(0xFF027A40);
  static const black        = Color(0xFF0D1F17);
  static const dark         = Color(0xFF1A2E22);
  static const white        = Color(0xFFFFFFFF);
  static const bg           = Color(0xFFF2FAF5);
  static const border       = Color(0xFFDDF0E6);
  static const label        = Color(0xFF7A9E87);
  static const inactive     = Color(0xFFB0C9BB);
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String   label;
  final bool     hasNotif;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.hasNotif = false,
  });
}

class MainAcheteurPage extends StatefulWidget {
  final User? user;
  const MainAcheteurPage({super.key, this.user});

  @override
  State<MainAcheteurPage> createState() => _MainAcheteurPageState();
}

class _MainAcheteurPageState extends State<MainAcheteurPage>
    with TickerProviderStateMixin {

  int _selectedIndex = 0;
  late List<Widget> _pages;

  // ── Clé pour positionner le popup sur le bouton "•••" ──
  final GlobalKey _moreKey = GlobalKey();

  final List<_NavItem> _navItems = const [
    _NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Accueil',
    ),
    _NavItem(
      icon: Icons.medication_outlined,
      activeIcon: Icons.medication_rounded,
      label: 'Catalogue',
    ),
    _NavItem(
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
      label: 'Commandes',
      hasNotif: true,
    ),
    _NavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profil',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(user: widget.user),
      const ProduitPage(),
      const HistoriqueCommandesPage(),
      ProfilPage(user: widget.user),
    ];
  }

  void _onTap(int index) {
    if (_selectedIndex == index) return;
    HapticFeedback.lightImpact();
    setState(() => _selectedIndex = index);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // POPUP "Plus" — s'affiche juste au-dessus du bouton "•••"
  // ══════════════════════════════════════════════════════════════════════════
  void _showMoreMenu() {
    HapticFeedback.lightImpact();

    // Récupère la position du bouton "•••" à l'écran
    final RenderBox box =
    _moreKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = box.localToGlobal(Offset.zero);
    final Size   size   = box.size;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.25),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, _, __) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return Stack(
          children: [
            // Tap outside → ferme
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),
            // Menu positionné au-dessus du bouton
            Positioned(
              // On remonte de ~hauteur estimée du menu (160) + espace
              top: offset.dy - 168,
              left: offset.dx - 80, // centre approximatif
              child: ScaleTransition(
                scale: curved,
                alignment: Alignment.bottomRight,
                child: FadeTransition(
                  opacity: anim,
                  child: _MoreMenuCard(
                    onAvoirsTab: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, animation, __) =>
                          const AvoirsPage(),
                          transitionsBuilder: (_, animation, __, child) =>
                              SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.0, 1.0),
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic)),
                                child: child,
                              ),
                          transitionDuration:
                          const Duration(milliseconds: 350),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _C.bg,
        extendBody: true,
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: _buildNavBar(),
        floatingActionButton: _buildFAB(),
        floatingActionButtonLocation:
        FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  // ── FAB ───────────────────────────────────────────────────────────────────
  Widget _buildFAB() {
    return FloatingActionButton(
      backgroundColor: _C.primary,
      elevation: 4,
      onPressed: () {},
      child: const Icon(Icons.add, color: _C.white),
    );
  }

  // ── NAVBAR ────────────────────────────────────────────────────────────────
  Widget _buildNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: _C.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // ── Accueil ──
            Expanded(child: _buildNavItem(0)),
            // ── Catalogue ──
            Expanded(child: _buildNavItem(1)),
            // ── Espace FAB ──
            const SizedBox(width: 60),
            // ── Commandes ──
            Expanded(child: _buildNavItem(2)),
            // ── Profil ──
            Expanded(child: _buildNavItem(3)),
            // ── Bouton "•••" discret ──
            _buildMoreButton(),
          ],
        ),
      ),
    );
  }

  // ── Item nav standard ─────────────────────────────────────────────────────
  Widget _buildNavItem(int index) {
    final item     = _navItems[index];
    final selected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: selected ? 38 : 0,
                  height: selected ? 4 : 0,
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: _C.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Icon(
                  selected ? item.activeIcon : item.icon,
                  size: 22,
                  color: selected ? _C.primary : _C.inactive,
                ),
                const SizedBox(height: 3),
                Text(
                  item.label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? _C.primary : _C.inactive,
                  ),
                ),
              ],
            ),
            // Badge notif
            if (item.hasNotif)
              Positioned(
                top: selected ? 2 : -2,
                right: 18,
                child: Container(
                  width: 7, height: 7,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5722),
                    shape: BoxShape.circle,
                    border: Border.all(color: _C.white, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Bouton "•••" discret ──────────────────────────────────────────────────
  Widget _buildMoreButton() {
    return GestureDetector(
      key: _moreKey,
      onTap: _showMoreMenu,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: _C.primaryLight,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: _C.border),
              ),
              child: const Icon(
                Icons.more_horiz_rounded,
                size: 16,
                color: _C.primary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Plus',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: _C.inactive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CARD DU MENU "PLUS"
// ══════════════════════════════════════════════════════════════════════════════
class _MoreMenuCard extends StatelessWidget {
  final VoidCallback onAvoirsTab;

  const _MoreMenuCard({required this.onAvoirsTab});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: _C.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _C.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Titre du menu ──
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(children: [
                Container(
                  width: 4, height: 14,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_C.primary, _C.primaryDark],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Menu',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _C.black,
                  ),
                ),
              ]),
            ),

            Divider(height: 1, color: _C.border),

            // ── Item : Mes Avoirs ──
            _MenuItem(
              icon: Icons.account_balance_wallet_rounded,
              label: 'Mes Avoirs',
              sublabel: 'Crédits & remboursements',
              color: _C.primary,
              bg: _C.primaryLight,
              onTap: onAvoirsTab,
              showDivider: false,
            ),

            // ── Tu peux ajouter d'autres items ici de la même façon ──
            // _MenuItem(
            //   icon: Icons.star_rounded,
            //   label: 'Favoris',
            //   sublabel: 'Mes médicaments favoris',
            //   color: Color(0xFFFF9800),
            //   bg: Color(0xFFFFF3E0),
            //   onTap: () {},
            //   showDivider: false,
            // ),

            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}

// ── Item générique du menu ─────────────────────────────────────────────────
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   sublabel;
  final Color    color;
  final Color    bg;
  final VoidCallback onTap;
  final bool     showDivider;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.bg,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 10),
            child: Row(children: [
              // Icône
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                      color: color.withOpacity(0.2)),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 10),
              // Textes
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _C.black,
                      ),
                    ),
                    Text(
                      sublabel,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: _C.label,
                      ),
                    ),
                  ],
                ),
              ),
              // Flèche
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 11, color: _C.label),
            ]),
          ),
        ),
        if (showDivider)
          Divider(height: 1, indent: 14, endIndent: 14, color: _C.border),
      ],
    );
  }
}