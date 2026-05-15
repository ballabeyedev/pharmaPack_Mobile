import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/services/token_service.dart';
import '../../../../injection_container.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/register_user.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser loginUser;
  final RegisterUser registerUser;

  AuthBloc({
    required this.loginUser,
    required this.registerUser,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<ResetAuthState>((event, emit) => emit(AuthInitial()));
  }

  // =========================
  // 🔐 LOGIN SAFE + ROBUSTE
  // =========================
  Future<void> _onLoginRequested(
      LoginRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    final identifiant = event.email ?? event.telephone;

    if (identifiant == null || identifiant.trim().isEmpty) {
      emit(const AuthFailure(message: "Email ou téléphone requis"));
      return;
    }

    try {
      final result = await loginUser(
        identifiant.trim(),
        event.mot_de_passe,
      );

      await result.fold(
            (failure) async {
          if (emit.isDone) return;
          emit(AuthFailure(message: failure.errorMessage));
        },
            (user) async {
          try {
            final storage = sl<FlutterSecureStorage>();

            await storage.write(key: 'user_id', value: user.id);
            await storage.write(key: 'role', value: user.role);

            // sécurité anti crash bloc
            if (emit.isDone) return;

            emit(AuthSuccess(user: user));
          } catch (e) {
            if (!emit.isDone) {
              emit(AuthFailure(
                message: "Erreur stockage local : $e",
              ));
            }
          }
        },
      );
    } catch (e) {
      if (!emit.isDone) {
        emit(AuthFailure(message: "Erreur serveur : $e"));
      }
    }
  }

  // =========================
  // 📝 REGISTER
  // =========================
  Future<void> _onRegisterRequested(
      RegisterRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    try {
      final result = await registerUser.call(
        nom: event.nom,
        prenom: event.prenom,
        email: event.email,
        mot_de_passe: event.mot_de_passe,
        adresse: event.adresse,
        telephone: event.telephone,

        nomPharmacie: event.nomPharmacie,
        emailPharmacie: event.emailPharmacie,
        telephonePharmacie: event.telephonePharmacie,
        villePharmacie: event.villePharmacie,
        adressePharmacie: event.adressePharmacie,
      );

      result.fold(
            (failure) {
          emit(AuthFailure(message: failure.errorMessage));
        },
            (user) {
          emit(AuthSuccess(user: user));
        },
      );
    } catch (e) {
      emit(AuthFailure(message: "Erreur inscription : $e"));
    }
  }

  // =========================
  // 🚪 LOGOUT
  // =========================
  Future<void> _onLogoutRequested(
      LogoutRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    try {
      final storage = sl<FlutterSecureStorage>();

      await sl<TokenService>().clearToken();
      await storage.delete(key: 'user_id');
      await storage.delete(key: 'role');

      emit(AuthInitial());
    } catch (e) {
      emit(AuthFailure(message: 'Erreur lors de la déconnexion : $e'));
    }
  }
}