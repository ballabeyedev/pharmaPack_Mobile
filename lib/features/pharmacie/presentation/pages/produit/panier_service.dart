import '../../../domain/entities/passer_commande.dart';

// ─── Modèle item panier ───────────────────────────────────────────────────────
class PanierItem {
  final dynamic produit;
  int quantite;

  PanierItem({required this.produit, this.quantite = 1});

  double get sousTotal {
    final prix = double.tryParse(produit.prix.toString()) ?? 0;
    return prix * quantite;
  }
}

// ─── Singleton PanierService ──────────────────────────────────────────────────
class PanierService {
  static final PanierService _instance = PanierService._internal();
  factory PanierService() => _instance;
  PanierService._internal();

  final List<PanierItem> items = [];

  int get count => items.fold(0, (s, i) => s + i.quantite);
  double get total => items.fold(0.0, (s, i) => s + i.sousTotal);

  void ajouter(dynamic produit) {
    final idx = items.indexWhere((i) => i.produit.id == produit.id);
    if (idx >= 0) {
      items[idx].quantite++;
    } else {
      items.add(PanierItem(produit: produit));
    }
  }

  void modifier(int idx, int delta) {
    items[idx].quantite += delta;
    if (items[idx].quantite <= 0) items.removeAt(idx);
  }

  void vider() => items.clear();

  int qte(String id) {
    final idx = items.indexWhere((i) => i.produit.id == id);
    return idx >= 0 ? items[idx].quantite : 0;
  }

  PasserCommande buildCommande() {
    return PasserCommande(
      produits: items
          .map((item) => LigneCommande(
        produitId: item.produit.id,
        quantite: item.quantite,
      ))
          .toList(),
    );
  }
}