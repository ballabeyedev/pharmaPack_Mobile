import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/commande.dart';
import '../../bloc/commande/commande_bloc.dart';
import '../../bloc/commande/commande_event.dart';

class DetailCommandePage extends StatelessWidget {

  final Commande commande;

  const DetailCommandePage({super.key, required this.commande});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Détail commande"),
        backgroundColor: const Color(0xFF1A2E22),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text("Référence : ${commande.reference}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            const SizedBox(height: 10),

            Text("Statut : ${commande.statut}"),

            const SizedBox(height: 20),

            const Text("Produits :", style: TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 10),

            Expanded(
              child: ListView(
                children: commande.details.map((p) {
                  return ListTile(
                    title: Text(p.nomProduit ?? ""),
                    subtitle: Text("x${p.quantite}"),
                    trailing: Text("${p.prixTotal} FCFA"),
                  );
                }).toList(),
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.all(14),
                ),

                onPressed: () {
                  context.read<CommandeBloc>().add(
                    AnnulerCommandeEvent(commande.id),
                  );

                  Navigator.pop(context);
                },

                child: const Text("Annuler la commande"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}