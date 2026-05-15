import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../bloc/produit/produit_bloc.dart';
import '../../bloc/produit/produit_event.dart';
import 'panier_service.dart';

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

// ─── PANIER PAGE ──────────────────────────────────────────────────────────────
class PanierPage extends StatefulWidget {
  const PanierPage({super.key});

  @override
  State<PanierPage> createState() => _PanierPageState();
}

class _PanierPageState extends State<PanierPage> with TickerProviderStateMixin {
  final PanierService _panier = PanierService();

  late AnimationController _headerCtrl;
  late Animation<double>   _headerFade;
  late Animation<Offset>   _headerSlide;
  late AnimationController _listCtrl;
  late Animation<double>   _listFade;

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _listCtrl   = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _headerFade  = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.03), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic));
    _listFade = CurvedAnimation(parent: _listCtrl, curve: Curves.easeOut);
    _headerCtrl.forward();
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) _listCtrl.forward();
    });
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _listCtrl.dispose();
    super.dispose();
  }

  void _modifierQuantite(int idx, int delta) {
    HapticFeedback.selectionClick();
    setState(() => _panier.modifier(idx, delta));
  }

  void _viderPanier() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _C.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Vider le panier ?',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 16, fontWeight: FontWeight.w800, color: _C.black)),
        content: Text('Tous les articles seront supprimés.',
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: _C.label)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, fontWeight: FontWeight.w600, color: _C.label)),
          ),
          GestureDetector(
            onTap: () {
              setState(() => _panier.vider());
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                  color: _C.redLight, borderRadius: BorderRadius.circular(10)),
              child: Text('Vider',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13, fontWeight: FontWeight.w700, color: _C.red)),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  void _passerCommande() {
    final commande = _panier.buildCommande();
    context.read<ProduitBloc>().add(PasserCommandeEvent(commande));
    setState(() => _panier.vider());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle_rounded, color: _C.white, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Commande envoyée !',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13, fontWeight: FontWeight.w800, color: _C.white)),
              Text('Vous serez contacté sous peu',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 11, color: _C.white.withOpacity(0.7))),
            ]),
          ),
        ]),
        backgroundColor: _C.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      ),
    );

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) Navigator.pop(context);
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
            child: FadeTransition(
              opacity: _listFade,
              child: _panier.items.isEmpty ? _buildPanierVide() : _buildPanierListe(),
            ),
          ),
          if (_panier.items.isNotEmpty) _buildFooter(),
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
        Positioned(top: -30, right: -10, child: _circle(120, _C.primary.withOpacity(0.09))),
        Positioned(bottom: 0, left: 40,  child: _circle(60,  _C.primary.withOpacity(0.06))),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: _C.white.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: _C.white.withOpacity(0.15)),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: _C.white),
                  ),
                ),
                const SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Mon panier',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 20, fontWeight: FontWeight.w800,
                          color: _C.white, letterSpacing: -0.4)),
                  const SizedBox(height: 2),
                  Text(
                    '${_panier.count} article${_panier.count > 1 ? 's' : ''} sélectionné${_panier.count > 1 ? 's' : ''}',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, color: _C.white.withOpacity(0.5),
                        fontWeight: FontWeight.w500),
                  ),
                ]),
                const Spacer(),
                if (_panier.items.isNotEmpty)
                  GestureDetector(
                    onTap: _viderPanier,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _C.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _C.red.withOpacity(0.3)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.delete_outline_rounded, size: 14, color: _C.red),
                        const SizedBox(width: 5),
                        Text('Vider',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 11, fontWeight: FontWeight.w700, color: _C.red)),
                      ]),
                    ),
                  ),
              ]),
              const SizedBox(height: 16),
              if (_panier.items.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _C.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _C.white.withOpacity(0.10)),
                  ),
                  child: Row(children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: _C.primary.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.shopping_bag_rounded, color: _C.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        '${_panier.items.length} produit${_panier.items.length > 1 ? 's' : ''} différent${_panier.items.length > 1 ? 's' : ''}',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 12, fontWeight: FontWeight.w600,
                            color: _C.white.withOpacity(0.7)),
                      ),
                      const SizedBox(height: 2),
                      Text('${_panier.count} unité${_panier.count > 1 ? 's' : ''} au total',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 11, color: _C.white.withOpacity(0.45))),
                    ]),
                    const Spacer(),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('Sous-total',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 10, color: _C.white.withOpacity(0.45))),
                      const SizedBox(height: 2),
                      Text('${_formatPrix(_panier.total)} F',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 16, fontWeight: FontWeight.w800,
                              color: _C.white, letterSpacing: -0.3)),
                    ]),
                  ]),
                ),
            ]),
          ),
        ),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LISTE ARTICLES
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildPanierListe() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
      itemCount: _panier.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _buildArticleCard(i),
    );
  }

  Widget _buildArticleCard(int i) {
    final item = _panier.items[i];
    final bgList = [
      _C.primaryLight, _C.blueLight, _C.amberLight,
      const Color(0xFFFCE4EC), const Color(0xFFF3E5F5),
    ];
    final imgBg = bgList[i % bgList.length];

    return Dismissible(
      key: Key(item.produit.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: _C.redLight,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.delete_rounded, color: _C.red, size: 28),
          const SizedBox(height: 4),
          Text('Supprimer', style: GoogleFonts.plusJakartaSans(
              fontSize: 10, fontWeight: FontWeight.w700, color: _C.red)),
        ]),
      ),
      onDismissed: (_) {
        HapticFeedback.mediumImpact();
        setState(() => _panier.items.removeAt(i));
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _C.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _C.border),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Row(children: [
          Stack(children: [
            Container(
              width: 68, height: 68,
              decoration: BoxDecoration(
                color: imgBg, borderRadius: BorderRadius.circular(14),
                image: (item.produit.image?.isNotEmpty ?? false)
                    ? DecorationImage(
                    image: NetworkImage(item.produit.image!), fit: BoxFit.cover)
                    : null,
              ),
              child: (item.produit.image?.isEmpty ?? true)
                  ? Center(child: Icon(Icons.medication_rounded, size: 28, color: _C.primaryMid))
                  : null,
            ),
            Positioned(
              bottom: 0, right: 0,
              child: Container(
                width: 20, height: 20,
                decoration: BoxDecoration(
                  color: _C.primary, shape: BoxShape.circle,
                  border: Border.all(color: _C.white, width: 1.5),
                ),
                child: Center(
                  child: Text('${item.quantite}',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 9, fontWeight: FontWeight.w800, color: _C.white)),
                ),
              ),
            ),
          ]),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.produit.nom ?? '',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14, fontWeight: FontWeight.w700, color: _C.black),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _C.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text('Rx', style: GoogleFonts.plusJakartaSans(
                      fontSize: 8, fontWeight: FontWeight.w700, color: _C.primaryDark)),
                ),
                const SizedBox(width: 6),
                Expanded(child: Text(item.produit.categorieNom ?? '',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: _C.label),
                    maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Text('${_formatPrix(item.produit.prix)} F × ${item.quantite}',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 11, color: _C.label, fontWeight: FontWeight.w500)),
                const Spacer(),
                Text('= ${_formatPrix(item.sousTotal)} F',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14, fontWeight: FontWeight.w800,
                        color: _C.primaryDark, letterSpacing: -0.3)),
              ]),
            ]),
          ),
          const SizedBox(width: 12),
          _buildQteControl(i, item),
        ]),
      ),
    );
  }

  Widget _buildQteControl(int i, PanierItem item) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      GestureDetector(
        onTap: () => _modifierQuantite(i, 1),
        child: Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [_C.primary, _C.primaryDark],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(9),
            boxShadow: [BoxShadow(color: _C.primary.withOpacity(0.28),
                blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: const Icon(Icons.add_rounded, color: _C.white, size: 16),
        ),
      ),
      const SizedBox(height: 6),
      Container(
        width: 32, height: 28,
        decoration: BoxDecoration(
          color: _C.bg, borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _C.border),
        ),
        child: Center(
          child: Text('${item.quantite}',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 14, fontWeight: FontWeight.w800, color: _C.black)),
        ),
      ),
      const SizedBox(height: 6),
      GestureDetector(
        onTap: () => _modifierQuantite(i, -1),
        child: Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: item.quantite == 1 ? _C.redLight : _C.primaryLight,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
                color: item.quantite == 1
                    ? _C.red.withOpacity(0.3)
                    : _C.primary.withOpacity(0.3)),
          ),
          child: Icon(
            item.quantite == 1 ? Icons.delete_outline_rounded : Icons.remove_rounded,
            color: item.quantite == 1 ? _C.red : _C.primary,
            size: 15,
          ),
        ),
      ),
    ]);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PANIER VIDE
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildPanierVide() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 110, height: 110,
            decoration: BoxDecoration(
              color: _C.primaryLight, shape: BoxShape.circle,
              border: Border.all(color: _C.primary.withOpacity(0.15), width: 2),
            ),
            child: const Icon(Icons.shopping_cart_outlined, color: _C.primary, size: 50),
          ),
          const SizedBox(height: 24),
          Text('Votre panier est vide',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 18, fontWeight: FontWeight.w800, color: _C.black)),
          const SizedBox(height: 8),
          Text('Ajoutez des médicaments depuis\nle catalogue pour passer commande',
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: _C.label, height: 1.5),
              textAlign: TextAlign.center),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [_C.primary, _C.primaryDark],
                    begin: Alignment.centerLeft, end: Alignment.centerRight),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: _C.primary.withOpacity(0.35),
                    blurRadius: 14, offset: const Offset(0, 5))],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.arrow_back_rounded, size: 18, color: _C.white),
                const SizedBox(width: 8),
                Text('Voir le catalogue',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14, fontWeight: FontWeight.w700, color: _C.white)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FOOTER
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildFooter() {
    return Container(
      decoration: BoxDecoration(
        color: _C.white,
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 20, offset: const Offset(0, -6))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _ligneTotal('Articles', '${_panier.count} unité${_panier.count > 1 ? 's' : ''}'),
            const SizedBox(height: 8),
            _ligneTotal('Livraison', 'Gratuite', isGreen: true),
            const SizedBox(height: 12),
            Divider(color: _C.border, thickness: 1),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [_C.dark, _C.primaryDeep],
                    begin: Alignment.centerLeft, end: Alignment.centerRight),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Total à payer',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 11, color: _C.white.withOpacity(0.5))),
                  const SizedBox(height: 4),
                  Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(_formatPrix(_panier.total),
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 28, fontWeight: FontWeight.w800,
                            color: _C.white, letterSpacing: -0.5)),
                    const SizedBox(width: 5),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('F CFA',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 12, color: _C.white.withOpacity(0.55))),
                    ),
                  ]),
                ]),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _C.primary.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _C.primary.withOpacity(0.30)),
                  ),
                  child: Column(children: [
                    Text('${_panier.items.length}',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 18, fontWeight: FontWeight.w800, color: _C.primary)),
                    Text('réf.', style: GoogleFonts.plusJakartaSans(
                        fontSize: 9, color: _C.primary.withOpacity(0.8))),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _passerCommande,
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_C.primary, _C.primaryDark],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(
                    color: _C.primary.withOpacity(0.40),
                    blurRadius: 16, offset: const Offset(0, 6),
                  )],
                ),
                child: Center(
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.shopping_bag_rounded, color: _C.white, size: 22),
                    const SizedBox(width: 10),
                    Text('Confirmer la commande',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 15, fontWeight: FontWeight.w800, color: _C.white)),
                  ]),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _ligneTotal(String label, String value, {bool isGreen = false}) {
    return Row(children: [
      Text(label, style: GoogleFonts.plusJakartaSans(
          fontSize: 13, color: _C.label, fontWeight: FontWeight.w500)),
      const Spacer(),
      if (isGreen)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
              color: _C.primaryLight, borderRadius: BorderRadius.circular(6)),
          child: Text(value, style: GoogleFonts.plusJakartaSans(
              fontSize: 12, fontWeight: FontWeight.w700, color: _C.primaryDark)),
        )
      else
        Text(value, style: GoogleFonts.plusJakartaSans(
            fontSize: 13, fontWeight: FontWeight.w700, color: _C.black)),
    ]);
  }

  Widget _circle(double size, Color color) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );

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