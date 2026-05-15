import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_it/get_it.dart';
import 'panier_service.dart';
import '../../../domain/entities/produit.dart';
import '../../../domain/usecases/get_produit_detail.dart';

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
  static const amber        = Color(0xFFFFA000);
  static const amberLight   = Color(0xFFFFF8E1);
  static const blueLight    = Color(0xFFEBF2FF);
  static const blue         = Color(0xFF185FA5);
  static const surface      = Color(0xFFF8FDF9);
}

class ProduitDetailPage extends StatefulWidget {
  final String produitId;
  final PanierService panier;
  final void Function(Produit) onAjouterAuPanier;

  const ProduitDetailPage({
    super.key,
    required this.produitId,
    required this.panier,
    required this.onAjouterAuPanier,
  });

  @override
  State<ProduitDetailPage> createState() => _ProduitDetailPageState();
}

class _ProduitDetailPageState extends State<ProduitDetailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  Produit? _produit;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _fadeAnim  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
    _loadProduit();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProduit() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final getDetail = GetIt.I<GetProduitDetail>();
      final produit = await getDetail(widget.produitId);
      setState(() { _produit = produit; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  void _ajouter() {
    if (_produit == null) return;
    HapticFeedback.lightImpact();
    widget.onAjouterAuPanier(_produit!);
    setState(() {});
    _showAddedSnack(_produit!.nom);
  }

  void _showAddedSnack(String nom) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle_rounded, color: _C.white, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text('$nom ajouté au panier',
            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: _C.white))),
      ]),
      backgroundColor: _C.primaryDark,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _C.bg,
        body: _isLoading
            ? _buildLoading()
            : _error != null
            ? _buildError()
            : _buildContent(),
      ),
    );
  }

  // ── LOADING ───────────────────────────────────────────────────────────────
  Widget _buildLoading() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const CircularProgressIndicator(color: _C.primary),
        const SizedBox(height: 16),
        Text('Chargement du produit...',
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: _C.label)),
      ]),
    );
  }

  // ── ERROR ─────────────────────────────────────────────────────────────────
  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 70, height: 70,
            decoration: const BoxDecoration(color: _C.redLight, shape: BoxShape.circle),
            child: const Icon(Icons.error_outline_rounded, size: 32, color: _C.red),
          ),
          const SizedBox(height: 16),
          Text('Erreur de chargement',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 15, fontWeight: FontWeight.w700, color: _C.black)),
          const SizedBox(height: 6),
          Text(_error ?? 'Une erreur est survenue',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: _C.label),
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _loadProduit,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_C.primary, _C.primaryDark]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(
                    color: _C.primary.withOpacity(0.3),
                    blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.refresh_rounded, size: 16, color: _C.white),
                const SizedBox(width: 8),
                Text('Réessayer', style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, fontWeight: FontWeight.w700, color: _C.white)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  // ── CONTENU PRINCIPAL ─────────────────────────────────────────────────────
  Widget _buildContent() {
    final p = _produit!;
    final qteInCart = widget.panier.qte(p.id);
    final hasPromo = p.prixPromo != null && p.prixPromo! < p.prix;
    final prixAffiche = p.prixPromo ?? p.prix;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: CustomScrollView(
          slivers: [

            // ── Hero AppBar ─────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: _C.dark,
              automaticallyImplyLeading: false,
              leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _C.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _C.white.withOpacity(0.2)),
                  ),
                  child: const Icon(Icons.arrow_back_rounded, color: _C.white, size: 18),
                ),
              ),
              actions: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: qteInCart > 0 ? _C.primary : _C.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: qteInCart > 0 ? _C.primaryDark : _C.white.withOpacity(0.2)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(qteInCart > 0
                          ? Icons.shopping_cart_rounded
                          : Icons.shopping_cart_outlined,
                          color: _C.white, size: 15),
                      if (qteInCart > 0) ...[
                        const SizedBox(width: 5),
                        Text('×$qteInCart', style: GoogleFonts.plusJakartaSans(
                            fontSize: 11, fontWeight: FontWeight.w800, color: _C.white)),
                      ],
                    ]),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(fit: StackFit.expand, children: [
                  (p.image != null && p.image!.isNotEmpty)
                      ? Image.network(p.image!, fit: BoxFit.cover,
                      loadingBuilder: (ctx, child, prog) {
                        if (prog == null) return child;
                        return _heroPlaceholder();
                      })
                      : _heroPlaceholder(),
                  // Dégradé
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      height: 160,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, _C.dark.withOpacity(0.95)],
                        ),
                      ),
                    ),
                  ),
                  // Infos bas du hero
                  Positioned(
                    bottom: 16, left: 16, right: 16,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        if (hasPromo) ...[
                          const SizedBox(width: 8),
                          _heroBadge(Icons.local_offer_rounded,
                              '-${((1 - p.prixPromo! / p.prix) * 100).toInt()}% Promo',
                              _C.amber),
                        ],
                      ]),
                      const SizedBox(height: 8),
                      Text(p.nom, style: GoogleFonts.plusJakartaSans(
                          fontSize: 22, fontWeight: FontWeight.w800,
                          color: _C.white, letterSpacing: -0.5, height: 1.2)),
                      const SizedBox(height: 4),
                      Row(children: [
                        const Icon(Icons.category_outlined, size: 13, color: _C.label),
                        const SizedBox(width: 5),
                        Text(p.categorieNom, style: GoogleFonts.plusJakartaSans(
                            fontSize: 12, color: _C.label)),
                      ]),
                    ]),
                  ),
                ]),
              ),
            ),

            // ── Corps scrollable ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ① SECTION PRIX ─────────────────────────────────────
                    _sectionTitle(Icons.sell_rounded, 'Tarification'),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_C.dark, _C.primaryDeep],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [BoxShadow(
                            color: _C.primary.withOpacity(0.18),
                            blurRadius: 16, offset: const Offset(0, 6))],
                      ),
                      child: Column(children: [
                        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Prix de vente', style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11, color: _C.white.withOpacity(0.5))),
                              const SizedBox(height: 6),
                              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                if (hasPromo) ...[
                                  Text(_formatPrix(p.prix), style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16, fontWeight: FontWeight.w600,
                                      color: _C.white.withOpacity(0.45),
                                      decoration: TextDecoration.lineThrough,
                                      decorationColor: _C.white.withOpacity(0.45))),
                                  const SizedBox(width: 8),
                                ],
                                Text(_formatPrix(prixAffiche), style: GoogleFonts.plusJakartaSans(
                                    fontSize: 34, fontWeight: FontWeight.w800,
                                    color: _C.white, letterSpacing: -0.5)),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4, left: 4),
                                  child: Text('F CFA', style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13, color: _C.white.withOpacity(0.6))),
                                ),
                              ]),
                              if (hasPromo)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Row(children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: _C.amber.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: _C.amber.withOpacity(0.4)),
                                      ),
                                      child: Text(
                                        'Économie : ${_formatPrix(p.prix - prixAffiche)} F CFA',
                                        style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10, fontWeight: FontWeight.w600,
                                            color: _C.amber),
                                      ),
                                    ),
                                  ]),
                                ),
                            ]),
                          ),
                          const SizedBox(width: 12),
                          // Indicateur panier
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: qteInCart > 0
                                ? Container(
                              key: const ValueKey('inCart'),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: _C.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: _C.primary.withOpacity(0.45)),
                              ),
                              child: Column(children: [
                                const Icon(Icons.shopping_cart_rounded, size: 20, color: _C.primary),
                                const SizedBox(height: 3),
                                Text('×$qteInCart', style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13, fontWeight: FontWeight.w800, color: _C.primary)),
                                Text('Au panier', style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9, color: _C.primary.withOpacity(0.7))),
                              ]),
                            )
                                : Container(
                              key: const ValueKey('dispo'),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: _C.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: _C.white.withOpacity(0.15)),
                              ),
                              child: Column(children: [
                                const Icon(Icons.local_offer_rounded, size: 20, color: _C.white),
                                const SizedBox(height: 3),
                                Text('Dispo', style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11, fontWeight: FontWeight.w600, color: _C.white)),
                              ]),
                            ),
                          ),
                        ]),
                        // Dimension & Unité
                        if (p.dimension.isNotEmpty || p.unite.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 14),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _C.white.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _C.white.withOpacity(0.1)),
                            ),
                            child: Row(children: [
                              if (p.dimension.isNotEmpty)
                                Expanded(child: _darkMetaItem(
                                    Icons.aspect_ratio_rounded, 'Dimension', p.dimension)),
                              if (p.dimension.isNotEmpty && p.unite.isNotEmpty)
                                Container(width: 1, height: 36,
                                    color: _C.white.withOpacity(0.12)),
                              if (p.unite.isNotEmpty)
                                Expanded(child: _darkMetaItem(
                                    Icons.inventory_2_outlined, 'Unité', p.unite)),
                            ]),
                          ),
                      ]),
                    ),

                    const SizedBox(height: 22),

                    // ② SECTION DISPONIBILITÉ ────────────────────────────
                    _sectionTitle(Icons.inventory_2_rounded, 'Disponibilité en stock'),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _C.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: p.stock > 0
                                ? _C.primary.withOpacity(0.25)
                                : _C.red.withOpacity(0.25)),
                        boxShadow: [BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: Row(children: [
                        Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(
                            color: p.stock > 0 ? _C.primaryLight : _C.redLight,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            p.stock > 0 ? Icons.check_circle_rounded : Icons.cancel_rounded,
                            color: p.stock > 0 ? _C.primary : _C.red,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(
                            p.stock > 0 ? 'Produit disponible' : 'Rupture de stock',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 14, fontWeight: FontWeight.w700,
                                color: p.stock > 0 ? _C.primaryDark : _C.red),
                          ),
                          const SizedBox(height: 2),
                          Text('Quantité en stock : ${p.stock} unités',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: _C.label)),
                        ])),
                      ]),
                    ),

                    const SizedBox(height: 22),

                    // ④ SECTION DESCRIPTION ──────────────────────────────
                    if (p.description.isNotEmpty) ...[
                      _sectionTitle(Icons.description_rounded, 'Description du produit'),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: _C.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: _C.border),
                          boxShadow: [BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 8, offset: const Offset(0, 2))],
                        ),
                        child: Text(p.description, style: GoogleFonts.plusJakartaSans(
                            fontSize: 13, color: _C.sub, height: 1.7)),
                      ),
                      const SizedBox(height: 30),
                    ],

                    // ── BOUTONS D'ACTION ─────────────────────────────────
                    Row(children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: 54,
                            decoration: BoxDecoration(
                              color: _C.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _C.border),
                            ),
                            child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.arrow_back_rounded, size: 17, color: _C.primary),
                              const SizedBox(width: 7),
                              Text('Retour', style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13, fontWeight: FontWeight.w700, color: _C.primary)),
                            ])),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: _ajouter,
                          child: Container(
                            height: 54,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [_C.primary, _C.primaryDark],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(
                                  color: _C.primary.withOpacity(0.35),
                                  blurRadius: 14, offset: const Offset(0, 6))],
                            ),
                            child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.add_shopping_cart_rounded, size: 20, color: _C.white),
                              const SizedBox(width: 9),
                              Text('Ajouter au panier', style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13, fontWeight: FontWeight.w700, color: _C.white)),
                            ])),
                          ),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── WIDGETS AUXILIAIRES ───────────────────────────────────────────────────

  Widget _heroPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            colors: [_C.dark, _C.primaryDeep],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Center(child: Icon(Icons.medication_rounded,
          size: 90, color: _C.primaryMid.withOpacity(0.4))),
    );
  }

  Widget _heroBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.85),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(
            color: color.withOpacity(0.35), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: _C.white),
        const SizedBox(width: 5),
        Text(label, style: GoogleFonts.plusJakartaSans(
            fontSize: 11, fontWeight: FontWeight.w700, color: _C.white)),
      ]),
    );
  }

  /// Titre de section avec icône + ligne décorative
  Widget _sectionTitle(IconData icon, String title) {
    return Row(children: [
      Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          color: _C.primaryLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: _C.primary),
      ),
      const SizedBox(width: 10),
      Text(title, style: GoogleFonts.plusJakartaSans(
          fontSize: 15, fontWeight: FontWeight.w700, color: _C.black)),
      const SizedBox(width: 10),
      Expanded(child: Container(height: 1, color: _C.border)),
    ]);
  }

  /// Métadonnée sur fond sombre (dans le bloc prix)
  Widget _darkMetaItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(children: [
        Icon(icon, size: 14, color: _C.white.withOpacity(0.45)),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.plusJakartaSans(
              fontSize: 10, color: _C.white.withOpacity(0.45))),
          Text(value, style: GoogleFonts.plusJakartaSans(
              fontSize: 12, fontWeight: FontWeight.w700,
              color: _C.white.withOpacity(0.85))),
        ]),
      ]),
    );
  }

  /// Tuile caractéristique (grille 2×2)
  Widget _featTile(IconData icon, String label, String value, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.border),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 17, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.plusJakartaSans(
              fontSize: 9, color: _C.label),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(value, style: GoogleFonts.plusJakartaSans(
              fontSize: 12, fontWeight: FontWeight.w700, color: _C.black),
              maxLines: 1, overflow: TextOverflow.ellipsis),
        ])),
      ]),
    );
  }

  String _formatPrix(dynamic prix) {
    final d = double.tryParse(prix?.toString() ?? '0') ?? 0;
    final formatted = d.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < formatted.length; i++) {
      if (i > 0 && (formatted.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(formatted[i]);
    }
    return buffer.toString();
  }
}