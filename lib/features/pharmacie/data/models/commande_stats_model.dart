import '../../domain/entities/commande_stats.dart';

class CommandeStatsModel extends CommandeStats {
  CommandeStatsModel({
    required super.enAttente,
    required super.validees,
    required super.livrees,
    required super.annulees,
    required super.rejetees,
  });

  factory CommandeStatsModel.fromList(List<int> data) {
    return CommandeStatsModel(
      enAttente: data.length > 0 ? data[0] : 0,
      validees:  data.length > 1 ? data[1] : 0,
      livrees:   data.length > 2 ? data[2] : 0,
      annulees:  data.length > 3 ? data[3] : 0,
      rejetees:  data.length > 4 ? data[4] : 0,
    );
  }
}