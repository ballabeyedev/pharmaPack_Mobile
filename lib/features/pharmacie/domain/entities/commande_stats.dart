class CommandeStats {
  final int enAttente;
  final int validees;
  final int livrees;
  final int annulees;
  final int rejetees;

  CommandeStats({
    required this.enAttente,
    required this.validees,
    required this.livrees,
    required this.annulees,
    required this.rejetees,
  });

  int get total =>
      enAttente + validees + livrees + annulees + rejetees;
}