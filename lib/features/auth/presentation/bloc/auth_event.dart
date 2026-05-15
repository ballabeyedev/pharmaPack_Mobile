import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// =========================
// 🔐 LOGIN
// =========================
class LoginRequested extends AuthEvent {
  final String? email;
  final String? telephone;
  final String mot_de_passe;

  const LoginRequested({
    this.email,
    this.telephone,
    required this.mot_de_passe,
  });

  @override
  List<Object?> get props => [email, telephone, mot_de_passe];
}

// =========================
// 📝 REGISTER (USER + PHARMACIE)
// =========================
class RegisterRequested extends AuthEvent {
  // ===== USER =====
  final String nom;
  final String prenom;
  final String email;
  final String mot_de_passe;
  final String adresse;
  final String telephone;

  // ===== PHARMACIE =====
  final String nomPharmacie;
  final String emailPharmacie;
  final String telephonePharmacie;
  final String villePharmacie;
  final String adressePharmacie;

  const RegisterRequested({
    // USER
    required this.nom,
    required this.prenom,
    required this.email,
    required this.mot_de_passe,
    required this.adresse,
    required this.telephone,

    // PHARMACIE
    required this.nomPharmacie,
    required this.emailPharmacie,
    required this.telephonePharmacie,
    required this.villePharmacie,
    required this.adressePharmacie,
  });

  @override
  List<Object?> get props => [
    // USER
    nom,
    prenom,
    email,
    mot_de_passe,
    adresse,
    telephone,

    // PHARMACIE
    nomPharmacie,
    emailPharmacie,
    telephonePharmacie,
    villePharmacie,
    adressePharmacie,
  ];
}

// =========================
// 🚪 LOGOUT
// =========================
class LogoutRequested extends AuthEvent {}

// =========================
// 🔄 RESET STATE
// =========================
class ResetAuthState extends AuthEvent {}