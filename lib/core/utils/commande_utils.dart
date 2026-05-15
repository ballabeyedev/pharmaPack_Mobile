import 'package:flutter/material.dart';

class CommandeUtils {

  static String getStatutLabel(String statut) {
    switch (statut) {
      case 'en_attente':
        return 'En attente';
      case 'valider':
        return 'Validée';
      case 'rejeter':
        return 'Rejetée';
      case 'livree':
        return 'Livrée';
      case 'annulee':
        return 'Annulée';
      default:
        return statut;
    }
  }

  static Color getStatutColor(String statut) {
    switch (statut) {
      case 'en_attente':
        return Colors.orange;
      case 'valider':
        return Colors.green;
      case 'livree':
        return Colors.blue;
      case 'annulee':
        return Colors.deepOrange;
      case 'rejeter':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}