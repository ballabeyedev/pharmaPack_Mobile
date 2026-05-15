class Env {
  // 🔹 BASE URL
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://pharmapack.onrender.com/pharmaPack',
  );

  // 🔹 AUTH
  static const login = String.fromEnvironment(
    'AUTH_LOGIN_PATH',
    defaultValue: '/auth/login',
  );

  static const register = String.fromEnvironment(
    'AUTH_REGISTER_PATH',
    defaultValue: '/auth/register',
  );

  // 🔹 COMMANDES STATS
  static const commandesEnAttente = String.fromEnvironment(
    'CMD_EN_ATTENTE',
    defaultValue: '/pharmacie/nombre-de-commandes-en-attente',
  );

  static const commandesValidees = String.fromEnvironment(
    'CMD_VALIDEES',
    defaultValue: '/pharmacie/nombre-de-commandes-validees',
  );

  static const commandesLivrees = String.fromEnvironment(
    'CMD_LIVREES',
    defaultValue: '/pharmacie/nombre-de-commandes-livrees',
  );

  static const commandesAnnulees = String.fromEnvironment(
    'CMD_ANNULEES',
    defaultValue: '/pharmacie/nombre-de-commandes-annulees',
  );

  static const commandesRejetees = String.fromEnvironment(
    'CMD_REJETEES',
    defaultValue: '/pharmacie/nombre-de-commandes-rejetees',
  );

  static const historiqueCommandes = String.fromEnvironment(
    'CMD_HISTORIQUE',
    defaultValue: '/pharmacie/historique-commandes',
  );

  static const produits = String.fromEnvironment(
    'PRODUITS_LIST',
    defaultValue: '/pharmacie/lister-produits',
  );

  static const produitDetail = String.fromEnvironment(
    'PRODUIT_DETAIL',
    defaultValue: '/pharmacie/detail-produit', // 👉 on ajoutera /id dynamiquement
  );

  static const passerCommande = String.fromEnvironment(
    'PASSER_COMMANDE',
    defaultValue: '/pharmacie/passer-commande',
  );

  static const annulerCommande = String.fromEnvironment(
    'ANNULER_COMMANDE',
    defaultValue: '/pharmacie/annuler-commande',
  );

  static const commandeDetail = String.fromEnvironment(
    'COMMANDE_DETAIL',
    defaultValue: '/pharmacie/detailler-commande',
  );

  //commande livree
  static const commandeLivree = String.fromEnvironment(
    'COMMANDE_LIVREE',
    defaultValue: '/pharmacie/commandes-livrees',
  );

  //en attnete
  static const commandeEnAttente = String.fromEnvironment(
    'COMMANDE_EN_ATTENTE',
    defaultValue: '/pharmacie/commandes-en-attente',
  );

  //annulee
  static const commandeAnnulee = String.fromEnvironment(
    'COMMANDE_ANNULEE',
    defaultValue: '/pharmacie/commandes-annulees',
  );

  //validees
  static const commandeValidee = String.fromEnvironment(
    'COMMANDE_VALIDEES',
    defaultValue: '/pharmacie/commandes-validees',
  );

  //rejetees
  static const commandeRejetee = String.fromEnvironment(
    'COMMANDE_REJETEE',
    defaultValue: '/pharmacie/commandes-rejetees',
  );

  static const allCommande = String.fromEnvironment(
    'ALL_COMMANDE',
    defaultValue: '/pharmacie/toutes-les-commandes',
  );

}