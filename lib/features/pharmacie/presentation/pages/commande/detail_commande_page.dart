import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../domain/entities/commande.dart';
import '../../../domain/entities/commande_detail.dart';
import '../../bloc/commande/commande_bloc.dart';
import '../../bloc/commande/commande_event.dart';
import '../../bloc/commande/commande_state.dart';

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
  static const purple       = Color(0xFF7C4DFF);
  static const purpleLight  = Color(0xFFEDE7F6);
  static const orange       = Color(0xFFFF9800);
  static const orangeLight  = Color(0xFFFFF3E0);
}

class DetailCommandePage extends StatefulWidget {
  final String commandeId;

  const DetailCommandePage({super.key, required this.commandeId});

  @override
  State<DetailCommandePage> createState() => _DetailCommandePageState();
}

class _DetailCommandePageState extends State<DetailCommandePage> {
  @override
  void initState() {
    super.initState();
    context.read<CommandeBloc>().add(LoadCommandeDetail(widget.commandeId));
  }

  _StatutInfo _statutInfo(String statut) {
    switch (statut.toLowerCase()) {
      case 'en_attente':
        return _StatutInfo('En attente',  _C.amberLight,   _C.amber,  Icons.hourglass_top_rounded);
      case 'validee':
        return _StatutInfo('Validée',     _C.blueLight,    _C.blue,   Icons.check_circle_rounded);
      case 'livree':
        return _StatutInfo('Livrée',      _C.primaryLight, _C.primary, Icons.local_shipping_rounded);
      case 'annulee':
        return _StatutInfo('Annulée',     _C.redLight,     _C.red,    Icons.cancel_rounded);
      case 'rejetee':
        return _StatutInfo('Rejetée',     _C.purpleLight,  _C.purple, Icons.block_rounded);
      default:
        return _StatutInfo(statut,        _C.border,       _C.label,  Icons.info_rounded);
    }
  }

  bool _peutAnnuler(Commande commande) {
    return commande.statut.toLowerCase() == 'en_attente';
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _C.bg,
        body: BlocConsumer<CommandeBloc, CommandeState>(
          listener: (context, state) {
            if (state is CommandeSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(children: [
                    const Icon(Icons.check_circle_rounded, color: _C.white, size: 16),
                    const SizedBox(width: 8),
                    Text('Commande annulée avec succès',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, color: _C.white)),
                  ]),
                  backgroundColor: _C.primaryDark,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                ),
              );
              Navigator.pop(context);
            }
            if (state is CommandeError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message,
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: _C.white)),
                  backgroundColor: _C.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is CommandeLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: _C.primary, strokeWidth: 3),
                    const SizedBox(height: 16),
                    Text('Chargement en cours…',
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, color: _C.label)),
                  ],
                ),
              );
            }
            if (state is CommandeError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 72, height: 72,
                        decoration: BoxDecoration(color: _C.redLight, shape: BoxShape.circle),
                        child: const Icon(Icons.error_outline, size: 36, color: _C.red),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Impossible de charger la commande',
                        style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: _C.black),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, color: _C.label),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => context.read<CommandeBloc>().add(LoadCommandeDetail(widget.commandeId)),
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('Réessayer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _C.primary,
                          foregroundColor: _C.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (state is CommandeDetailLoaded) {
              final commande = state.commande;
              final si = _statutInfo(commande.statut);
              final dateStr = _formatDate(commande.createdAt);
              final updateStr = commande.updatedAt != null ? _formatDate(commande.updatedAt!) : null;

              return CustomScrollView(
                slivers: [
                  // ─── App Bar ───────────────────────────────────────────
                  SliverAppBar(
                    expandedHeight: 240,
                    pinned: true,
                    backgroundColor: _C.dark,
                    automaticallyImplyLeading: false,
                    elevation: 0,
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
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(fit: StackFit.expand, children: [
                        // Fond dégradé
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF0D1F17), _C.primaryDeep],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                        // Cercles décoratifs
                        Positioned(top: -40, right: -30,
                            child: _circle(180, _C.primary.withOpacity(0.07))),
                        Positioned(top: 50, right: 70,
                            child: _circle(90, _C.primary.withOpacity(0.05))),
                        Positioned(bottom: -20, left: -20,
                            child: _circle(120, _C.primaryMid.withOpacity(0.06))),
                        // Grille décorative subtile
                        Positioned.fill(
                          child: CustomPaint(painter: _GridPainter()),
                        ),
                        // Contenu principal du header
                        Positioned(
                          bottom: 24, left: 20, right: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Badge statut
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: si.bgColor.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: si.textColor.withOpacity(0.3)),
                                ),
                                child: Row(mainAxisSize: MainAxisSize.min, children: [
                                  Icon(si.icon, size: 13, color: si.textColor),
                                  const SizedBox(width: 6),
                                  Text(si.label,
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11, fontWeight: FontWeight.w700, color: si.textColor)),
                                ]),
                              ),
                              const SizedBox(height: 12),
                              // Référence
                              Text(
                                'Commande #${commande.reference}',
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 22, fontWeight: FontWeight.w800,
                                    color: _C.white, letterSpacing: -0.5, height: 1.2),
                              ),
                              const SizedBox(height: 6),
                              // Date
                              Row(children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: _C.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.calendar_today_rounded, size: 11, color: _C.label),
                                ),
                                const SizedBox(width: 6),
                                Text('Passée le $dateStr',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: _C.label)),
                              ]),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ),

                  // ─── Corps ────────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 48),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // ── Récapitulatif ──
                          _sectionTitle(Icons.info_outline_rounded, 'Récapitulatif'),
                          const SizedBox(height: 10),
                          _buildCard(
                            child: Column(children: [
                              _recapRow(Icons.tag_rounded, 'Référence', '#${commande.reference}', isFirst: true),
                              _recapRow(Icons.local_shipping_rounded, 'Mode de livraison',
                                  commande.modeLivraison == 'livraison' ? 'Livraison à domicile' : 'Retrait en pharmacie'),
                              if (commande.adresseLivraison != null && commande.adresseLivraison!.isNotEmpty)
                                _recapRow(Icons.location_on_rounded, 'Adresse', commande.adresseLivraison!),
                              _recapRow(Icons.shopping_bag_rounded, 'Produits',
                                  '${commande.details.length} produit${commande.details.length > 1 ? 's' : ''}'),
                              if (updateStr != null)
                                _recapRow(Icons.update_rounded, 'Dernière mise à jour', updateStr),
                              if (commande.motifAnnulation != null && commande.motifAnnulation!.isNotEmpty)
                                _recapRow(Icons.comment_rounded, 'Motif annulation', commande.motifAnnulation!, isLast: true),
                            ]),
                          ),

                          const SizedBox(height: 24),

                          // ── Produits commandés ──
                          _sectionTitle(Icons.medication_rounded, 'Produits commandés'),
                          const SizedBox(height: 10),
                          ...commande.details.asMap().entries.map((entry) =>
                              _buildDetailCard(entry.value, entry.key)),

                          const SizedBox(height: 24),

                          // ── Récapitulatif financier ──
                          _sectionTitle(Icons.receipt_rounded, 'Récapitulatif financier'),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [_C.dark, _C.primaryDeep],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [BoxShadow(
                                  color: _C.primary.withOpacity(0.22),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8))],
                            ),
                            child: Column(children: [
                              ...commande.details.map((d) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(children: [
                                  Expanded(child: Text(
                                    '${d.nomProduit ?? 'Produit'} ×${d.quantite}',
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12, color: _C.white.withOpacity(0.6)),
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                  )),
                                  Text('${_formatPrix(d.prixTotal)} F CFA',
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12, color: _C.white.withOpacity(0.6))),
                                ]),
                              )),
                              Container(
                                  height: 1,
                                  color: _C.white.withOpacity(0.1),
                                  margin: const EdgeInsets.symmetric(vertical: 10)),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Total',
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13, color: _C.white.withOpacity(0.7))),
                                  const Spacer(),
                                  Text(_formatPrix(commande.montantTotal),
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 30, fontWeight: FontWeight.w800,
                                          color: _C.white, letterSpacing: -1)),
                                  const SizedBox(width: 4),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text('F CFA',
                                        style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11, color: _C.white.withOpacity(0.55))),
                                  ),
                                ],
                              ),
                            ]),
                          ),

                          const SizedBox(height: 32),

                          // ── Bouton / message annulation ──
                          if (_peutAnnuler(commande))
                            BlocBuilder<CommandeBloc, CommandeState>(
                              builder: (context, state) {
                                final loading = state is CommandeLoading;
                                return GestureDetector(
                                  onTap: loading ? null : () => _confirmerAnnulation(context, commande),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: double.infinity,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: loading ? _C.redLight : _C.red,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: loading ? [] : [BoxShadow(
                                          color: _C.red.withOpacity(0.35),
                                          blurRadius: 16,
                                          offset: const Offset(0, 6))],
                                    ),
                                    child: Center(
                                      child: loading
                                          ? const SizedBox(width: 22, height: 22,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: _C.red))
                                          : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.cancel_outlined, size: 20, color: _C.white),
                                          const SizedBox(width: 10),
                                          Text('Annuler la commande',
                                              style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 15, fontWeight: FontWeight.w700, color: _C.white)),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                          if (!_peutAnnuler(commande))
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _C.border,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                const Icon(Icons.info_outline_rounded, size: 15, color: _C.label),
                                const SizedBox(width: 8),
                                Text(
                                  'Cette commande ne peut plus être annulée.',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: _C.label),
                                ),
                              ]),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // ─── Modal annulation avec motif ────────────────────────────────────────────
  void _confirmerAnnulation(BuildContext context, Commande commande) {
    final motifController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // Handle bar
                    Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Icon
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: _C.redLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.cancel_rounded,
                        color: _C.red,
                        size: 34,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      "Annuler la commande ?",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "#${commande.reference}",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: _C.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Cette action est irréversible",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Input
                    TextFormField(
                      controller: motifController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Motif d'annulation...",
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (v) =>
                      v == null || v.trim().isEmpty
                          ? "Motif obligatoire"
                          : null,
                    ),

                    const SizedBox(height: 20),

                    // Buttons
                    Row(
                      children: [

                        // Cancel
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text("Fermer"),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // Confirm
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (!formKey.currentState!.validate()) return;

                              Navigator.pop(context);

                              context.read<CommandeBloc>().add(
                                AnnulerCommandeEvent(
                                  commande.id,
                                  motif: motifController.text.trim(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _C.red,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text("Confirmer"),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── Carte produit améliorée ─────────────────────────────────────────────
  Widget _buildDetailCard(CommandeDetail d, int index) {
    final imageUrl = d.imageProduit ?? '';
    // Vérification URL valide (http ou https)
    final hasImage = imageUrl.isNotEmpty &&
        (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'));

    return Container(
      key: ValueKey('${d.id}_$index'),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image produit ──
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: hasImage
                ? CachedNetworkImage(
              imageUrl: imageUrl,
              width: 68,
              height: 68,
              fit: BoxFit.cover,
              httpHeaders: const {
                // Ajoute ici tes headers si l'API nécessite un token
                // 'Authorization': 'Bearer $token',
              },
              placeholder: (context, url) => _imagePlaceholder(isLoading: true),
              errorWidget: (context, url, error) => _imagePlaceholder(isError: true),
            )
                : _imagePlaceholder(),
          ),

          const SizedBox(width: 14),

          // ── Infos produit ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.nomProduit ?? 'Produit',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14, fontWeight: FontWeight.w700, color: _C.black),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _badge('${_formatPrix(d.prixUnitaire)} F/unité', _C.primaryLight, _C.primaryDark),
                    _badge('×${d.quantite}', _C.border, _C.sub),
                    if (d.prixTotal != null)
                      _badge('Total: ${_formatPrix(d.prixTotal)} F', _C.orangeLight, _C.orange),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder({bool isLoading = false, bool isError = false}) {
    return Container(
      width: 68, height: 68,
      decoration: BoxDecoration(
        color: _C.primaryLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: isLoading
          ? const Center(child: SizedBox(
          width: 20, height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: _C.primary)))
          : Icon(
        isError ? Icons.broken_image_rounded : Icons.medication_rounded,
        color: _C.primary, size: 28,
      ),
    );
  }

  Widget _badge(String text, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(text,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 10, fontWeight: FontWeight.w600, color: textColor)),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 10,
            offset: const Offset(0, 3))],
      ),
      child: child,
    );
  }

  Widget _recapRow(IconData icon, String label, String value,
      {bool isFirst = false, bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: _C.border, width: 1)),
        borderRadius: isFirst
            ? const BorderRadius.vertical(top: Radius.circular(20))
            : isLast
            ? const BorderRadius.vertical(bottom: Radius.circular(20))
            : null,
      ),
      child: Row(children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
              color: _C.primaryLight, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 16, color: _C.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.plusJakartaSans(fontSize: 10, color: _C.label)),
              const SizedBox(height: 2),
              Text(value,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13, fontWeight: FontWeight.w700, color: _C.black)),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Row(children: [
      Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
            color: _C.primaryLight, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 16, color: _C.primary),
      ),
      const SizedBox(width: 10),
      Text(title,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 15, fontWeight: FontWeight.w700, color: _C.black)),
      const SizedBox(width: 12),
      Expanded(child: Container(height: 1.5, color: _C.border)),
    ]);
  }

  Widget _circle(double size, Color color) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );

  String _formatDate(DateTime d) {
    const months = [
      '', 'jan', 'fév', 'mar', 'avr', 'mai', 'jun',
      'jul', 'août', 'sep', 'oct', 'nov', 'déc'
    ];
    return '${d.day} ${months[d.month]} ${d.year} à '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  String _formatPrix(double? prix) {
    if (prix == null) return '–';
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

// ─── Peintre pour la grille décorative du header ──────────────────────────
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;
    const spacing = 30.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => false;
}

class _StatutInfo {
  final String label;
  final Color bgColor;
  final Color textColor;
  final IconData icon;
  const _StatutInfo(this.label, this.bgColor, this.textColor, this.icon);
}