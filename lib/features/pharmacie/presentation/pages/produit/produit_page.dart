import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../bloc/produit/produit_bloc.dart';
import '../../bloc/produit/produit_event.dart';
import '../../bloc/produit/produit_state.dart';
import 'panier_service.dart';
import 'panier_page.dart';
import 'produit_detail_page.dart';

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
  static const surface      = Color(0xFFF8FDF9);
  static const border       = Color(0xFFDDF0E6);
  static const label        = Color(0xFF7A9E87);
  static const sub          = Color(0xFF4D7A60);
  static const red          = Color(0xFFE53935);
  static const redLight     = Color(0xFFFFEBEE);
  static const amberLight   = Color(0xFFFFF3E0);
  static const blueLight    = Color(0xFFEBF2FF);
}

// ─── PRODUIT PAGE (Liste uniquement) ─────────────────────────────────────────
class ProduitPage extends StatefulWidget {
  const ProduitPage({super.key});

  @override
  State<ProduitPage> createState() => _ProduitPageState();
}

class _ProduitPageState extends State<ProduitPage> with TickerProviderStateMixin {
  String _searchQuery = '';
  String _sortBy      = 'nom';
  bool   _gridView    = true;

  // Singleton partagé avec PanierPage
  final PanierService _panier = PanierService();

  late AnimationController _headerCtrl;
  late Animation<double>   _headerFade;
  late Animation<Offset>   _headerSlide;
  late AnimationController _contentCtrl;
  late Animation<double>   _contentFade;

  final TextEditingController _searchCtrl  = TextEditingController();
  final FocusNode             _searchFocus = FocusNode();

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

    _loadData();
  }

  void _loadData() {
    context.read<ProduitBloc>().add(LoadProduits());
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _contentCtrl.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _ouvrirPanier() async {
    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const PanierPage(),
        transitionsBuilder: (_, animation, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
    if (mounted) setState(() {});
  }

  void _ajouterAuPanier(dynamic produit) {
    HapticFeedback.lightImpact();
    setState(() => _panier.ajouter(produit));
    _showAddedSnack(produit.nom);
  }

  void _showAddedSnack(String nom) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle_rounded, color: _C.white, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(
            '$nom ajouté au panier',
            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: _C.white),
          )),
        ]),
        backgroundColor: _C.primaryDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 90),
      ),
    );
  }

  void _ouvrirDetail(dynamic produit) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => ProduitDetailPage(
          produitId: produit.id,
          panier: _panier,
          onAjouterAuPanier: _ajouterAuPanier,
        ),
        transitionsBuilder: (_, animation, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

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
        Positioned(top: -40, right: -20, child: _circle(150, _C.primary.withOpacity(0.10))),
        Positioned(top: 30,  right: 50,  child: _circle(70,  _C.primary.withOpacity(0.07))),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Catalogue',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 22, fontWeight: FontWeight.w800,
                          color: _C.white, letterSpacing: -0.5)),
                  const SizedBox(height: 2),
                  BlocBuilder<ProduitBloc, ProduitState>(
                    builder: (_, state) {
                      final n = state is ProduitsLoaded ? state.produits.length : 0;
                      return Text('$n médicaments',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 12, color: _C.white.withOpacity(0.5),
                              fontWeight: FontWeight.w500));
                    },
                  ),
                ]),
                const Spacer(),
                // ── Bouton Vue grille/liste ──────────────────────────────
                _headerBtn(
                  icon: _gridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                  onTap: () => setState(() => _gridView = !_gridView),
                  bg: _C.white.withOpacity(0.09),
                  border: _C.white.withOpacity(0.12),
                  iconColor: _C.white,
                ),
                const SizedBox(width: 10),
                // ── Bouton Trier ─────────────────────────────────────────
                _headerBtn(
                  icon: Icons.sort_rounded,
                  onTap: _showSortSheet,
                  bg: _C.primary.withOpacity(0.20),
                  border: _C.primary.withOpacity(0.35),
                  iconColor: _C.primary,
                ),
                const SizedBox(width: 10),
                // ── Bouton Refresh manuel ─────────────────────────────────
                BlocBuilder<ProduitBloc, ProduitState>(
                  builder: (_, state) {
                    final isLoading = state is ProduitLoading;
                    return GestureDetector(
                      onTap: isLoading ? null : _loadData,
                      child: Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          color: _C.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(color: _C.white.withOpacity(0.18)),
                        ),
                        child: isLoading
                            ? Padding(
                          padding: const EdgeInsets.all(9),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                _C.white.withOpacity(0.7)),
                          ),
                        )
                            : const Icon(Icons.refresh_rounded, size: 18, color: _C.white),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 10),
                // ── Bouton Panier ────────────────────────────────────────
                GestureDetector(
                  onTap: _ouvrirPanier,
                  child: Stack(clipBehavior: Clip.none, children: [
                    Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: _C.white,
                        borderRadius: BorderRadius.circular(11),
                        boxShadow: [BoxShadow(
                            color: _C.primary.withOpacity(0.25),
                            blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: const Icon(Icons.shopping_cart_rounded, size: 18, color: _C.primary),
                    ),
                    if (_panier.count > 0)
                      Positioned(
                        top: -5, right: -5,
                        child: Container(
                          width: 18, height: 18,
                          decoration: BoxDecoration(
                            color: _C.red, shape: BoxShape.circle,
                            border: Border.all(color: _C.dark, width: 1.5),
                          ),
                          child: Center(
                            child: Text('${_panier.count}',
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9, fontWeight: FontWeight.w800, color: _C.white)),
                          ),
                        ),
                      ),
                  ]),
                ),
              ]),
              const SizedBox(height: 14),
              // ── Barre de recherche ─────────────────────────────────────
              Container(
                height: 46,
                decoration: BoxDecoration(
                  color: _C.white,
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12, offset: const Offset(0, 3))],
                ),
                child: Row(children: [
                  const SizedBox(width: 14),
                  Icon(Icons.search_rounded, size: 18, color: _C.label),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      focusNode: _searchFocus,
                      onChanged: (v) => setState(() => _searchQuery = v.toLowerCase().trim()),
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13, color: _C.black, fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: 'Rechercher un médicament, DCI...',
                        hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: _C.label),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                        _searchFocus.unfocus();
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 26, height: 26,
                        decoration: BoxDecoration(color: _C.border, shape: BoxShape.circle),
                        child: const Icon(Icons.close_rounded, size: 14, color: _C.sub),
                      ),
                    )
                  else
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [_C.primary, _C.primaryDark]),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(Icons.tune_rounded, size: 15, color: _C.white),
                    ),
                ]),
              ),
              const SizedBox(height: 12),
              if (_sortBy != 'nom' || _searchQuery.isNotEmpty)
                Wrap(spacing: 8, children: [
                  if (_sortBy != 'nom')
                    _activeChip(
                      label: _sortBy == 'prix_asc' ? 'Prix ↑' : 'Prix ↓',
                      icon: Icons.sort_rounded,
                      onRemove: () => setState(() => _sortBy = 'nom'),
                    ),
                  if (_searchQuery.isNotEmpty)
                    _activeChip(
                      label: '"$_searchQuery"',
                      icon: Icons.search_rounded,
                      onRemove: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                      },
                    ),
                ]),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _headerBtn({
    required IconData icon,
    required VoidCallback onTap,
    required Color bg,
    required Color border,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: border),
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
    );
  }

  Widget _activeChip({
    required String label,
    required IconData icon,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _C.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.primary.withOpacity(0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: _C.primary),
        const SizedBox(width: 5),
        Text(label, style: GoogleFonts.plusJakartaSans(
            fontSize: 11, fontWeight: FontWeight.w600, color: _C.primary)),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: onRemove,
          child: const Icon(Icons.close_rounded, size: 12, color: _C.primary),
        ),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CONTENU
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildContent() {
    return BlocBuilder<ProduitBloc, ProduitState>(
      buildWhen: (previous, current) =>
      current is ProduitLoading ||
          current is ProduitError ||
          current is ProduitsLoaded,
      builder: (context, state) {
        if (state is ProduitLoading) return _buildLoading();
        if (state is ProduitError)   return _buildError(context, state.message);
        if (state is ProduitsLoaded) return _buildProduitsList(context, state);
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoading() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 12,
        mainAxisSpacing: 12, childAspectRatio: 0.76,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => _shimmerCard(),
    );
  }

  Widget _shimmerCard() {
    return Container(
      decoration: BoxDecoration(
        color: _C.white, borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.border),
      ),
      child: Column(children: [
        Expanded(child: Container(
          decoration: BoxDecoration(
            color: _C.border,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
          ),
        )),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _shim(h: 12, w: 110),
            const SizedBox(height: 6),
            _shim(h: 10, w: 70),
            const SizedBox(height: 10),
            Row(children: [_shim(h: 14, w: 55), const Spacer(), _shim(h: 28, w: 28, r: 8)]),
          ]),
        ),
      ]),
    );
  }

  Widget _shim({required double h, double? w, double r = 6}) => Container(
    height: h, width: w,
    decoration: BoxDecoration(color: _C.border, borderRadius: BorderRadius.circular(r)),
  );

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 70, height: 70,
              decoration: const BoxDecoration(color: _C.redLight, shape: BoxShape.circle),
              child: const Icon(Icons.error_outline_rounded, color: _C.red, size: 32)),
          const SizedBox(height: 16),
          Text('Erreur de chargement',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 15, fontWeight: FontWeight.w700, color: _C.black)),
          const SizedBox(height: 6),
          Text(message,
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: _C.label),
              textAlign: TextAlign.center, maxLines: 2),
          const SizedBox(height: 20),
          _greenButton(label: 'Réessayer', icon: Icons.refresh_rounded, onTap: _loadData),
        ]),
      ),
    );
  }

  Widget _buildProduitsList(BuildContext context, ProduitsLoaded state) {
    var liste = state.produits.where((p) {
      if (_searchQuery.isEmpty) return true;
      return (p.nom ?? '').toLowerCase().contains(_searchQuery);
    }).toList();

    liste.sort((a, b) {
      if (_sortBy == 'prix_asc') {
        final pa = double.tryParse(a.prix.toString()) ?? 0;
        final pb = double.tryParse(b.prix.toString()) ?? 0;
        return pa.compareTo(pb);
      }
      if (_sortBy == 'prix_desc') {
        final pa = double.tryParse(a.prix.toString()) ?? 0;
        final pb = double.tryParse(b.prix.toString()) ?? 0;
        return pb.compareTo(pa);
      }
      return (a.nom ?? '').compareTo(b.nom ?? '');
    });

    if (liste.isEmpty) return _buildEmpty();

    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      color: _C.primary,
      backgroundColor: _C.white,
      child: _gridView
          ? GridView.builder(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 12,
          mainAxisSpacing: 12, childAspectRatio: 0.76,
        ),
        itemCount: liste.length,
        itemBuilder: (_, i) => _buildGridCard(context, liste[i], i),
      )
          : ListView.separated(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
        itemCount: liste.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _buildListCard(context, liste[i], i),
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, dynamic p, int index) {
    final bgList = [
      _C.primaryLight, _C.blueLight, _C.amberLight,
      const Color(0xFFFCE4EC), const Color(0xFFF3E5F5),
    ];
    final imgBg = bgList[index % bgList.length];
    final qteInCart = _panier.qte(p.id);

    return GestureDetector(
      onTap: () => _ouvrirDetail(p),
      child: Container(
        decoration: BoxDecoration(
          color: _C.white, borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _C.border),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
              blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Stack(children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: imgBg,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
                  image: (p.image?.isNotEmpty ?? false)
                      ? DecorationImage(image: NetworkImage(p.image!), fit: BoxFit.cover)
                      : null,
                ),
                child: (p.image?.isEmpty ?? true)
                    ? Center(child: Icon(Icons.medication_rounded, size: 44, color: _C.primaryMid))
                    : null,
              ),
              Positioned(top: 8, left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: _C.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _C.primary.withOpacity(0.3)),
                    ),
                    child: Text('Rx', style: GoogleFonts.plusJakartaSans(
                        fontSize: 9, fontWeight: FontWeight.w700, color: _C.primaryDark)),
                  )),
              if (qteInCart > 0)
                Positioned(top: 8, right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                          color: _C.primary, borderRadius: BorderRadius.circular(8)),
                      child: Text('×$qteInCart', style: GoogleFonts.plusJakartaSans(
                          fontSize: 10, fontWeight: FontWeight.w800, color: _C.white)),
                    )),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.nom ?? '',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 12, fontWeight: FontWeight.w700, color: _C.black),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(p.categorieNom ?? '',
                  style: GoogleFonts.plusJakartaSans(fontSize: 10, color: _C.label),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${_formatPrix(p.prix)} F',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 14, fontWeight: FontWeight.w800,
                          color: _C.black, letterSpacing: -0.3)),
                  Text('CFA', style: GoogleFonts.plusJakartaSans(fontSize: 9, color: _C.label)),
                ]),
                GestureDetector(
                  onTap: () => _ajouterAuPanier(p),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: qteInCart > 0
                              ? [_C.primaryDark, _C.primaryDeep]
                              : [_C.primary, _C.primaryDark],
                          begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(9),
                      boxShadow: [BoxShadow(color: _C.primary.withOpacity(0.3),
                          blurRadius: 6, offset: const Offset(0, 2))],
                    ),
                    child: const Icon(Icons.add_rounded, color: _C.white, size: 17),
                  ),
                ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildListCard(BuildContext context, dynamic p, int index) {
    final bgList = [
      _C.primaryLight, _C.blueLight, _C.amberLight,
      const Color(0xFFFCE4EC), const Color(0xFFF3E5F5),
    ];
    final imgBg = bgList[index % bgList.length];
    final qteInCart = _panier.qte(p.id);

    return GestureDetector(
      onTap: () => _ouvrirDetail(p),
      child: Container(
        decoration: BoxDecoration(
          color: _C.white, borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: qteInCart > 0 ? _C.primary.withOpacity(0.3) : _C.border),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03),
              blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(children: [
          Stack(children: [
            Container(
              width: 80, height: 90,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: imgBg, borderRadius: BorderRadius.circular(12),
                image: (p.image?.isNotEmpty ?? false)
                    ? DecorationImage(image: NetworkImage(p.image!), fit: BoxFit.cover)
                    : null,
              ),
              child: (p.image?.isEmpty ?? true)
                  ? Center(child: Icon(Icons.medication_rounded, size: 32, color: _C.primaryMid))
                  : null,
            ),
            if (qteInCart > 0)
              Positioned(top: 6, right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                        color: _C.primary, borderRadius: BorderRadius.circular(6)),
                    child: Text('×$qteInCart', style: GoogleFonts.plusJakartaSans(
                        fontSize: 9, fontWeight: FontWeight.w800, color: _C.white)),
                  )),
          ]),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 2),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _C.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: _C.primary.withOpacity(0.25)),
                    ),
                    child: Text('Rx', style: GoogleFonts.plusJakartaSans(
                        fontSize: 8, fontWeight: FontWeight.w700, color: _C.primaryDark)),
                  ),
                  const SizedBox(width: 6),
                  Expanded(child: Text(p.nom ?? '',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13, fontWeight: FontWeight.w700, color: _C.black),
                      maxLines: 1, overflow: TextOverflow.ellipsis)),
                ]),
                const SizedBox(height: 4),
                Text(p.categorieNom ?? '',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: _C.label),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Text('${_formatPrix(p.prix)} F CFA',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 15, fontWeight: FontWeight.w800,
                        color: _C.black, letterSpacing: -0.3)),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: GestureDetector(
              onTap: () => _ajouterAuPanier(p),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [_C.primary, _C.primaryDark],
                      begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: _C.primary.withOpacity(0.3),
                      blurRadius: 6, offset: const Offset(0, 2))],
                ),
                child: const Icon(Icons.add_rounded, color: _C.white, size: 18),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 80, height: 80,
              decoration: const BoxDecoration(color: _C.primaryLight, shape: BoxShape.circle),
              child: const Icon(Icons.search_off_rounded, color: _C.primary, size: 36)),
          const SizedBox(height: 16),
          Text('Aucun résultat',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 16, fontWeight: FontWeight.w700, color: _C.black)),
          const SizedBox(height: 6),
          Text('La liste des produits est vide',
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: _C.label),
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              _searchCtrl.clear();
              setState(() { _searchQuery = ''; _sortBy = 'nom'; });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _C.primaryLight, borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _C.primary.withOpacity(0.3)),
              ),
              child: Text('Effacer les filtres',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13, fontWeight: FontWeight.w600, color: _C.primary)),
            ),
          ),
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SORT SHEET
  // ══════════════════════════════════════════════════════════════════════════
  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: _C.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 36, height: 4,
              decoration: BoxDecoration(color: _C.border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Text('Trier les médicaments',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 15, fontWeight: FontWeight.w800, color: _C.black)),
          const SizedBox(height: 4),
          Text('Choisissez l\'ordre d\'affichage',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: _C.label)),
          const SizedBox(height: 16),
          _sortTile('nom',       Icons.sort_by_alpha_rounded,  'Nom A → Z',        'Ordre alphabétique'),
          const SizedBox(height: 8),
          _sortTile('prix_asc',  Icons.trending_up_rounded,    'Prix croissant',   'Du moins cher au plus cher'),
          const SizedBox(height: 8),
          _sortTile('prix_desc', Icons.trending_down_rounded,  'Prix décroissant', 'Du plus cher au moins cher'),
        ]),
      ),
    );
  }

  Widget _sortTile(String val, IconData icon, String label, String sub) {
    final sel = _sortBy == val;
    return GestureDetector(
      onTap: () {
        setState(() => _sortBy = val);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: sel ? _C.primaryLight : _C.surface,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: sel ? _C.primary.withOpacity(0.3) : _C.border),
        ),
        child: Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: sel ? _C.primary : _C.border,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: sel ? _C.white : _C.label),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: GoogleFonts.plusJakartaSans(
                fontSize: 13, fontWeight: FontWeight.w700,
                color: sel ? _C.primaryDark : _C.black)),
            Text(sub, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: _C.label)),
          ])),
          if (sel)
            Container(
              width: 22, height: 22,
              decoration: const BoxDecoration(color: _C.primary, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, size: 13, color: _C.white),
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

  Widget _greenButton({required String label, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_C.primary, _C.primaryDark]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: _C.primary.withOpacity(0.3),
              blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: _C.white),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.plusJakartaSans(
              fontSize: 13, fontWeight: FontWeight.w700, color: _C.white)),
        ]),
      ),
    );
  }

  String _formatPrix(dynamic prix) {
    final d = double.tryParse(prix?.toString() ?? '0') ?? 0;
    if (d >= 1000) {
      final formatted = d.toStringAsFixed(0);
      final buf = StringBuffer();
      int count = 0;
      for (int i = formatted.length - 1; i >= 0; i--) {
        if (count > 0 && count % 3 == 0) buf.write(' ');
        buf.write(formatted[i]);
        count++;
      }
      return buf.toString().split('').reversed.join();
    }
    return d.toStringAsFixed(0);
  }
}